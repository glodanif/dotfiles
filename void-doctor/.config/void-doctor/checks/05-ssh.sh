section "SSH"

if ls ~/.ssh/id_* 2>/dev/null | grep -v "\.pub$" | grep -q .; then
    ok "SSH private key present in ~/.ssh/"
else
    err "no SSH private keys found in ~/.ssh/"
fi

[[ -f ~/.ssh/authorized_keys ]] && ok "authorized_keys present" || warn "authorized_keys missing (remote login may fail)"

sshd_conf="/etc/ssh/sshd_config"
if [[ -f "$sshd_conf" ]]; then
    grep -qE "^\s*PasswordAuthentication\s+no" "$sshd_conf" \
        && ok "PasswordAuthentication disabled" \
        || warn "PasswordAuthentication not explicitly set to no"
    grep -qE "^\s*PermitRootLogin\s+no" "$sshd_conf" \
        && ok "PermitRootLogin disabled" \
        || warn "PermitRootLogin not explicitly set to no"
else
    warn "/etc/ssh/sshd_config not found"
fi

git config --global user.name &>/dev/null && ok "git user.name configured" || warn "git user.name not set"
git config --global user.email &>/dev/null && ok "git user.email configured" || warn "git user.email not set"
