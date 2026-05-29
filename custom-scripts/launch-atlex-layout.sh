#!/usr/bin/env bash
# Launch an Atlex dev layout on the current sway workspace:
#   Left:           Chrome → http://$LOOPBACK:5173/practice
#   Top right:      Chrome → http://$LOOPBACK:5176
#   Middle right:   wezterm in the worktree dir
#   Bottom right:   wezterm in apps/services running `pnpm tsx scratch/log-messages.ts`
#
# LOOPBACK is read from <wt>/.envrc.local (falls back to 127.0.0.1).
#
# Usage:
#   launch-atlex-layout.sh telemetry-cli
#   launch-atlex-layout.sh ~/atlex-ts--telemetry-cli
#
# Alternatives if this script gets fragile or harder to extend:
#   1. swaymsg append_layout — declarative JSON layout with "swallow" rules
#      that match windows by app_id/title. Replaces the splith/splitv/sleep
#      dance; you template the JSON to parameterize. Good next step if the
#      sleeps start racing.
#   2. python-i3ipc (or a Go/Rust i3ipc binding) — event-driven IPC client.
#      Subscribe to window::new and place each window deterministically. Right
#      tool once layout logic gets conditional, multi-monitor, or reactive.
#   3. i3-resurrect / swayr — session save/restore. Useful for "restore my
#      whole desktop on login," less for parameterized per-WT launches.

set -euo pipefail

ARG="${1:-}"
if [[ -z "$ARG" ]]; then
    echo "usage: $0 <worktree-path-or-branch>" >&2
    exit 1
fi

# Resolve worktree dir: path-like arg used as-is, otherwise treat as branch name.
if [[ "$ARG" == /* || "$ARG" == ./* || "$ARG" == ../* || "$ARG" == ~* ]]; then
    DIR="${ARG/#\~/$HOME}"
else
    DIR="$HOME/atlex-ts--$ARG"
fi

if [[ ! -d "$DIR" ]]; then
    echo "error: $DIR is not a directory" >&2
    exit 1
fi

LOOPBACK="127.0.0.1"
if [[ -f "$DIR/.envrc.local" ]]; then
    # shellcheck disable=SC1091
    LOOPBACK="$(source "$DIR/.envrc.local" && echo "$LOOPBACK")"
fi

LEFT_URL="http://${LOOPBACK}:5173/practice"
RIGHT_URL="http://${LOOPBACK}:5176"

# Smaller than the default 16pt so both right-side terminals fit comfortably.
TERM_FONT_SIZE="11.0"

CHROME_APP_ID="google-chrome"
WEZTERM_APP_ID="org.wezfurlong.wezterm"

# Per-run marks so resize commands can target windows without relying on focus.
TAG="$$"
MARK_RIGHT="atlex-right-$TAG"
MARK_MID="atlex-mid-$TAG"

# How many windows of $1 are currently in the sway tree. grep on the JSON
# avoids a jq dependency — `"app_id": "X"` only ever appears on container nodes.
count_windows() {
    swaymsg -t get_tree | grep -c "\"app_id\": \"$1\""
}

# Block until a new window of $1 appears (count increases above $2). When it
# does, sway has already focused it, so a follow-up `mark --add` is safe.
wait_new_window() {
    local app_id="$1" before="$2" deadline=$((SECONDS + 10))
    while (( SECONDS < deadline )); do
        (( $(count_windows "$app_id") > before )) && return 0
        sleep 0.1
    done
    echo "warning: no new $app_id window appeared within 10s" >&2
    return 1
}

# 1. Left Chrome
before=$(count_windows "$CHROME_APP_ID")
google-chrome --new-window "$LEFT_URL" &
wait_new_window "$CHROME_APP_ID" "$before"

# 2. Right Chrome (split horizontally, lands to the right of left)
swaymsg "splith"
before=$(count_windows "$CHROME_APP_ID")
google-chrome --new-window "$RIGHT_URL" &
wait_new_window "$CHROME_APP_ID" "$before"
swaymsg "mark --add $MARK_RIGHT"

# 3. wezterm middle-right (split vertically — opens below right Chrome).
swaymsg "splitv"
before=$(count_windows "$WEZTERM_APP_ID")
wezterm --config "font_size=$TERM_FONT_SIZE" start --cwd "$DIR" -- sh -c \
    "direnv exec '$DIR' turbo dev; exec ${SHELL:-zsh}" &
wait_new_window "$WEZTERM_APP_ID" "$before"
swaymsg "mark --add $MARK_MID"

# 4. wezterm bottom-right — message logger.
# `splitv` here wraps wezterm 1 in a nested vertical container, so wezterm 2
# becomes its sibling INSIDE that nest rather than a third sibling at the
# outer level. This nesting is what makes 50/30/20 ratios reachable: sway's
# `resize set ... ppt` redistributes leftover space EQUALLY among the other
# siblings, so a flat 3-child column forces the two un-set children to be
# equal — you can't get asymmetric ratios. Nesting reduces each resize to a
# clean 2-sibling decision.
# `direnv exec` loads .envrc without relying on shell init timing, then we drop
# into a normal shell so the window stays open if the logger exits.
swaymsg "splitv"
LOGGER_DIR="$DIR/apps/services"
before=$(count_windows "$WEZTERM_APP_ID")
wezterm --config "font_size=$TERM_FONT_SIZE" start --cwd "$LOGGER_DIR" -- sh -c \
    "direnv exec '$LOGGER_DIR' pnpm tsx scratch/log-messages.ts; exec ${SHELL:-zsh}" &
wait_new_window "$WEZTERM_APP_ID" "$before"

# Outer level: Chrome takes 50% of the right column; the nested container
# (holding both wezterms) gets the other 50%.
swaymsg "[con_mark=$MARK_RIGHT] resize set height 70 ppt"
# Inner level: wezterm 1 takes 60% of the nested container (= 30% of total
# right column); wezterm 2 gets the remaining 40% (= 20%).
swaymsg "[con_mark=$MARK_MID] resize set height 60 ppt"

# Clean up our marks so they don't linger on the windows or get inherited by
# something else if we re-run.
swaymsg "unmark $MARK_RIGHT" 2>/dev/null || true
swaymsg "unmark $MARK_MID" 2>/dev/null || true
