section "Own Tools"

command -v terminal-weather &>/dev/null && ok "terminal-weather available" || err "terminal-weather not in PATH" "Build/install it and ensure ~/.local/bin is on PATH."
command -v pioctl &>/dev/null && ok "pioctl available" || err "pioctl not in PATH" "Build/install it and ensure ~/.local/bin is on PATH."
command -v stainer &>/dev/null && ok "stainer available" || err "stainer not in PATH" "Build/install it and ensure ~/.local/bin is on PATH."

[ -d "$HOME/.local/share/pioctl" ] && ok ".local/share/pioctl exists" || err ".local/share/pioctl missing" "Create it:" "mkdir -p ~/.local/share/pioctl"
[ -d "$HOME/.cache/scripts" ] && ok ".cache/scripts exists" || err ".cache/scripts missing" "Create it:" "mkdir -p ~/.cache/scripts"

