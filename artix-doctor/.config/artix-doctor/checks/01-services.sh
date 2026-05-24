section "Services"

required=(NetworkManager elogind dbus greetd)
optional=(bluetoothd iwd netmount sshd cronie)

for svc in "${required[@]}"; do
    if rc-update show default 2>/dev/null | grep -qE "^\s*$svc\s"; then
        ok "$svc enabled in default runlevel"
    else
        err "$svc NOT enabled" "Enable and start it:" "sudo rc-update add $svc default && sudo rc-service $svc start"
    fi
done

for svc in "${optional[@]}"; do
    if rc-update show default 2>/dev/null | grep -qE "^\s*$svc\s"; then
        ok "$svc enabled"
    else
        warn "$svc not enabled" "Enable and start it:" "sudo rc-update add $svc default && sudo rc-service $svc start"
    fi
done

greetd_conf_path="/home/glodanif/.config/greetd/config.toml"
if [[ -f /etc/conf.d/greetd ]] && grep -q "$greetd_conf_path" /etc/conf.d/greetd; then
    ok "/etc/conf.d/greetd points to config"
else
    err "/etc/conf.d/greetd not configured" "Add to /etc/conf.d/greetd:" "command_args=\"--config $greetd_conf_path\""
fi
