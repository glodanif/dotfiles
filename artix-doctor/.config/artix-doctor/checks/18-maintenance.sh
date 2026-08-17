section "Maintenance"

for tool in maintenance-watch sys-maintenance; do
    if [[ -x ~/.local/bin/$tool ]]; then
        ok "$tool available"
    else
        err "$tool missing or not executable" "Stow the scripts package:" "cd ~/dotfiles && ./refresh.sh"
    fi
done

# Without the waybar module nothing ever nags, so the whole scheme fails
# silently — a passing scrub-age check below would be pure luck.
if grep -q 'custom/maintenance' ~/.config/waybar/config.jsonc 2>/dev/null; then
    ok "waybar maintenance module wired"
else
    err "waybar has no custom/maintenance module — nothing will remind you" "Add it to ~/.config/waybar/config.jsonc, then:" "rewaybar"
fi

# Reuse maintenance-watch's own thresholds rather than keeping a second copy
# here that could drift out of step with the ones you actually get nagged by.
if [[ -x ~/.local/bin/maintenance-watch ]]; then
    if due=$(maintenance-watch --plain 2>/dev/null); then
        ok "no maintenance due"
    else
        while IFS= read -r item; do
            [[ -z $item ]] && continue
            warn "due — $item" "Run it:" "sys-maintenance"
        done <<< "$due"
    fi
fi
