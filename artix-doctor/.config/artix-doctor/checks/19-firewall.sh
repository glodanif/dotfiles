section "Firewall"

command -v nft &>/dev/null && ok "nftables installed" || err "nftables not installed" "Install:" "sudo pacman -S nftables"

[[ -f /etc/nftables.conf ]] && ok "/etc/nftables.conf present" || err "/etc/nftables.conf missing — nothing for the boot hook to load" "Write a ruleset there, then:" "sudo nft -f /etc/nftables.conf"

# Artix ships no nftables OpenRC service (only iptables-openrc lives in the
# repos), so the ruleset is loaded from local.d, which is already in the
# default runlevel. Without this hook the rules still work until reboot and
# then silently vanish — the machine comes up wide open with no symptom.
hook=/etc/local.d/nftables.start
if [[ -x "$hook" ]]; then
    ok "nftables boot hook present and executable"
elif [[ -f "$hook" ]]; then
    err "$hook is not executable — local.d will skip it and the firewall won't load at boot" "Fix:" "sudo chmod +x $hook"
else
    err "no nftables boot hook — the ruleset will not survive a reboot" "Create $hook containing 'exec /usr/bin/nft -f /etc/nftables.conf', then:" "sudo chmod +x $hook"
fi

# Reading the live ruleset needs root. Distinguish "no sudo ticket" (warn, the
# check simply couldn't look) from "sudo works and there are no drop-policy
# rules" (err, the firewall is genuinely not up).
if sudo -n true 2>/dev/null; then
    if sudo -n nft list chain inet filter input 2>/dev/null | grep -q 'policy drop'; then
        ok "firewall active (input policy drop)"
    else
        err "no active inbound firewall — every listening port is reachable from the LAN" "Load the ruleset:" "sudo nft -f /etc/nftables.conf"
    fi
else
    warn "cannot read the live ruleset without a sudo ticket" "Verify by hand:" "sudo nft list ruleset"
fi
