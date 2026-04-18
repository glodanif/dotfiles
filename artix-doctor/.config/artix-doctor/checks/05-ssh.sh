section "SSH"

[[ -f ~/.ssh/id_ed25519_glodanif ]] && ok "personal SSH key present" || err "personal SSH key missing"

if [[ -n "${WORK_SSH_KEY:-}" ]]; then
    [[ -f "$WORK_SSH_KEY" ]] && ok "work SSH key present" || err "work SSH key missing"
else
    warn "WORK_SSH_KEY not set in local.conf"
fi

git config --global user.name &>/dev/null && ok "git user.name configured" || warn "git user.name not set"
git config --global user.email &>/dev/null && ok "git user.email configured" || warn "git user.email not set"
