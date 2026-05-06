section "Hardware"

if lsmod | grep -q "^nvidia"; then
    ok "NVIDIA modules loaded"
else
    err "NVIDIA modules not loaded"
fi
if pacman -Qi android-udev &>/dev/null; then
    ok "android-udev package installed"
else
    warn "android-udev package not installed"
fi
if groups | grep -q adbusers; then
    ok "user in adbusers group"
else
    warn "user not in adbusers group"
fi

