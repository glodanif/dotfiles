section "Own Tools"

command -v terminal-weather &>/dev/null && ok "terminal-weather available" || err "terminal-weather not in PATH" "Build/install it and ensure ~/.local/bin is on PATH."
command -v stainer &>/dev/null && ok "stainer available" || err "stainer not in PATH" "Build/install it and ensure ~/.local/bin is on PATH."

