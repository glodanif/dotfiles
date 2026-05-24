section "SSH"

[[ -f ~/.ssh/id_ed25519_glodanif ]] && ok "personal SSH key present" || err "personal SSH key missing" "Restore from backup, or generate:" "ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_glodanif"

if [[ -n "${WORK_SSH_KEY:-}" ]]; then
    [[ -f "$WORK_SSH_KEY" ]] && ok "work SSH key present" || err "work SSH key missing" "Restore the work key to the path set in WORK_SSH_KEY ($WORK_SSH_KEY)."
else
    warn "WORK_SSH_KEY not set in local.conf" "Set it in ~/.config/artix-doctor/local.conf:" "WORK_SSH_KEY=~/.ssh/<work-key>"
fi

[[ -f ~/.ssh/authorized_keys ]] && ok "authorized_keys present" || warn "authorized_keys missing (MacBook login will use password)" "Append the client's public key:" "ssh-copy-id -i <pubkey> glodanif@<host>"

sshd_conf="/etc/ssh/sshd_config"
if [[ -f "$sshd_conf" ]]; then
    grep -qE "^\s*PasswordAuthentication\s+no" "$sshd_conf" \
        && ok "PasswordAuthentication disabled" \
        || warn "PasswordAuthentication not explicitly set to no" "Add to /etc/ssh/sshd_config, then restart sshd:" "PasswordAuthentication no"
    grep -qE "^\s*PermitRootLogin\s+no" "$sshd_conf" \
        && ok "PermitRootLogin disabled" \
        || warn "PermitRootLogin not explicitly set to no" "Add to /etc/ssh/sshd_config, then restart sshd:" "PermitRootLogin no"
fi

# SSH agent (gcr-ssh-agent + gnome-keyring)
pgrep -f gcr-ssh-agent &>/dev/null \
    && ok "gcr-ssh-agent running" \
    || err "gcr-ssh-agent not running" "Add gcr-ssh-agent to ~/.config/hypr/autostart.conf and re-login."

[[ "$SSH_AUTH_SOCK" == */gcr/ssh ]] \
    && ok "SSH_AUTH_SOCK points to gcr socket" \
    || err "SSH_AUTH_SOCK not pointing to gcr socket" "Set in ~/.config/hypr/environment.conf:" "env = SSH_AUTH_SOCK,\$XDG_RUNTIME_DIR/gcr/ssh"

grep -q "AddKeysToAgent yes" ~/.ssh/config 2>/dev/null \
    && ok "AddKeysToAgent enabled in ~/.ssh/config" \
    || err "AddKeysToAgent yes missing from ~/.ssh/config" "Add to ~/.ssh/config:" "AddKeysToAgent yes"

grep -q "Include.*config.local" ~/.ssh/config 2>/dev/null \
    && ok "~/.ssh/config includes config.local" \
    || err "config.local not included in ~/.ssh/config" "Add to the top of ~/.ssh/config:" "Include ~/.ssh/config.local"

[[ -f ~/.ssh/config.local ]] \
    && ok "~/.ssh/config.local present (work SSH config)" \
    || err "~/.ssh/config.local missing" "Restore ~/.ssh/config.local from your SSH key archive backup."

git config --global user.name &>/dev/null && ok "git user.name configured" || warn "git user.name not set" "Set it:" 'git config --global user.name "Your Name"'
git config --global user.email &>/dev/null && ok "git user.email configured" || warn "git user.email not set" "Set it:" 'git config --global user.email "you@example.com"'
