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

# Two invariants that let this firewall coexist with libvirt and the VPN
# killswitch. Both are easy to reintroduce by editing the file, and neither
# failure is visible until a VM or the tunnel misbehaves much later.
if [[ -f /etc/nftables.conf ]]; then
    grep -qE '^\s*flush ruleset' /etc/nftables.conf \
        && err "/etc/nftables.conf calls 'flush ruleset' — at boot it deletes libvirt's and wg-quick's tables too" "Scope the reset instead: a 'table inet filter' line followed by 'delete table inet filter'." \
        || ok "nftables.conf resets only its own table"

    grep -qE 'hook forward' /etc/nftables.conf \
        && warn "/etc/nftables.conf defines a forward chain — with policy drop it blocks libvirt VM NAT regardless of libvirt's own rules" "Remove the forward chain unless this host actually routes traffic." \
        || ok "no forward chain (libvirt governs its own forwarding)"
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
