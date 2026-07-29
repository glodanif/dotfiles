@RTK.md

Call rtk read, rtk grep, or rtk find directly, if you need to read a file, find a file or filter its content.

# Artix Dotfiles

## Repo Layout

This is a **GNU Stow** repo. Each top-level directory is a stow package whose contents mirror `$HOME`:

| Package | What it manages |
|---|---|
| `artix-doctor/` | System health checks (`.config/artix-doctor/checks/*.sh`) |
| `bash/` | Bash utilities (`.config/bash/utils.sh`) — shared by scripts & artix-doctor |
| `hypr/` | Hyprland WM config — Lua (`hyprland.lua` + `require`d `*.lua` modules) |
| `waybar/` | Status bar |
| `walker/` | App launcher (config.toml) |
| `ghostty/` | Terminal emulator |
| `swaync/` | Notification center (`config.json` + `style.css`) |
| `wlogout/` | Logout menu |
| `screensaver/` | Screensaver config |
| `swayimg/` | Image viewer |
| `mpv/` | Media player |
| `brave/` | Brave launch flags (`.config/brave-origin-flags.conf`) |
| `zsh/` | Zsh shell config |
| `greetd/` | Login manager (config.toml) |
| `pipewire/` | Audio (PipeWire conf.d snippets) |
| `mic/` | Friendly names for audio inputs, read by `mic-watch` |
| `gnupg/` | GPG agent config |
| `go/` | Go env file — relocates GOPATH out of `~/go` to `~/.local/share/go` |
| `ssh/` | SSH client config |
| `restic/` | Backup config |
| `scripts/` | User scripts in `.local/bin/` |
| `stainer/` | Stainer tool config |
| `fastfetch/` | System info display |
| `fontconfig/` | Font rendering overrides (Montserrat unhinted) |
| `elephant/` | Elephant menus (toml) |
| `applications/` | .desktop files |
| `assets/` | Wallpapers and other assets |

**Applying changes**: Always use `./refresh.sh` from the repo root — it re-stows all packages and updates the package lists. Do not run `stow` commands manually.

## artix-doctor

`artix-doctor` is a shell script at `~/.local/bin/artix-doctor` (stowed from `scripts/`). It sources `~/.config/bash/utils.sh` for output helpers, then sources every `*.sh` in `~/.config/artix-doctor/checks/` in order.

### Check script conventions

Each check file follows this pattern:

```sh
section "Section Name"

# Use ok/warn/err with a message, then optional fix hint + command:
command -v foo &>/dev/null && ok "foo installed" || err "foo not installed" "Install:" "sudo pacman -S foo"

# ok(msg)           — green OK, increments OKS counter
# warn(msg, [hint], [cmd]) — yellow WRN, increments WARNINGS, shows fix if given
# err(msg, [hint], [cmd])  — red ERR, increments ERRORS, shows fix if given
# section(name)     — prints a colored section header
```

The `fix()` helper prints: `hint_text command_text` (hint in dim, command in bold cyan).

### Existing checks (00–16)

00-bootloader (limine, mkinitcpio hooks, plymouth), 01-services (OpenRC: required & optional), 02-shell (zsh, oh-my-zsh, p10k), 03-power (elogind/loginctl), 04-dotfiles (stow symlink integrity), 05-ssh (keys, agent, git config), 06-vpn (wireguard), 07-toolchains (rust, flutter, dart, java, esp32), 08-packages (yay, pacman repos, parallel downloads), 09-hardware (nvidia, android-udev, ESP32 serial), 10-backup (restic, NAS mount, samba creds), 11-own-tools (terminal-weather, pioctl, stainer), 12-apps (voxtype), 13-fonts (nerd fonts, noto, lato, montserrat, SUSE Mono), 14-dns (dnscrypt-proxy, resolv.conf, NM override, setcap), 15-suspend (hypridle running, elogind NVIDIA sleep hook), 16-cookies (Brave cookie export, keyring key, cron entry, jar freshness on both hosts).

### Adding a new check

1. Create `NN-name.sh` in `artix-doctor/.config/artix-doctor/checks/` (next number in sequence, currently 17).
2. Start with `section "Name"`.
3. Use `ok`, `warn`, `err` for assertions; provide fix hints.
4. No shebang needed — files are sourced.
5. Can use variables from `local.conf` (e.g., `$WORK_SSH_KEY`).

### local.conf

`~/.config/artix-doctor/local.conf` is sourced if present. Machine-specific overrides go here (not tracked in git).

## System details

