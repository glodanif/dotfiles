section "Samba"

command -v smbd &>/dev/null && ok "smbd installed" || err "smbd not installed" "Install:" "sudo xbps-install -S samba"

[[ -f /etc/samba/smb.conf ]] && ok "smb.conf present" || err "/etc/samba/smb.conf missing" "Create /etc/samba/smb.conf (restore from backup or configure your shares)."

if command -v testparm &>/dev/null && [[ -f /etc/samba/smb.conf ]]; then
    if testparm -s /etc/samba/smb.conf &>/dev/null 2>&1; then
        ok "smb.conf syntax valid"
    else
        err "smb.conf has syntax errors" "Inspect the config:" "testparm"
    fi
fi

sv_running() { sv status "$1" 2>/dev/null | grep -q "^run:" || pgrep -f "$1" &>/dev/null; }
for svc in smbd nmbd; do
    if sv_running "$svc"; then
        ok "$svc running"
    else
        err "$svc not running" "Start it:" "sudo sv up $svc"
    fi
done

if command -v pdbedit &>/dev/null; then
    user_count=$(sudo pdbedit -L 2>/dev/null | grep -c "." || true)
    if (( user_count > 0 )); then
        ok "$user_count Samba user(s) configured"
    else
        warn "no Samba users configured" "Add one:" "sudo pdbedit -a <username>"
    fi
else
    warn "pdbedit not available — cannot check Samba users" "Install Samba:" "sudo xbps-install -S samba"
fi
