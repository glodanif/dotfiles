section "Backup"

# ── restic + backup script ───────────────────────────────
command -v restic &>/dev/null && ok "restic installed" || err "restic not installed" "Install:" "sudo xbps-install -S restic"

if [[ -L ~/.local/bin/sys-backup || -f ~/.local/bin/sys-backup ]]; then
    ok "sys-backup script available"
else
    err "sys-backup script missing (~/.local/bin/sys-backup)" "Re-stow the packages:" "cd ~/dotfiles && ./refresh.sh"
fi

# ── repo password (backup runs as root) ──────────────────
PASSWORD_FILE="/root/.restic-password"
if sudo -n test -r "$PASSWORD_FILE" 2>/dev/null; then
    ok "restic password file present ($PASSWORD_FILE)"
else
    warn "cannot verify $PASSWORD_FILE (required for backup)" "Create it as root:" "sudo sh -c 'printf %s YOUR_PASSWORD > /root/.restic-password'"
fi

# ── local repo on the backup drive ───────────────────────
BACKUP_DRIVE="/mnt/nvme-3"
REPO="$BACKUP_DRIVE/void-backup"
if mountpoint -q "$BACKUP_DRIVE" 2>/dev/null; then
    ok "backup drive mounted ($BACKUP_DRIVE)"
    if sudo restic --repo "$REPO" --password-file "$PASSWORD_FILE" snapshots &>/dev/null; then
        latest=$(sudo restic --repo "$REPO" --password-file "$PASSWORD_FILE" snapshots --last 2>/dev/null \
            | grep -oP '\d{4}-\d{2}-\d{2}' | tail -1)
        ok "restic repo accessible, latest snapshot: ${latest:-unknown}"

        # The B2 mirror tracks the local repo 1:1, so guard against the 10 GB
        # free tier by watching the local repo size (no network call needed).
        WARN_BYTES=8000000000   # 8 GB — headroom to trim before B2's 10 GB cap
        repo_bytes=$(sudo du -sb "$REPO" 2>/dev/null | cut -f1)
        if [[ -n "$repo_bytes" ]]; then
            repo_h=$(numfmt --to=si --suffix=B "$repo_bytes" 2>/dev/null || echo "${repo_bytes} bytes")
            if (( repo_bytes >= WARN_BYTES )); then
                warn "backup repo at $repo_h — nearing B2 10 GB free tier" "Tighten keep-* retention in sys-backup, exclude more, or upsize the B2 bucket"
            else
                ok "backup repo size $repo_h (< 8 GB B2 threshold)"
            fi
        fi
    else
        warn "restic repo not initialized or inaccessible at $REPO" "Initialize the repo:" "sudo restic --repo $REPO --password-file $PASSWORD_FILE init"
    fi
else
    err "backup drive not mounted ($BACKUP_DRIVE)" "Mount it:" "sudo mount $BACKUP_DRIVE"
fi

# ── Forgejo (repos captured via `forgejo dump`) ──────────
command -v forgejo &>/dev/null && ok "forgejo installed (repos included via dump)" || warn "forgejo not found — Forgejo dump step will be skipped"

# ── scheduled run (snooze runit service) ─────────────────
if [[ -L /var/service/void-backup ]]; then
    if sudo sv status void-backup 2>/dev/null | grep -q "^run:"; then
        ok "void-backup snooze service enabled and supervised"
    else
        warn "void-backup service enabled but not supervised" "Inspect it:" "sudo sv status void-backup"
    fi
else
    warn "void-backup snooze service not enabled" "Enable it:" "sudo ln -s /etc/sv/void-backup /var/service/"
fi

# ── off-site mirror (Backblaze B2 via rclone) ────────────
# The backup runs as root, so the rclone 'b2' remote must live in root's config.
if command -v rclone &>/dev/null; then
    if sudo rclone listremotes 2>/dev/null | grep -qx "b2:"; then
        ok "rclone B2 remote 'b2' configured (root)"
    else
        warn "rclone 'b2' remote missing from root config" "Configure it as root:" "sudo rclone config"
    fi
else
    warn "rclone not installed — B2 mirror disabled" "Install:" "sudo xbps-install -S rclone"
fi