- **Distro**: Artix Linux (OpenRC init, not systemd — use `rc-service`/`rc-update`, not `systemctl`)
- **Bootloader**: Limine
- **WM**: Hyprland (Wayland) with native dwindle layout, configured in Lua (`configProvider: lua`)
- **Login**: greetd
- **Audio**: PipeWire
- **GPU**: NVIDIA (nvidia-open-dkms)
- **DNS**: dnscrypt-proxy (encrypted DNS, bound to 127.0.0.1)
- **Backup**: restic to NAS (Samba/CIFS mount)
- **AUR helper**: yay
- **Shell**: zsh + oh-my-zsh + powerlevel10k

## Common tasks

- **Apply dotfile changes**: `./refresh.sh` from the repo root (re-stows all packages, updates package lists)
- **Run health check**: `artix-doctor`
- **Service management**: `sudo rc-service <svc> start|stop|restart`, `sudo rc-update add|del <svc> default`
- **Hyprland reload**: Changes to `~/.config/hypr/*.lua` are auto-reloaded by Hyprland
- **Check Hyprland config**: `Hyprland --verify-config` (parse errors only — it does not execute `hl.on` callbacks)
- **Test Waybar**: `~/.local/bin/rewaybar` (kills and relaunches)

## Guidelines when editing

- Hyprland config is Lua: `hyprland.lua` `require`s one module per concern (`keybinds.lua`, `windows.lua`, …) — edit the right module, not the main file. The `hl` global is the API (`hl.config`, `hl.bind`, `hl.dsp.*`, `hl.window_rule`, `hl.workspace_rule`, `hl.env`, `hl.exec_cmd`).
- The old compositor `*.conf` files were **deleted** once Lua went live — there is no hyprlang fallback left. The only remaining `.conf` files in `hypr/` are `hypridle.conf`, `hyprlock.conf` and `hyprpaper.conf`, which belong to separate tools (not the compositor) and have no Lua config, so they stay hyprlang. Don't add compositor settings to them.
- Lua has no hyprlang `$var` expansion: `programs.lua` returns a table to `require`, and `hl.env` needs `os.getenv("HOME")` rather than a literal `$HOME`.
- **The config reads runtime state.** `display-mode.lua` returns `"pc"` or `"tv"` from `~/.local/state/hypr-display-mode` (written by `monitors-layout-toggle`), and `monitors.lua` + `windows.lua` branch on it to declare the monitor layout and workspace rules. So neither file tells you the active layout on its own — check the state file. Anything unrecognized falls back to `pc`, so a corrupt state file can't leave you with no enabled output.
- Because of the above, `monitors-layout-restore` passes `--skip-monitors` for **both** modes: the layout is already declared at config load, and redoing it would only add modesets (each one a chance to trip the TV's FRL link-training failure). If you ever make the config layout unconditional again, that flag has to come back out or TV boot will never enable the TV.
- A config reload re-runs `hl.monitor`, so it re-applies the declared layout. Editing any required `.lua` while on the TV at @120 re-declares `preferred` and causes a mode flap — switch to PC before editing config.
- `hyprctl keyword` does **not** work under the Lua config ("keyword can't work with non-legacy parsers. Use eval."); use `hyprctl eval '<lua>'` instead. Scripts that touch monitors detect this via `hyprctl systeminfo | grep configProvider`.
- `hyprctl dispatch` parses its argument as **Lua source**, so the legacy `dispatch <name> <args>` form is dead (fails with exit 7). Write `hyprctl dispatch 'hl.dsp.exit()'`, `'hl.dsp.focus({ workspace = 2 })'`, `'hl.dsp.window.close()'`. This applies anywhere a dispatch is shelled out — scripts, `waybar/config.jsonc`, and `hypridle.conf`. Lua accepts single-quoted strings, so use `monitor = 'DP-1'` inside a double-quoted shell string to avoid escaping.
- `hl.dsp.*` builders **silently ignore unknown fields**, and an unrecognized `action` string falls back to `"toggle"` (enum 0) rather than erroring — e.g. `hl.dsp.dpms({ action = "bogus" })` returns `ok` and blanks the screen. Don't probe dispatchers live to discover argument shapes.
- `hl.monitor()` **merges** into an output's existing rule rather than replacing it, so re-enabling an output needs an explicit `disabled = false`. The legacy `hyprctl keyword monitor "NAME,mode,pos,scale"` enabled it implicitly; the Lua form does not. Omitting it leaves the output off and, if it was the last one, Hyprland drops to a headless `FALLBACK` (black screens). See `set_monitor` in `scripts/.local/bin/monitors-layout-toggle`.
- Never use systemd commands — this is OpenRC. `rc-service` for services, `rc-update` for boot enable/disable.
- Scripts in `scripts/.local/bin/` use `#!/bin/zsh` and source `~/.config/bash/utils.sh` for shared helpers.
- artix-doctor check scripts are **sourced**, not executed — they share the parent shell's variables and functions.
- The `fix()` pattern takes `(explanation, command)` — keep hints short and actionable.
- Package install commands should use `sudo pacman -S` for official or `yay -S` for AUR.
