section "Services"

required=(NetworkManager elogind dbus greetd)
optional=(bluetoothd iwd netmount sshd cronie earlyoom)

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

# earlyoom is only useful if it's actually running AND has its --avoid guard.
# Both halves have failed here before: the regex needs single quotes because
# supervise-daemon evals the assembled command line (unquoted ( ) | are shell
# syntax and the service refuses to start), while a wrongly-quoted regex would
# start fine and match nothing — leaving Hyprland killable, which loses every
# window at once and is worse than the OOM earlyoom was installed to prevent.
if rc-update show default 2>/dev/null | grep -qE '^\s*earlyoom\s'; then
    if ! pgrep -x earlyoom &>/dev/null; then
        err "earlyoom enabled but not running — likely a quoting error in EARLYOOM_ARGS" "Restart it and read the error:" "sudo rc-service earlyoom restart"
    elif pgrep -a earlyoom | grep -q -- '--avoid'; then
        ok "earlyoom running with --avoid guard"
    else
        warn "earlyoom running without --avoid — an OOM kill could take Hyprland and the whole session" "Set in /etc/conf.d/earlyoom:" "EARLYOOM_ARGS=\"--avoid '^(Hyprland|sshd)\$'\""
    fi
fi

greetd_conf_path="/home/glodanif/.config/greetd/config.toml"
if [[ -f /etc/conf.d/greetd ]] && grep -q "$greetd_conf_path" /etc/conf.d/greetd; then
    ok "/etc/conf.d/greetd points to config"
else
    err "/etc/conf.d/greetd not configured" "Add to /etc/conf.d/greetd:" "command_args=\"--config $greetd_conf_path\""
fi
