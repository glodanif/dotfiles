section "Bootloader"

command -v limine &>/dev/null && ok "limine binary in PATH" || err "limine not installed"

[[ -f /boot/limine.conf ]] && ok "limine.conf present" || err "limine.conf missing at /boot"

[[ -f /boot/EFI/limine/limine_x64.efi ]] && ok "limine EFI binary present" || err "limine EFI binary missing"

required_hooks=(base udev block encrypt filesystems keyboard keymap)
optional_hooks=(autodetect microcode modconf kms consolefont fsck)

if [[ -f /etc/mkinitcpio.conf ]]; then
    hooks_line=$(grep -E '^HOOKS=' /etc/mkinitcpio.conf)
    for hook in "${required_hooks[@]}"; do
        if echo "$hooks_line" | grep -qE "\b$hook\b"; then
            ok "mkinitcpio hook: $hook"
        else
            err "mkinitcpio hook missing: $hook"
        fi
    done
    for hook in "${optional_hooks[@]}"; do
        if echo "$hooks_line" | grep -qE "\b$hook\b"; then
            ok "mkinitcpio hook: $hook"
        else
            warn "mkinitcpio hook missing: $hook (recommended)"
        fi
    done
else
    err "/etc/mkinitcpio.conf not found"
fi
