section "Download Cookies"

COOKIE_DIR="$HOME/.local/share/cookies"
JAR="$COOKIE_DIR/cookies.txt"
PATREON_HEADER="$COOKIE_DIR/patreon-cookie.txt"
BRAVE_PROFILE="$HOME/.config/BraveSoftware/Brave-Origin/Default"
COOKIE_NAS="${COOKIE_NAS:-void.local}"
STALE_HOURS=8   # cron runs every 4h, so 8h means two runs in a row failed

# ── tooling ──────────────────────────────────────────────
command -v yt-dlp &>/dev/null && ok "yt-dlp installed (decrypts Brave's cookie DB)" \
    || err "yt-dlp not installed" "Install:" "sudo pacman -S yt-dlp"

if [[ -L ~/.local/bin/cookie-sync || -f ~/.local/bin/cookie-sync ]]; then
    ok "cookie-sync script available"
else
    err "cookie-sync script missing (~/.local/bin/cookie-sync)" "Re-stow the packages:" "cd ~/dotfiles && ./refresh.sh"
fi

[[ -d "$BRAVE_PROFILE" ]] && ok "Brave profile present" \
    || err "Brave profile not found at $BRAVE_PROFILE" "Fix BRAVE_PROFILE in ~/.local/bin/cookie-sync"

# ── keyring holds the decryption key ─────────────────────
# Never print the secret — just confirm the entry resolves.
if command -v secret-tool &>/dev/null; then
    if secret-tool lookup application brave &>/dev/null; then
        ok "Brave Safe Storage key readable from keyring"
    else
        warn "Brave Safe Storage key not readable — cookie export will fail" "Unlock the keyring (log in to the desktop session), then:" "cookie-sync"
    fi
else
    warn "secret-tool not installed — cannot verify keyring access" "Install:" "sudo pacman -S libsecret"
fi

# ── scheduled refresh ────────────────────────────────────
if crontab -l 2>/dev/null | grep -q "cookie-sync"; then
    ok "cookie-sync scheduled in crontab"
else
    warn "cookie-sync not in crontab — cookies will go stale" "Add an entry:" "crontab -e   # 0 */4 * * * cookie-sync --quiet"
fi

# ── local jar ────────────────────────────────────────────
if [[ -s "$JAR" ]]; then
    age_h=$(( ( $(date +%s) - $(stat -c %Y "$JAR") ) / 3600 ))
    n=$(grep -cvE '^# ' "$JAR" 2>/dev/null || echo 0)
    if (( age_h > STALE_HOURS )); then
        warn "local cookie jar is ${age_h}h old ($n cookies)" "Refresh it:" "cookie-sync"
    else
        ok "local cookie jar fresh (${age_h}h old, $n cookies)"
    fi

    perms=$(stat -c %a "$JAR")
    [[ "$perms" == "600" ]] && ok "cookie jar permissions 0600" \
        || warn "cookie jar is mode $perms — it holds live sessions" "Tighten it:" "chmod 600 $JAR"
else
    err "no cookie jar at $JAR" "Generate it:" "cookie-sync"
fi

# ── patreon header ───────────────────────────────────────
if [[ -s "$PATREON_HEADER" ]]; then
    # Anchored so analytics_session_id can't pass for session_id.
    if grep -qE '(^|; )session_id=' "$PATREON_HEADER"; then
        ok "Patreon session_id present"
    else
        warn "Patreon cookie has no session_id — patron-only content will fail" "Log in to Patreon in Brave, then:" "cookie-sync"
    fi
else
    warn "no Patreon cookie header at $PATREON_HEADER" "Generate it:" "cookie-sync"
fi

# ── NAS copy ─────────────────────────────────────────────
if remote_ts=$(ssh -o BatchMode=yes -o ConnectTimeout=5 "$COOKIE_NAS" \
        "stat -c %Y .local/share/cookies/cookies.txt" 2>/dev/null); then
    remote_age_h=$(( ( $(date +%s) - remote_ts ) / 3600 ))
    if (( remote_age_h > STALE_HOURS )); then
        warn "$COOKIE_NAS jar is ${remote_age_h}h old" "Push a fresh copy:" "cookie-sync"
    else
        ok "$COOKIE_NAS jar in sync (${remote_age_h}h old)"
    fi
else
    warn "cannot read the cookie jar on $COOKIE_NAS (host down, or never pushed)" "Push one:" "cookie-sync"
fi
