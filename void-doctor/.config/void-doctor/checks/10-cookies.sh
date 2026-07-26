section "Download Cookies"

COOKIE_DIR="$HOME/.local/share/cookies"
JAR="$COOKIE_DIR/cookies.txt"
PATREON_HEADER="$COOKIE_DIR/patreon-cookie.txt"
STALE_HOURS=8   # the Artix box pushes every 4h; 8h means two runs in a row failed

# ── tooling ──────────────────────────────────────────────
command -v yt-dlp &>/dev/null && ok "yt-dlp installed" \
    || err "yt-dlp not installed" "Install:" "sudo xbps-install -S yt-dlp"

command -v ffmpeg &>/dev/null && ok "ffmpeg installed (muxing)" \
    || err "ffmpeg not installed" "Install:" "sudo xbps-install -S ffmpeg"

command -v node &>/dev/null && ok "nodejs installed (patreon-dl runtime)" \
    || err "nodejs not installed" "Install:" "sudo xbps-install -S nodejs"

command -v patreon-dl &>/dev/null && ok "patreon-dl installed" \
    || err "patreon-dl not installed" "Install it globally:" "sudo npm i -g patreon-dl"

if [[ -L ~/.local/bin/pdl || -f ~/.local/bin/pdl ]]; then
    ok "pdl wrapper available"
else
    err "pdl wrapper missing (~/.local/bin/pdl)" "Re-stow the packages:" "cd ~/dotfiles && ./refresh.sh"
fi

# ── synced jar (this host cannot regenerate it) ──────────
if [[ -s "$JAR" ]]; then
    age_h=$(( ( $(date +%s) - $(stat -c %Y "$JAR") ) / 3600 ))
    n=$(grep -cvE '^# ' "$JAR" 2>/dev/null || echo 0)
    if (( age_h > STALE_HOURS )); then
        warn "cookie jar is ${age_h}h old ($n cookies)" "Refresh from the Artix box:" "ssh artix-pc cookie-sync"
    else
        ok "cookie jar fresh (${age_h}h old, $n cookies)"
    fi

    perms=$(stat -c %a "$JAR")
    [[ "$perms" == "600" ]] && ok "cookie jar permissions 0600" \
        || warn "cookie jar is mode $perms — it holds live sessions" "Tighten it:" "chmod 600 $JAR"
else
    err "no cookie jar at $JAR" "Push one from the Artix box:" "cookie-sync"
fi

if [[ -s "$PATREON_HEADER" ]]; then
    # Anchored so analytics_session_id can't pass for session_id.
    if grep -qE '(^|; )session_id=' "$PATREON_HEADER"; then
        ok "Patreon session_id present"
    else
        warn "Patreon cookie has no session_id — patron-only content will fail" "Log in to Patreon in Brave, then re-run on the Artix box:" "cookie-sync"
    fi
else
    warn "no Patreon cookie header at $PATREON_HEADER" "Push one from the Artix box:" "cookie-sync"
fi

# ── download target ──────────────────────────────────────
DL_DIR="$HOME/downloads"
[[ -d "$DL_DIR" ]] && ok "download dir present ($DL_DIR)" \
    || warn "download dir missing ($DL_DIR)" "Create it:" "mkdir -p $DL_DIR"
