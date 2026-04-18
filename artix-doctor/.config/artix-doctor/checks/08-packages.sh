section "Packages"

command -v yay &>/dev/null && ok "yay installed (AUR helper)" || err "yay not installed"

if grep -q "^ParallelDownloads" /etc/pacman.conf; then
    ok "pacman ParallelDownloads enabled"
else
    warn "pacman ParallelDownloads not set"
fi

if grep -qE "^\[multilib\]" /etc/pacman.conf; then
    ok "multilib repo enabled"
else
    warn "multilib repo not enabled"
fi

for repo in system world galaxy; do
    if grep -qE "^\[$repo\]" /etc/pacman.conf; then
        ok "Artix repo enabled: $repo"
    else
        err "Artix repo missing: $repo"
    fi
done

if grep -qE "^\[extra\]" /etc/pacman.conf; then
    ok "Arch [extra] repo enabled"
else
    warn "Arch [extra] not enabled"
fi
