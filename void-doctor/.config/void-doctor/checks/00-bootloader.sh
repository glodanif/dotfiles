section "Bootloader"

command -v grub-install &>/dev/null && ok "grub-install in PATH" || err "grub-install not installed"
command -v grub-mkconfig &>/dev/null && ok "grub-mkconfig in PATH" || warn "grub-mkconfig not found"

[[ -f /boot/grub/grub.cfg ]] && ok "grub.cfg present" || err "grub.cfg missing at /boot/grub/grub.cfg"

if [[ -d /boot/EFI ]] || [[ -d /boot/efi ]]; then
    ok "EFI boot directory present"
    if ls /boot/EFI/*/grubx64.efi /boot/EFI/BOOT/BOOTX64.EFI &>/dev/null 2>&1; then
        ok "GRUB EFI binary present"
    else
        warn "GRUB EFI binary not found in expected locations"
    fi
else
    warn "No /boot/EFI directory found (BIOS mode?)"
fi

kernel_count=$(ls /boot/vmlinuz* 2>/dev/null | wc -l)
if (( kernel_count > 0 )); then
    ok "$kernel_count kernel image(s) in /boot"
else
    err "no kernel images found in /boot"
fi
