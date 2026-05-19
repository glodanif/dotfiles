section "Own Tools"

command -v terminal-weather &>/dev/null && ok "terminal-weather available" || err "terminal-weather not in PATH"
command -v pioctl &>/dev/null && ok "pioctl available" || err "pioctl not in PATH"
command -v stainer &>/dev/null && ok "stainer available" || err "stainer not in PATH"

[ -d "$HOME/.local/share/pioctl" ] && ok ".local/share/pioctl exists" || err ".local/share/pioctl missing"
[ -d "$HOME/.cache/scripts" ] && ok ".cache/scripts exists" || err ".cache/scripts missing"

