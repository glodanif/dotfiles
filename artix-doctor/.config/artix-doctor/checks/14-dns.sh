section "Encrypted DNS"
command -v dnscrypt-proxy &>/dev/null && ok "dnscrypt-proxy installed" || err "dnscrypt-proxy not installed" "Install:" "sudo pacman -S dnscrypt-proxy"
if rc-service dnscrypt-proxy status &>/dev/null; then
    ok "dnscrypt-proxy service running"
else
    err "dnscrypt-proxy service not running" "Start it:" "sudo rc-service dnscrypt-proxy start"
fi
if rc-update show default | grep -q dnscrypt-proxy; then
    ok "dnscrypt-proxy enabled at boot"
else
    warn "dnscrypt-proxy not in default runlevel" "Enable at boot:" "sudo rc-update add dnscrypt-proxy default"
fi
if grep -q "^nameserver 127.0.0.1" /etc/resolv.conf; then
    ok "resolv.conf points to localhost"
else
    err "resolv.conf not pointing to 127.0.0.1" "Point it at the local resolver:" "echo 'nameserver 127.0.0.1' | sudo tee /etc/resolv.conf"
fi
if [[ -f /etc/NetworkManager/conf.d/dns.conf ]] && grep -q "dns=none" /etc/NetworkManager/conf.d/dns.conf; then
    ok "NetworkManager DNS override disabled"
else
    warn "NetworkManager may overwrite resolv.conf" "Add 'dns=none' under [main] in /etc/NetworkManager/conf.d/dns.conf."
fi
if getcap "$(which dnscrypt-proxy)" 2>/dev/null | grep -q cap_net_bind_service; then
    ok "dnscrypt-proxy has cap_net_bind_service"
else
    err "dnscrypt-proxy missing setcap (run setcap after updates)" "Grant the capability:" "sudo setcap cap_net_bind_service=+ep \$(which dnscrypt-proxy)"
fi
if [[ -f /etc/pacman.d/hooks/dnscrypt-proxy-setcap.hook ]]; then
    ok "pacman hook for setcap exists"
else
    warn "pacman hook for auto-setcap missing" "Create /etc/pacman.d/hooks/dnscrypt-proxy-setcap.hook to re-apply setcap after upgrades."
fi
if getent hosts example.com &>/dev/null; then
    ok "DNS resolution working"
else
    err "DNS resolution failing" "Verify dnscrypt-proxy is running and resolv.conf points to 127.0.0.1."
fi

