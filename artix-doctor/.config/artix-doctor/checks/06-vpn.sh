section "VPN"

command -v wg-quick &>/dev/null && ok "wg-quick installed" || err "wg-quick not installed" "Install:" "sudo pacman -S wireguard-tools"

if ls ~/.config/wireguard/*.conf &>/dev/null; then
    ok "wireguard config(s) present"
else
    warn "no wireguard .conf files in ~/.config/wireguard" "Place your provider's .conf files in ~/.config/wireguard/."
fi
