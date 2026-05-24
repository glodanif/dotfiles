section "Dotfiles"

command -v stow &>/dev/null && ok "stow installed" || err "stow not installed" "Install:" "sudo xbps-install -S stow"
[[ -d ~/dotfiles ]] && ok "~/dotfiles directory present" || err "~/dotfiles directory missing" "Clone your dotfiles repo into ~/dotfiles."

declare -i shadowed=0 missing=0 mismatch=0

while IFS= read -r src; do
    pkg_and_rest=${src#$HOME/dotfiles/}
    pkg=${pkg_and_rest%%/*}
    relative=${pkg_and_rest#*/}
    target="$HOME/$relative"

    # Skip repo-root metadata files
    case "$relative" in
        LICENSE|README.md|.gitignore|.stowignore|packages-*.txt|refresh.sh) continue ;;
    esac

    if [[ -L "$target" ]]; then
        link_target=$(readlink -f "$target" 2>/dev/null)
        expected=$(readlink -f "$src" 2>/dev/null)
        if [[ "$link_target" != "$expected" ]]; then
            warn "mismatch: ${target/#$HOME/~}" "Re-stow the package:" "cd ~/dotfiles && stow -R $pkg"
            ((mismatch++)) || true
        fi
    elif [[ -f "$target" ]]; then
        err "shadowed (real file): ${target/#$HOME/~}" "Back up and remove the real file, then re-stow:" "cd ~/dotfiles && stow -R $pkg"
        ((shadowed++)) || true
    else
        err "missing: ${target/#$HOME/~}" "Stow the package:" "cd ~/dotfiles && stow $pkg"
        ((missing++)) || true
    fi
done < <(find ~/dotfiles -type f -not -path '*/.git/*' -not -path '*/.claude/*')

if (( shadowed == 0 && missing == 0 && mismatch == 0 )); then
    ok "all dotfiles properly stowed"
fi

