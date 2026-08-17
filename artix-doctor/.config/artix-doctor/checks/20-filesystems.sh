section "Filesystems"

# fstab and the live mount can disagree, and the failure is silent: an option
# added to fstab does nothing until a remount, and an option the kernel refused
# looks exactly like one that was never written down.
if grep -qE '^[^#].*btrfs.*compress=zstd' /etc/fstab 2>/dev/null; then
    if findmnt -no OPTIONS / | grep -q 'compress=zstd'; then
        ok "root mounted with compress=zstd"
    else
        warn "fstab declares compress=zstd but the live mount doesn't have it" "Apply it without rebooting:" "sudo mount -o remount /"
    fi
fi

# ntfs3 mounts a dirty NTFS volume READ-ONLY rather than failing, so "mounted"
# is not the same as "usable". Windows Fast Startup leaving the volume
# hibernated is the usual cause, and the only symptom is writes failing later.
if mountpoint -q /mnt/2t; then
    fstype=$(findmnt -no FSTYPE /mnt/2t)
    opts=$(findmnt -no OPTIONS /mnt/2t)

    if [[ "$fstype" == ntfs3 ]]; then
        ok "/mnt/2t on the in-kernel ntfs3 driver"
    else
        warn "/mnt/2t on '$fstype', not ntfs3 (FUSE ntfs-3g is slower)" "Set the fstab type to ntfs3, then:" "sudo umount /mnt/2t && sudo mount /mnt/2t"
    fi

    if [[ "$opts" == ro,* || "$opts" == *,ro,* || "$opts" == *,ro ]]; then
        err "/mnt/2t is mounted read-only — the NTFS volume is dirty" "Boot Windows once to clear it (disable Fast Startup), or mount with ntfs-3g and 'remove_hiberfile'."
    else
        ok "/mnt/2t mounted read-write"
    fi
else
    warn "/mnt/2t not mounted" "Mount it:" "sudo mount /mnt/2t"
fi
