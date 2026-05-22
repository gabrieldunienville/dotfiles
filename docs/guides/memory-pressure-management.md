# Managing memory pressure

Operational cheatsheet for the zram + nohang-desktop setup on this workstation. For *why* this setup exists, see [`docs/decisions/2026-05-20-memory-pressure-handling.md`](../decisions/2026-05-20-memory-pressure-handling.md).

## Check what's happening right now

| Command | Tells you |
|---|---|
| `zramctl` | zram pool state. `DATA` = logical swap used, `COMPR` = actual RAM cost. Ratio of the two is compression efficiency (2.5×+ is healthy). |
| `swapon --show` | Confirms `/dev/zram0` is the active swap at priority 100. |
| `free -h` | Overall RAM + swap totals. Quick sanity check. |
| `psi-top` | Live PSI (Pressure Stall Information) view. Shows whether the system *is currently under pressure*, not just whether memory looks full. |
| `oom-sort` | Kernel `oom_score` ranking. Shows what the *kernel* would kill if it had to, ordered by RSS. Does **not** reflect nohang's custom rules. |

## What nohang would actually kill

These are the only commands that reflect the custom badness rules:

```bash
# Per-process badness with all rules applied, plus the top-ranked victim
sudo /usr/sbin/nohang --tasks --config /etc/nohang/nohang-desktop.conf

# Validate config file and echo back the parsed rules (run after editing)
sudo /usr/sbin/nohang --check --config /etc/nohang/nohang-desktop.conf
```

## Service control

```bash
# nohang
systemctl status  nohang-desktop.service
systemctl restart nohang-desktop.service   # required after editing /etc/nohang/nohang-desktop.conf

# zram
systemctl status  zramswap.service
systemctl restart zramswap.service         # required after editing /etc/default/zramswap
```

## Logs — what got killed and why

```bash
# Follow nohang activity live (worth running in a tmux pane when you suspect a kill)
sudo journalctl -u nohang-desktop -f

# Recent kills only
sudo journalctl -u nohang-desktop --since "1 hour ago"
```

When nohang fires you'll also see a desktop notification (the desktop variant feature). The journal has the victim name, PID, and badness score.

## Config files

| Path | Purpose | After editing |
|---|---|---|
| `/etc/nohang/nohang-desktop.conf` | Custom badness rules live at the bottom under the `# --- Local overrides ---` marker. | `--check` then restart service. |
| `/etc/default/zramswap` | `ALGO` and `PERCENT` are the only knobs you'll usually touch. | Restart service. |

## Adding a new LSP to the kill-preference list

1. Identify how it appears in `ps -eo pid,comm,cmd`.
   - If `comm` matches the binary name (e.g. `gopls`, `clangd`), use a NAME rule.
   - If it shows as `node` or another generic interpreter, you need a CMDLINE rule.
2. Append to `/etc/nohang/nohang-desktop.conf` under the `# --- Local overrides ---` block:
   ```conf
   @BADNESS_ADJ_RE_NAME      200  ///  ^new-lsp-name$
   # or
   @BADNESS_ADJ_RE_CMDLINE   200  ///  new-langserver
   ```
   Remember: `comm` is truncated to 15 chars.
3. Validate:
   ```bash
   sudo /usr/sbin/nohang --check --config /etc/nohang/nohang-desktop.conf
   ```
4. Reload:
   ```bash
   sudo systemctl restart nohang-desktop.service
   ```

## Something got killed that shouldn't have — protect it

```bash
sudo journalctl -u nohang-desktop --since "10 min ago"   # confirm the victim
```

Add an avoidance rule to `/etc/nohang/nohang-desktop.conf`:

```conf
@BADNESS_ADJ_RE_NAME     -200  ///  ^process-name$
# or
@BADNESS_ADJ_RE_CMDLINE  -200  ///  distinctive-cmdline-fragment
```

Then `--check` and `restart`. Avoid going below `-300` unless you really mean "never kill this" — a truly runaway process at -400 will starve the system before nohang touches it.

## Tuning zram sizing

`/etc/default/zramswap`:

- `PERCENT=50` (current) — ~19 GiB pool on 38 GiB RAM, ~50–60 GiB effective with zstd.
- Going *above* 50% gets risky: zram itself can become memory-pressured.
- Going *below* 50% (e.g. `PERCENT=33`) is fine if you want a smaller ceiling.
- After editing: `sudo systemctl restart zramswap.service`, then verify with `zramctl`.

`ALGO` choices:

| Algo | Compression | CPU | Notes |
|---|---|---|---|
| `lz4` | ~2.1× | very low | Fastest. Default in many distros. |
| `zstd` | ~3× | low | Current choice. Best ratio for the CPU cost. |
| `lzo-rle` | ~2.3× | very low | Older, similar to lz4. |

## Healthy-state benchmarks

Things to expect on a normal-ish day, for comparison if something looks off:

- `zramctl` immediately after boot: `DATA` very small (kernel hasn't needed swap yet).
- Under sustained dev workload: `DATA` grows to a few GiB; `COMPR` should be ~1/3 of `DATA` with zstd.
- `psi-top` memory `some` values under 5% most of the time. Sustained >20% means real pressure.
- nohang's own RAM use (in `systemctl status nohang-desktop`): ~13 MiB. Capped at 100 MiB by the service unit.
