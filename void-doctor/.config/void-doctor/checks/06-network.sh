section "Network"

hostname=$(hostname 2>/dev/null)
if [[ -n "$hostname" && "$hostname" != "localhost" ]]; then
    ok "hostname set: $hostname"
else
    warn "hostname is not set or is 'localhost'" "Set it:" "echo <name> | sudo tee /etc/hostname"
fi

if ip link show 2>/dev/null | grep -q "state UP"; then
    ok "at least one network interface is UP"
else
    err "no network interfaces appear to be UP" "Check cabling and bring an interface up (dhcpcd/NetworkManager):" "ip link"
fi

if getent hosts one.one.one.one &>/dev/null; then
    ok "DNS resolution working"
else
    err "DNS resolution failing" "Check /etc/resolv.conf and upstream connectivity."
fi

if sv status avahi-daemon 2>/dev/null | grep -q "^run:" || pgrep -f avahi-daemon &>/dev/null; then
    ok "avahi-daemon running (mDNS active)"
else
    warn "avahi-daemon not running (local .local hostname resolution unavailable)" "Enable it:" "sudo ln -s /etc/sv/avahi-daemon /var/service/"
fi
