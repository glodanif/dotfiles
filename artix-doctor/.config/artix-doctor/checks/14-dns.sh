section "Encrypted DNS"
command -v dnscrypt-proxy &>/dev/null && ok "dnscrypt-proxy installed" || err "dnscrypt-proxy not installed"
if rc-service dnscrypt-proxy status &>/dev/null; then
    ok "dnscrypt-proxy service running"
else
    err "dnscrypt-proxy service not running"
fi
if rc-update show default | grep -q dnscrypt-proxy; then
    ok "dnscrypt-proxy enabled at boot"
else
    warn "dnscrypt-proxy not in default runlevel"
fi
if grep -q "^nameserver 127.0.0.1" /etc/resolv.conf; then
    ok "resolv.conf points to localhost"
else
    err "resolv.conf not pointing to 127.0.0.1"
fi
if [[ -f /etc/NetworkManager/conf.d/dns.conf ]] && grep -q "dns=none" /etc/NetworkManager/conf.d/dns.conf; then
    ok "NetworkManager DNS override disabled"
else
    warn "NetworkManager may overwrite resolv.conf"
fi
if getcap "$(which dnscrypt-proxy)" 2>/dev/null | grep -q cap_net_bind_service; then
    ok "dnscrypt-proxy has cap_net_bind_service"
else
    err "dnscrypt-proxy missing setcap (run setcap after updates)"
fi
if [[ -f /etc/pacman.d/hooks/dnscrypt-proxy-setcap.hook ]]; then
    ok "pacman hook for setcap exists"
else
    warn "pacman hook for auto-setcap missing"
fi
if getent hosts example.com &>/dev/null; then
    ok "DNS resolution working"
else
    err "DNS resolution failing"
fi

