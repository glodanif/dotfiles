section "Backup"
command -v restic &>/dev/null && ok "restic installed" || err "restic not installed" "Install:" "sudo pacman -S restic"
if [[ -L ~/.local/bin/sys-backup || -f ~/.local/bin/sys-backup ]]; then
    ok "sys-backup script available"
else
    err "sys-backup script missing" "Stow the scripts package:" "cd ~/dotfiles && stow scripts"
fi
if sudo -n test -r /root/.restic-password 2>/dev/null; then
    ok "restic password file exists and readable by sudo"
else
    warn "cannot verify /root/.restic-password" "Create it as root:" "sudo sh -c 'echo YOUR_PASSWORD > /root/.restic-password'"
fi
if [[ -f /etc/samba/artix-creds ]]; then
    ok "Samba credentials file exists"
else
    warn "Samba credentials file missing at /etc/samba/artix-creds" "Create it with 'username=' and 'password=' lines for the NAS share."
fi
_nas_mounted_by_doctor=0
if mountpoint -q /mnt/backup 2>/dev/null; then
    ok "NAS backup share mounted at /mnt/backup"
else
    if sudo mount /mnt/backup 2>/dev/null; then
        ok "NAS backup share mounted successfully"
        _nas_mounted_by_doctor=1
    else
        err "Failed to mount NAS backup share" "Check the /mnt/backup entry in /etc/fstab and that the NAS is reachable."
    fi
fi
if (( _nas_mounted_by_doctor == 1 )); then
    sudo umount /mnt/backup 2>/dev/null && ok "NAS backup share unmounted after check"
fi

