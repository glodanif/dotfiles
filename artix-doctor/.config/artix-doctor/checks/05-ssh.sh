section "SSH"

[[ -f ~/.ssh/id_ed25519_glodanif ]] && ok "personal SSH key present" || err "personal SSH key missing"

if [[ -n "${WORK_SSH_KEY:-}" ]]; then
    [[ -f "$WORK_SSH_KEY" ]] && ok "work SSH key present" || err "work SSH key missing"
else
    warn "WORK_SSH_KEY not set in local.conf"
fi

[[ -f ~/.ssh/authorized_keys ]] && ok "authorized_keys present" || warn "authorized_keys missing (MacBook login will use password)"

sshd_conf="/etc/ssh/sshd_config"
if [[ -f "$sshd_conf" ]]; then
    grep -qE "^\s*PasswordAuthentication\s+no" "$sshd_conf" \
        && ok "PasswordAuthentication disabled" \
        || warn "PasswordAuthentication not explicitly set to no"
    grep -qE "^\s*PermitRootLogin\s+no" "$sshd_conf" \
        && ok "PermitRootLogin disabled" \
        || warn "PermitRootLogin not explicitly set to no"
fi

# SSH agent (gcr-ssh-agent + gnome-keyring)
pgrep -f gcr-ssh-agent &>/dev/null \
    && ok "gcr-ssh-agent running" \
    || err "gcr-ssh-agent not running (add to hypr/autostart.conf)"

[[ "$SSH_AUTH_SOCK" == */gcr/ssh ]] \
    && ok "SSH_AUTH_SOCK points to gcr socket" \
    || err "SSH_AUTH_SOCK not pointing to gcr socket (check hypr/environment.conf)"

grep -q "AddKeysToAgent yes" ~/.ssh/config 2>/dev/null \
    && ok "AddKeysToAgent enabled in ~/.ssh/config" \
    || err "AddKeysToAgent yes missing from ~/.ssh/config"

grep -q "Include.*config.local" ~/.ssh/config 2>/dev/null \
    && ok "~/.ssh/config includes config.local" \
    || err "config.local not included in ~/.ssh/config"

[[ -f ~/.ssh/config.local ]] \
    && ok "~/.ssh/config.local present (work SSH config)" \
    || err "~/.ssh/config.local missing (create from SSH key archive backup)"

grep -q "pam_gnome_keyring" /etc/pam.d/login 2>/dev/null \
    && ok "gnome-keyring PAM integration present" \
    || err "gnome-keyring PAM entries missing from /etc/pam.d/login"

git config --global user.name &>/dev/null && ok "git user.name configured" || warn "git user.name not set"
git config --global user.email &>/dev/null && ok "git user.email configured" || warn "git user.email not set"
