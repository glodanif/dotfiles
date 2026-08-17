section "Bootloader"

command -v limine &>/dev/null && ok "limine binary in PATH" || err "limine not installed" "Install:" "sudo pacman -S limine"

[[ -f /boot/limine.conf ]] && ok "limine.conf present" || err "limine.conf missing at /boot" "Restore /boot/limine.conf from backup or regenerate it (limine-mkinitcpio hook)."

[[ -f /boot/EFI/limine/limine_x64.efi ]] && ok "limine EFI binary present" || err "limine EFI binary missing" "Copy it to the ESP:" "sudo cp /usr/share/limine/limine_x64.efi /boot/EFI/limine/"

required_hooks=(base udev plymouth block encrypt lvm2 filesystems keyboard keymap)
optional_hooks=(autodetect microcode modconf kms consolefont fsck)

if [[ -f /etc/mkinitcpio.conf ]]; then
    hooks_line=$(grep -E '^HOOKS=' /etc/mkinitcpio.conf)
    for hook in "${required_hooks[@]}"; do
        if echo "$hooks_line" | grep -qE "\b$hook\b"; then
            ok "mkinitcpio hook: $hook"
        else
            err "mkinitcpio hook missing: $hook" "Add '$hook' to HOOKS in /etc/mkinitcpio.conf, then rebuild:" "sudo mkinitcpio -P"
        fi
    done
    for hook in "${optional_hooks[@]}"; do
        if echo "$hooks_line" | grep -qE "\b$hook\b"; then
            ok "mkinitcpio hook: $hook"
        else
            warn "mkinitcpio hook missing: $hook (recommended)" "Add '$hook' to HOOKS in /etc/mkinitcpio.conf, then rebuild:" "sudo mkinitcpio -P"
        fi
    done
else
    err "/etc/mkinitcpio.conf not found" "Reinstall mkinitcpio:" "sudo pacman -S mkinitcpio"
fi

preset=/etc/mkinitcpio.d/linux.preset
fallback_img=/boot/initramfs-linux-fallback.img

if [[ -f "$preset" ]]; then
    # PRESETS alone isn't enough — fallback_image must be uncommented or the
    # preset builds nothing and only warns.
    grep -qE "^PRESETS=.*'fallback'" "$preset" \
        && ok "mkinitcpio fallback preset enabled" \
        || err "mkinitcpio fallback preset disabled — no rescue initramfs will be built" "Set PRESETS=('default' 'fallback') in $preset, then:" "sudo mkinitcpio -P"

    grep -qE '^fallback_image=' "$preset" \
        && ok "mkinitcpio fallback_image set" \
        || err "fallback_image commented out — fallback preset builds no image" "Uncomment fallback_image and fallback_options in $preset, then:" "sudo mkinitcpio -P"
else
    err "$preset not found" "Reinstall the kernel package:" "sudo pacman -S linux"
fi

if [[ -f "$fallback_img" ]]; then
    ok "fallback initramfs present ($(du -h "$fallback_img" | cut -f1))"
    if [[ "$fallback_img" -ot /boot/vmlinuz-linux ]]; then
        err "fallback initramfs older than the kernel — it won't boot this kernel" "Rebuild it:" "sudo mkinitcpio -P"
    else
        ok "fallback initramfs newer than kernel"
    fi
else
    err "fallback initramfs missing — no rescue entry to boot from" "Build it:" "sudo mkinitcpio -P"
fi

if [[ -f /boot/limine.conf ]]; then
    grep -qF 'initramfs-linux-fallback.img' /boot/limine.conf \
        && ok "limine fallback boot entry present" \
        || err "fallback initramfs has no limine entry — unreachable at boot" "Add an '/Artix Linux (fallback)' entry to /boot/limine.conf with module_path: boot():/initramfs-linux-fallback.img"
fi

if [[ -f /boot/limine.conf ]]; then
    # -m1: first cmdline only (the default entry). Later entries are rescue
    # entries that deliberately drop quiet/splash.
    cmdline=$(grep -m1 -E '^\s+cmdline:' /boot/limine.conf)
    echo "$cmdline" | grep -q 'quiet' && ok "limine cmdline: quiet" || warn "limine cmdline: quiet missing (plymouth won't suppress logs)" "Add 'quiet' to the cmdline: line in /boot/limine.conf."
    echo "$cmdline" | grep -q 'splash' && ok "limine cmdline: splash" || warn "limine cmdline: splash missing (plymouth won't activate)" "Add 'splash' to the cmdline: line in /boot/limine.conf."
fi

plymouth_theme=$(plymouth-set-default-theme 2>/dev/null)
if [[ -n "$plymouth_theme" && "$plymouth_theme" != "text" ]]; then
    ok "plymouth theme: $plymouth_theme"
else
    warn "plymouth theme not set or using fallback 'text'" "Set a theme and rebuild initramfs:" "sudo plymouth-set-default-theme -R <theme>"
fi

if [[ -f /etc/local.d/plymouth-quit.start && -x /etc/local.d/plymouth-quit.start ]]; then
    ok "plymouth-quit.start present and executable"
else
    err "plymouth-quit.start missing — plymouth won't quit after boot" "Create it:" "sudo sh -c 'printf \"#!/bin/sh\nplymouth quit --wait\n\" > /etc/local.d/plymouth-quit.start && chmod +x /etc/local.d/plymouth-quit.start'"
fi
