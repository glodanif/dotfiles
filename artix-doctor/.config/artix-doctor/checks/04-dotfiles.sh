section "Dotfiles"

command -v stow &>/dev/null && ok "stow installed" || err "stow not installed" "Install:" "sudo pacman -S stow"
[[ -d ~/dotfiles ]] && ok "~/dotfiles directory present" || err "~/dotfiles directory missing" "Clone your dotfiles repo into ~/dotfiles."

declare -i shadowed=0 missing=0 mismatch=0

while IFS= read -r src; do
    pkg_and_rest=${src#$HOME/dotfiles/}
    pkg=${pkg_and_rest%%/*}
    relative=${pkg_and_rest#*/}
    target="$HOME/$relative"

    # Skip repo-root metadata files. A stow package is always a directory, so
    # anything with no '/' left after stripping the repo path sits at the root
    # and belongs to no package. Structural rather than a list of names, so a
    # new root-level file (RECOVERY.md, a CI config) doesn't get reported as an
    # unstowed package the day it's added.
    [[ "$pkg_and_rest" != */* ]] && continue

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

