section "Samba"

command -v smbd &>/dev/null && ok "smbd installed" || err "smbd not installed"

[[ -f /etc/samba/smb.conf ]] && ok "smb.conf present" || err "/etc/samba/smb.conf missing"

if command -v testparm &>/dev/null && [[ -f /etc/samba/smb.conf ]]; then
    if testparm -s /etc/samba/smb.conf &>/dev/null 2>&1; then
        ok "smb.conf syntax valid"
    else
        err "smb.conf has syntax errors (run: testparm)"
    fi
fi

sv_running() { sv status "$1" 2>/dev/null | grep -q "^run:" || pgrep -x "$1" &>/dev/null; }
for svc in smbd nmbd; do
    if sv_running "$svc"; then
        ok "$svc running"
    else
        err "$svc not running"
    fi
done

if command -v pdbedit &>/dev/null; then
    user_count=$(sudo pdbedit -L 2>/dev/null | grep -c "." || true)
    if (( user_count > 0 )); then
        ok "$user_count Samba user(s) configured"
    else
        warn "no Samba users configured (run: pdbedit -a <username>)"
    fi
else
    warn "pdbedit not available — cannot check Samba users"
fi
