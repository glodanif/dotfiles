section "Apps"

if command -v voxtype &>/dev/null; then
    if [[ -d ~/.cache/voxtype ]] || [[ -d ~/.local/share/voxtype ]]; then
        ok "voxtype installed and initialized"
    else
        warn "voxtype installed but not initialized"
    fi
else
    warn "voxtype not installed"
fi

if command -v hyprpm &>/dev/null; then
    ok "hyprpm available"
else
    warn "hyprpm not installed"
fi

if command -v hyprpm &>/dev/null; then
    if hyprpm list 2>/dev/null | grep -A3 "hy3" | grep -q "enabled.*true"; then
        ok "hy3 plugin installed and enabled"
    elif hyprpm list 2>/dev/null | grep -qi "hy3"; then
        warn "hy3 plugin installed but not enabled"
    else
        warn "hy3 plugin not installed via hyprpm"
    fi
fi

