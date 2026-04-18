section "Services"

required=(NetworkManager elogind dbus)
optional=(bluetoothd iwd netmount)

for svc in "${required[@]}"; do
    if rc-update show default 2>/dev/null | grep -qE "^\s*$svc\s"; then
        ok "$svc enabled in default runlevel"
    else
        err "$svc NOT enabled"
    fi
done

for svc in "${optional[@]}"; do
    if rc-update show default 2>/dev/null | grep -qE "^\s*$svc\s"; then
        ok "$svc enabled"
    else
        warn "$svc not enabled"
    fi
done
