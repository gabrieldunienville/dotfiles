# Memory pressure handling on the dev workstation

**Date:** 2026-05-20
**Status:** Accepted, applied

## Problem

The dev workstation (Debian 12, swaywm, 38 GiB RAM) was regularly hitting ~100% memory utilization. When that happened, the entire system became so unresponsive that we couldn't open a terminal or process viewer to identify and kill the hog — the only recovery path was a hard reset, losing in-flight work.

Investigation surfaced two contributing factors:

1. **No swap configured at all** (`swapon --show` was empty). With no swap and no overflow space, when RAM fills the kernel has only two options: evict clean page cache or invoke the OOM killer. The desktop thrashes on cache eviction long before the kernel decides to OOM.
2. **The kernel OOM killer is slow to react** on desktop workloads — it triggers on allocation failure, not on pressure. By the time it fires, the system has already been unusable for many seconds or minutes.

Primary memory consumers were identified via `ps` audit: language servers (pyright running as `node`, tsserver, lua-language-server) and AI agents (Claude Code). Each can easily hold 1–2 GiB+, and several copies often run concurrently across editor sessions.

A key behavioral constraint: **LSPs are cheap to lose** (reopen a file, the editor re-spawns one), but **AI agent sessions hold expensive state** (conversation history, plans, in-progress reasoning) that is lost on kill. We need recovery to prefer the cheap victims.

## Decision

A two-part fix:

1. **zram swap, 50% of RAM, zstd compression** — gives the kernel an overflow space without disk I/O. Allocated lazily so there is no upfront RAM cost.
2. **nohang-desktop with custom badness rules** — a userspace OOM killer that uses PSI (Pressure Stall Information) to fire *before* the system locks up. Custom rules bias the kill queue toward LSPs and away from AI agents.

The two parts complement each other: zram smooths the pressure curve so nohang has more runway to detect and act; nohang ensures that if pressure does spike, the right thing dies.

## Alternatives considered

### Disk-based swap (file or partition)
Rejected. SSD wear over time, much higher latency than zram, would still introduce noticeable lag when active. zram trades a small amount of CPU for much better latency and no wear.

### `systemd-oomd` (instead of nohang)
Rejected. systemd-oomd operates at the cgroup level. LSPs are typically spawned as children of the editor, and AI agents are launched from the same terminal — so they often share a cgroup with the editor/terminal scope. systemd-oomd would kill the whole scope rather than just the offender, which is the opposite of the granularity we want.

### `earlyoom` (instead of nohang)
Rejected after empirical test. earlyoom has simple `--prefer` / `--avoid` regex knobs, which sounded like exactly what we wanted. But earlyoom only matches `/proc/PID/comm`, which is truncated to 15 chars and reflects the *binary*, not the script. A live `ps` audit confirmed that pyright runs as `node` (cmdline: `node .../pyright-langserver --stdio`) — indistinguishable from any other node process by comm alone. nohang's full-cmdline matching (`@BADNESS_ADJ_RE_CMDLINE`) handles this cleanly.

### Per-application cgroup memory limits (`systemd-run --user --scope -p MemoryMax=...`)
Not rejected, just out of scope for this initial pass. Still a good complement for specific known offenders if a process turns out to need a hard ceiling. Can be layered on later.

### Buy more RAM
Deferred. More RAM raises the ceiling but doesn't fix the responsiveness problem: workloads expand to fill available memory regardless of size. The lockup-on-pressure behavior is the actual issue.

## Why these specific knobs

- **`PERCENT=50` for zram (~19 GiB pool on 38 GiB RAM).** Going above 50% gets risky: if zram itself gets memory-pressured, behavior gets weird. 50% is the standard upper bound across Fedora, Ubuntu, ChromeOS defaults.
- **`zstd` over `lz4`.** zstd compresses ~3× on typical desktop pages vs. ~2.1× for lz4. CPU cost is mild and the workstation has cores to spare. Yields ~50–60 GiB *effective* overflow.
- **`±200` for badness adjustments.** Matches the magnitude of the shipped nohang-desktop rules (Chromium renderers = +200, window managers = −200). Stacking on the same scale keeps ordering predictable.
- **`-200` for `claude` (not stronger).** A truly runaway agent (30+ GiB) should still be killable. The goal is "prefer LSP when both are similarly bad," not "Claude is invincible."
- **nohang-*desktop* service variant over the basic `nohang` service.** Ships with built-in protection for sway, Xwayland, dbus, systemd, gdm, and others, and supports GUI notifications when a kill is about to fire.

