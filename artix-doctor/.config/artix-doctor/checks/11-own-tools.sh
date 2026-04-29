section "Own Tools"

command -v terminal-weather &>/dev/null && ok "terminal-weather available" || err "terminal-weather not in PATH"
[ -d "$HOME/.local/share/scripts" ] && ok ".local/share/scripts exists" || err ".local/share/scripts missing"
[ -d "$HOME/.cache/scripts" ] && ok ".cache/scripts exists" || err ".cache/scripts missing"

