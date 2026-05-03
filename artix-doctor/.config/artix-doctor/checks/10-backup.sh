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
if mountpoint -q /mnt/backup 2>/dev/null; then
    ok "NAS backup share mounted at /mnt/backup"
else
    warn "NAS backup share not mounted"
fi
if [[ -f /etc/samba/artix-creds ]]; then
    ok "Samba credentials file exists"
else
    warn "Samba credentials file missing at /etc/samba/artix-creds"
fi

