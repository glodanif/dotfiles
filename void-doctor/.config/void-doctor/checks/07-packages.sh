section "Packages"

command -v xbps-install &>/dev/null && ok "xbps-install available" || err "xbps package manager not found"
command -v xbps-query &>/dev/null && ok "xbps-query available" || err "xbps-query not found"

updates=$(sudo xbps-install -Sun 2>/dev/null | grep -v "^$\|\[" | grep -v "^Name" | grep -c "." || true)
if (( updates > 0 )); then
    warn "$updates package update(s) available (run: sys-update)"
else
    ok "all packages up to date"
fi

orphan_count=$(xbps-query -O 2>/dev/null | grep -c "." || true)
if (( orphan_count > 0 )); then
    warn "$orphan_count orphaned package(s) (run: sudo xbps-remove -Oo)"
else
    ok "no orphaned packages"
fi
