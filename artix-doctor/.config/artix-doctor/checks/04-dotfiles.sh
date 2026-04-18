section "Dotfiles"

command -v stow &>/dev/null && ok "stow installed" || err "stow not installed"
[[ -d ~/dotfiles ]] && ok "~/dotfiles directory present" || err "~/dotfiles directory missing"

typeset -A expected_links
expected_links[$HOME/.zshrc]=""
expected_links[$HOME/.zprofile]=""
expected_links[$HOME/.config/hypr/hyprland.conf]=""
expected_links[$HOME/.config/waybar/config.jsonc]=""
expected_links[$HOME/.config/walker/config.toml]=""
expected_links[$HOME/.config/ghostty/config.ghostty]=""
expected_links[$HOME/.config/mako/config]=""
expected_links[$HOME/.local/bin/sys-backup]=""

for link_path in "${(@k)expected_links}"; do
    if [[ -L "$link_path" ]]; then
        ok "stowed: ${link_path/#$HOME/~}"
    elif [[ -e "$link_path" ]]; then
        warn "exists but not a symlink: ${link_path/#$HOME/~}"
    else
        err "missing: ${link_path/#$HOME/~}"
    fi
done
