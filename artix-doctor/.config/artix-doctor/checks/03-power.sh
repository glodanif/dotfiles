section "Power Management"

command -v loginctl &>/dev/null && ok "loginctl available" || err "loginctl not available" "Install elogind:" "sudo pacman -S elogind"

if loginctl poweroff --help &>/dev/null; then
    ok "loginctl power actions accessible"
else
    warn "loginctl power actions may require authentication" "Ensure elogind is running and you have an active session (check polkit rules)."
fi
