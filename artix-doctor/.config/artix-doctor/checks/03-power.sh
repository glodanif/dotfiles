section "Power Management"

command -v loginctl &>/dev/null && ok "loginctl available" || err "loginctl not available"

if loginctl poweroff --help &>/dev/null; then
    ok "loginctl power actions accessible"
else
    warn "loginctl power actions may require authentication"
fi
