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

# Per-run marks so resize commands can target windows without relying on focus.
TAG="$$"
MARK_RIGHT="atlex-right-$TAG"
MARK_MID="atlex-mid-$TAG"

# 1. Left Chrome
google-chrome --new-window "$LEFT_URL" &
sleep 0.8

# 2. Right Chrome (split horizontally, lands to the right of left)
swaymsg "splith"
google-chrome --new-window "$RIGHT_URL" &
sleep 0.8
swaymsg "mark --add $MARK_RIGHT"

# 3. wezterm middle-right (split vertically — opens below right Chrome).
swaymsg "splitv"
wezterm --config "font_size=$TERM_FONT_SIZE" start --cwd "$DIR" &
sleep 0.8
swaymsg "mark --add $MARK_MID"

# 4. wezterm bottom-right — message logger.
# No splitv: opens as a third sibling in the right column so the three windows
# share one vertical parent (lets us set explicit ppt heights below).
# `direnv exec` loads .envrc without relying on shell init timing, then we drop
# into a normal shell so the window stays open if the logger exits.
LOGGER_DIR="$DIR/apps/services"
wezterm --config "font_size=$TERM_FONT_SIZE" start --cwd "$LOGGER_DIR" -- sh -c \
    "direnv exec '$LOGGER_DIR' pnpm tsx scratch/log-messages.ts; exec ${SHELL:-zsh}" &
sleep 0.8

# Target ratios in the right column: 50% / 30% / 20%.
# Setting two of three is enough — the remaining sibling absorbs the rest.
swaymsg "[con_mark=$MARK_RIGHT] resize set height 50 ppt"
swaymsg "[con_mark=$MARK_MID] resize set height 30 ppt"
