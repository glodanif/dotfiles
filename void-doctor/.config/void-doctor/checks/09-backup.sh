section "Backup"

command -v restic &>/dev/null && ok "restic installed" || err "restic not installed" "Install:" "sudo xbps-install -S restic"

if [[ -L ~/.local/bin/sys-backup || -f ~/.local/bin/sys-backup ]]; then
    ok "sys-backup script available"
else
    err "sys-backup script missing (~/.local/bin/sys-backup)" "Stow the scripts package:" "cd ~/dotfiles && stow scripts"
fi

PASSWORD_FILE="/root/.restic-password"
if sudo -n test -r "$PASSWORD_FILE" 2>/dev/null; then
    ok "restic password file present ($PASSWORD_FILE)"
else
    warn "cannot verify $PASSWORD_FILE (required for backup)" "Create it as root:" "sudo sh -c 'echo YOUR_PASSWORD > /root/.restic-password'"
fi

MOUNT_POINT="/mnt/backup"
REPO="$MOUNT_POINT/restic"
if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
    ok "backup mount point mounted ($MOUNT_POINT)"
    if sudo restic --repo "$REPO" --password-file "$PASSWORD_FILE" snapshots &>/dev/null 2>&1; then
        latest=$(sudo restic --repo "$REPO" --password-file "$PASSWORD_FILE" snapshots --last 2>/dev/null \
            | grep -oP '\d{4}-\d{2}-\d{2}' | tail -1)
        ok "restic repo accessible, latest snapshot: ${latest:-unknown}"
    else
        warn "restic repo not initialized or inaccessible at $REPO" "Initialize the repo:" "sudo restic --repo $REPO --password-file $PASSWORD_FILE init"
    fi
else
    warn "backup mount point not mounted ($MOUNT_POINT)" "Mount it:" "sudo mount $MOUNT_POINT"
fi
