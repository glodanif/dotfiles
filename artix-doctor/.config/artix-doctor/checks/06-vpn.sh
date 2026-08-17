section "VPN"

command -v wg-quick &>/dev/null && ok "wg-quick installed" || err "wg-quick not installed" "Install:" "sudo pacman -S wireguard-tools"

if ls ~/.config/wireguard/*.conf &>/dev/null; then
    ok "wireguard config(s) present"
else
    warn "no wireguard .conf files in ~/.config/wireguard" "Place your provider's .conf files in ~/.config/wireguard/."
fi

# Every config regenerated from the provider ships a `DNS =` line. It makes
# wg-quick call resolvconf, which fails against the immutable /etc/resolv.conf,
# and wg-quick then tears the interface back down. Nothing about the symptom
# points at DNS — vpn-run used to report it as stale keys. Worth re-checking
# after every config download, which is exactly what this is for.
if sudo -n true 2>/dev/null; then
    if sudo -n grep -lE '^[[:space:]]*DNS[[:space:]]*=' ~/.config/wireguard/*.conf 2>/dev/null | grep -q .; then
        err "a wireguard config has an active DNS= line — wg-quick will fail against the immutable resolv.conf" "Comment it out:" "sudo sed -i 's/^DNS/#DNS/' ~/.config/wireguard/*.conf"
    else
        ok "no active DNS= line in wireguard configs"
    fi
else
    warn "cannot read wireguard configs without a sudo ticket" "Check by hand:" "sudo grep -n '^DNS' ~/.config/wireguard/*.conf"
fi
