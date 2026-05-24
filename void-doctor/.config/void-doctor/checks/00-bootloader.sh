section "Bootloader"

command -v grub-install &>/dev/null && ok "grub-install in PATH" || err "grub-install not installed" "Install:" "sudo xbps-install -S grub"
command -v grub-mkconfig &>/dev/null && ok "grub-mkconfig in PATH" || warn "grub-mkconfig not found" "Install:" "sudo xbps-install -S grub"

[[ -f /boot/grub/grub.cfg ]] && ok "grub.cfg present" || err "grub.cfg missing at /boot/grub/grub.cfg" "Regenerate it:" "sudo grub-mkconfig -o /boot/grub/grub.cfg"

efi_dir=""
[[ -d /boot/EFI ]] && efi_dir="/boot/EFI"
[[ -d /boot/efi ]] && efi_dir="/boot/efi"

if [[ -n "$efi_dir" ]]; then
    ok "EFI boot directory present ($efi_dir)"
    if find "$efi_dir" \( -name "grubx64.efi" -o -name "BOOTX64.EFI" \) 2>/dev/null | grep -q .; then
        ok "GRUB EFI binary present"
    else
        warn "GRUB EFI binary not found in $efi_dir" "Reinstall GRUB to the ESP:" "sudo grub-install --target=x86_64-efi --efi-directory=$efi_dir"
    fi
else
    warn "No EFI boot directory found (BIOS mode?)" "Normal on legacy BIOS systems — ignore if this server boots in BIOS mode."
fi

kernel_count=$(ls /boot/vmlinuz* 2>/dev/null | wc -l)
if (( kernel_count > 0 )); then
    ok "$kernel_count kernel image(s) in /boot"
else
    err "no kernel images found in /boot" "Reinstall the kernel:" "sudo xbps-install -S linux"
fi
