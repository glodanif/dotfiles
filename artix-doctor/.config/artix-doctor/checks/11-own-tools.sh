section "Own Tools"

command -v terminal-weather &>/dev/null && ok "terminal-weather available" || err "terminal-weather not in PATH"
command -v profile-io &>/dev/null && ok "profile-io available" || err "profile-io not in PATH"