## How to recreate

### Prerequisites
- Debian 12 (bookworm)
- sudo access
- Sizing below assumes ~38 GiB RAM; adjust `PERCENT` if very different

### Install both packages

```bash
sudo apt install -y nohang zram-tools
```

### Configure zram

Edit `/etc/default/zramswap` so the only active lines are:

```
ALGO=zstd
PERCENT=50
```

(All other lines remain commented.) The package's postinst starts the service with the original defaults, so a restart is required for the edit to take effect:

```bash
sudo systemctl restart zramswap.service
```

Verify: `zramctl` should show `~19G` `DISKSIZE` with `ALGORITHM=zstd`.

### Configure nohang

Switch from the basic `nohang.service` to `nohang-desktop.service` (the two `Conflicts=` each other, so only one runs):

```bash
sudo systemctl disable --now nohang.service
sudo systemctl enable  --now nohang-desktop.service
```

Append the custom badness rules to the end of `/etc/nohang/nohang-desktop.conf`:

```conf
# --- Local overrides: prefer LSPs, spare AI agents ---

# LSPs that run as their own binary (matched via comm name, 15-char trunc)
@BADNESS_ADJ_RE_NAME      200  ///  ^lua-language-
@BADNESS_ADJ_RE_NAME      200  ///  ^gopls$
@BADNESS_ADJ_RE_NAME      200  ///  ^rust-analyzer$
@BADNESS_ADJ_RE_NAME      200  ///  ^clangd$

# LSPs running under node (must match by cmdline)
@BADNESS_ADJ_RE_CMDLINE   200  ///  pyright-langserver
@BADNESS_ADJ_RE_CMDLINE   200  ///  typescript-language-server
@BADNESS_ADJ_RE_CMDLINE   200  ///  /tsserver(\.js)?\b

# Spare Claude Code (still killable if it goes truly runaway)
@BADNESS_ADJ_RE_NAME     -200  ///  ^claude$
```

Reload so the rules take effect:

```bash
sudo systemctl restart nohang-desktop.service
```

### Verify

Config parses and all rules are loaded:

```bash
sudo /usr/sbin/nohang --check --config /etc/nohang/nohang-desktop.conf | \
  grep -A1 -E '(lua-language|gopls|rust-analyzer|clangd|pyright|tsserver|claude|typescript)'
```

Should echo back all 8 custom rules.

Live badness ranking (LSPs should sort above `claude`):

```bash
sudo /usr/sbin/nohang --tasks --config /etc/nohang/nohang-desktop.conf
```

At install time, an active pyright instance scored badness `907` while `claude` processes scored `470–474` — a ~437-point preference gap.

Swap and zram state:

```bash
zramctl              # DATA=logical, COMPR=actual RAM cost; ratio 2.5×+ is healthy
swapon --show        # /dev/zram0 should be listed at priority 100
free -h               # Swap line should show ~19 GiB total
```

## Operational notes

- **zram swap fills lazily.** `DATA: 4K` immediately after install is correct — the kernel hasn't needed it yet. Under pressure, inactive pages get pushed and compressed.
- **First time nohang fires** there will be a desktop notification before the kill (a feature of the desktop variant).
- **Adding more LSPs later:** standalone-binary LSPs use `@BADNESS_ADJ_RE_NAME` (remember the 15-char `comm` truncation). Node-hosted LSPs (i.e. anything launched via `node /path/to/...-langserver`) require `@BADNESS_ADJ_RE_CMDLINE`. Restart `nohang-desktop.service` after edits.
- **Tuning CMDLINE rules sparingly.** nohang's docs warn that cmdline matching slows victim search "under heavy swapping." Three rules is fine; piling on more is not.
- **If something gets killed and shouldn't have**, add an `@BADNESS_ADJ_RE_NAME -200 /// ^name$` (or cmdline equivalent) rule to bias against it.
