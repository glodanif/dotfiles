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
