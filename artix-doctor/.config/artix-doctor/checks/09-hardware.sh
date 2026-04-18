section "Hardware"

if lsmod | grep -q "^nvidia"; then
    ok "NVIDIA modules loaded"
else
    err "NVIDIA modules not loaded"
fi

[[ -f /etc/udev/rules.d/51-android.rules ]] \
    && ok "Android udev rule present" \
    || warn "Android udev rule missing"

if groups | grep -q plugdev; then
    ok "user in plugdev group"
else
    warn "user not in plugdev group"
fi
