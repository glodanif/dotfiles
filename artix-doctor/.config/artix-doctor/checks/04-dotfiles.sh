section "Dotfiles"

command -v stow &>/dev/null && ok "stow installed" || err "stow not installed"
[[ -d ~/dotfiles ]] && ok "~/dotfiles directory present" || err "~/dotfiles directory missing"

declare -i shadowed=0 missing=0 mismatch=0

while IFS= read -r src; do
    pkg_and_rest=${src#$HOME/dotfiles/}
    relative=${pkg_and_rest#*/}
    target="$HOME/$relative"

    # Skip repo-root metadata files
    case "$relative" in
        LICENSE|README.md|.gitignore|packages-*.txt) continue ;;
    esac

    if [[ -L "$target" ]]; then
        link_target=$(readlink -f "$target" 2>/dev/null)
        expected=$(readlink -f "$src" 2>/dev/null)
        if [[ "$link_target" != "$expected" ]]; then
            warn "mismatch: ${target/#$HOME/~}"
            ((mismatch++)) || true
        fi
    elif [[ -f "$target" ]]; then
        err "shadowed (real file): ${target/#$HOME/~}"
        ((shadowed++)) || true
    else
        err "missing: ${target/#$HOME/~}"
        ((missing++)) || true
    fi
done < <(find ~/dotfiles -type f -not -path '*/.git/*')

if (( shadowed == 0 && missing == 0 && mismatch == 0 )); then
    ok "all dotfiles properly stowed"
fi

