section "Hardware"

if lsmod | grep -q "^nvidia"; then
    ok "NVIDIA modules loaded"
else
    err "NVIDIA modules not loaded" "Install the driver and reboot:" "sudo pacman -S nvidia-dkms"
fi
if pacman -Qi android-udev &>/dev/null; then
    ok "android-udev package installed"
else
    warn "android-udev package not installed" "Install:" "sudo pacman -S android-udev"
fi
if groups | grep -q adbusers; then
    ok "user in adbusers group"
else
    warn "user not in adbusers group" "Add yourself (re-login afterwards):" "sudo usermod -aG adbusers \$USER"
fi
if modinfo cdc_acm &>/dev/null; then
    ok "cdc_acm module available (ESP32-C6 USB Serial/JTAG)"
else
    warn "cdc_acm module not available (required for ESP32-C6 USB connection)" "Ships with the linux kernel — reinstall/update it:" "sudo pacman -S linux"
fi
if groups | grep -qE "uucp|dialout"; then
    ok "user in serial port group (ESP32-C6 access)"
elif grep -r 'idVendor.*303a' /etc/udev/rules.d/ /usr/lib/udev/rules.d/ 2>/dev/null | grep -q 'MODE.*0666'; then
    ok "ESP32-C6 udev rule grants world access (303a)"
else
    warn "no ESP32-C6 serial access: not in uucp/dialout and no udev rule for vendor 303a" "Add yourself to the serial group (re-login afterwards):" "sudo usermod -aG uucp \$USER"
fi

