@RTK.md

Call rtk read, rtk grep, or rtk find directly, if you need to read a file, find a file or filter its content.

# Artix Dotfiles

## Repo Layout

This is a **GNU Stow** repo. Each top-level directory is a stow package whose contents mirror `$HOME`:

| Package | What it manages |
|---|---|
| `artix-doctor/` | System health checks (`.config/artix-doctor/checks/*.sh`) |
| `bash/` | Bash utilities (`.config/bash/utils.sh`) — shared by scripts & artix-doctor |
| `hypr/` | Hyprland WM config (split into `hyprland.conf` + `*.conf` includes) |
| `waybar/` | Status bar |
| `walker/` | App launcher (config.toml) |
| `ghostty/` | Terminal emulator |
| `mako/` | Notifications |
| `wlogout/` | Logout menu |
| `screensaver/` | Screensaver config |
| `swayimg/` | Image viewer |
| `mpv/` | Media player |
| `zsh/` | Zsh shell config |
| `greetd/` | Login manager (config.toml) |
| `pipewire/` | Audio (PipeWire conf.d snippets) |
| `gnupg/` | GPG agent config |
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

### Existing checks (00–14)

00-bootloader (limine, mkinitcpio hooks, plymouth), 01-services (OpenRC: required & optional), 02-shell (zsh, oh-my-zsh, p10k), 03-power (elogind/loginctl), 04-dotfiles (stow symlink integrity), 05-ssh (keys, agent, git config), 06-vpn (wireguard), 07-toolchains (rust, flutter, dart, java, esp32), 08-packages (yay, pacman repos, parallel downloads), 09-hardware (nvidia, android-udev, ESP32 serial), 10-backup (restic, NAS mount, samba creds), 11-own-tools (terminal-weather, pioctl, stainer), 12-apps (voxtype, hyprpm, hy3), 13-fonts (nerd fonts, noto, lato, montserrat, SUSE Mono), 14-dns (dnscrypt-proxy, resolv.conf, NM override, setcap).

### Adding a new check

1. Create `NN-name.sh` in `artix-doctor/.config/artix-doctor/checks/` (next number in sequence, currently 15).
2. Start with `section "Name"`.
3. Use `ok`, `warn`, `err` for assertions; provide fix hints.
4. No shebang needed — files are sourced.
5. Can use variables from `local.conf` (e.g., `$WORK_SSH_KEY`).

### local.conf

`~/.config/artix-doctor/local.conf` is sourced if present. Machine-specific overrides go here (not tracked in git).

## System details

- **Distro**: Artix Linux (OpenRC init, not systemd — use `rc-service`/`rc-update`, not `systemctl`)
- **Bootloader**: Limine
- **WM**: Hyprland (Wayland) with hy3 plugin
- **Login**: greetd
- **Audio**: PipeWire
- **GPU**: NVIDIA (nvidia-dkms)
- **DNS**: dnscrypt-proxy (encrypted DNS, bound to 127.0.0.1)
- **Backup**: restic to NAS (Samba/CIFS mount)
- **AUR helper**: yay
- **Shell**: zsh + oh-my-zsh + powerlevel10k

## Common tasks

- **Apply dotfile changes**: `./refresh.sh` from the repo root (re-stows all packages, updates package lists)
- **Run health check**: `artix-doctor`
- **Service management**: `sudo rc-service <svc> start|stop|restart`, `sudo rc-update add|del <svc> default`
- **Hyprland reload**: Changes to `~/.config/hypr/*.conf` are auto-reloaded by Hyprland
- **Test Waybar**: `~/.local/bin/rewaybar` (kills and relaunches)

## Guidelines when editing

- Hyprland config is split across multiple `.conf` files included from `hyprland.conf` — edit the right file, not the main one.
- Never use systemd commands — this is OpenRC. `rc-service` for services, `rc-update` for boot enable/disable.
- Scripts in `scripts/.local/bin/` use `#!/bin/zsh` and source `~/.config/bash/utils.sh` for shared helpers.
- artix-doctor check scripts are **sourced**, not executed — they share the parent shell's variables and functions.
- The `fix()` pattern takes `(explanation, command)` — keep hints short and actionable.
- Package install commands should use `sudo pacman -S` for official or `yay -S` for AUR.
