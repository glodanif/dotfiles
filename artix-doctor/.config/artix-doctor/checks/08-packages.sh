section "Packages"

command -v yay &>/dev/null && ok "yay installed (AUR helper)" || err "yay not installed" "Build from the AUR:" "git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"

if grep -q "^ParallelDownloads" /etc/pacman.conf; then
    ok "pacman ParallelDownloads enabled"
else
    warn "pacman ParallelDownloads not set" "Uncomment/add in /etc/pacman.conf:" "ParallelDownloads = 5"
fi

if grep -qE "^\[multilib\]" /etc/pacman.conf; then
    ok "multilib repo enabled"
else
    warn "multilib repo not enabled" "Uncomment the [multilib] section in /etc/pacman.conf, then:" "sudo pacman -Sy"
fi

for repo in system world galaxy; do
    if grep -qE "^\[$repo\]" /etc/pacman.conf; then
        ok "Artix repo enabled: $repo"
    else
        err "Artix repo missing: $repo" "Add the [$repo] repo section to /etc/pacman.conf."
    fi
done

if grep -qE "^\[extra\]" /etc/pacman.conf; then
    ok "Arch [extra] repo enabled"
else
    warn "Arch [extra] not enabled" "Enable Arch repos:" "sudo pacman -S artix-archlinux-support"
fi

if grep -qE "^\[lib32\]" /etc/pacman.conf; then
    if (( $(grep -nE "^\[lib32\]" /etc/pacman.conf | cut -d: -f1) < \
          $(grep -nE "^\[multilib\]" /etc/pacman.conf | cut -d: -f1 || echo 99999) )); then
        ok "Artix [lib32] enabled and ahead of [multilib]"
    else
        warn "Artix [lib32] is after [multilib]" \
             "Move the [lib32] section above [multilib] so Artix takes precedence."
    fi
else
    warn "Artix [lib32] not enabled" \
         "Enable it ahead of [multilib] for soname-stable 32-bit libs:" \
         "Add [lib32] Include = /etc/pacman.d/mirrorlist before [multilib]"
fi

