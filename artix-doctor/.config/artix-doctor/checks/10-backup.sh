section "Backup"

command -v restic &>/dev/null && ok "restic installed" || err "restic not installed"

if [[ -L ~/.local/bin/sys-backup || -f ~/.local/bin/sys-backup ]]; then
    ok "sys-backup script available"
else
    err "sys-backup script missing"
fi

if sudo -n test -r /root/.restic-password 2>/dev/null; then
    ok "restic password file exists and readable by sudo"
else
    warn "cannot verify /root/.restic-password"
fi

BACKUP_UUID="468df889-d691-4d07-8c89-31caa4c0b2ea"
if sudo -n blkid -U "$BACKUP_UUID" &>/dev/null; then
    ok "backup disk detected by UUID"
else
    warn "backup disk not currently connected"
fi
