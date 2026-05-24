section "Services"

sv_enabled() { [[ -L "/var/service/$1" ]]; }
sv_running() { sv status "$1" 2>/dev/null | grep -q "^run:" || pgrep -f "$1" &>/dev/null; }

required=(sshd smbd nmbd)
optional=(transmission-daemon avahi-daemon chronyd)

for svc in "${required[@]}"; do
    if sv_enabled "$svc"; then
        if sv_running "$svc"; then
            ok "$svc enabled and running"
        else
            err "$svc enabled but not running" "Start it:" "sudo sv up $svc"
        fi
    else
        err "$svc not enabled in /var/service" "Enable it:" "sudo ln -s /etc/sv/$svc /var/service/"
    fi
done

for svc in "${optional[@]}"; do
    if sv_enabled "$svc"; then
        if sv_running "$svc"; then
            ok "$svc enabled and running"
        else
            warn "$svc enabled but not running" "Start it:" "sudo sv up $svc"
        fi
    else
        warn "$svc not enabled" "Enable it:" "sudo ln -s /etc/sv/$svc /var/service/"
    fi
done
