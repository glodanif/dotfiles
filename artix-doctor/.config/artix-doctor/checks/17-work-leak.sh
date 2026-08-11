section "Work Config Leak"

# Guards against work/employer identity ending up in the dotfiles repo.
# The needles themselves are never stored here — they come from local.conf:
#   WORK_SSH_KEY="$HOME/.ssh/id_ed25519_<name>"   (basename is used as a needle)
#   WORK_SECRET_PATTERN="<org|employer|domain>"   (extended regex, case-insensitive)
# Matches are reported by file name only, so the pattern is never echoed back.

leak_repo="$HOME/dotfiles"
leak_patterns=()

[[ -n "${WORK_SSH_KEY:-}" ]] && leak_patterns+=("${WORK_SSH_KEY:t}")

if [[ -n "${WORK_SECRET_PATTERN:-}" ]]; then
    leak_patterns+=("$WORK_SECRET_PATTERN")
else
    warn "WORK_SECRET_PATTERN not set in local.conf" "Set it so the org name can be scanned for:" "WORK_SECRET_PATTERN=\"<org>|<work-domain>\""
fi

if [[ ! -d "$leak_repo/.git" ]]; then
    warn "~/dotfiles is not a git repo — skipping leak scan"
elif (( ${#leak_patterns[@]} == 0 )); then
    warn "no work leak patterns configured — nothing scanned" "Set at least one in ~/.config/artix-doctor/local.conf:" "WORK_SECRET_PATTERN=\"<org>\""
else
    leak_worktree=()
    leak_history=()

    for leak_pat in "${leak_patterns[@]}"; do
        # Working tree: tracked files + untracked ones git would pick up
        # (ignored paths excluded), so uncommitted edits are caught too.
        while IFS= read -r leak_hit; do
            [[ -n "$leak_hit" ]] && leak_worktree+=("$leak_hit")
        done < <(git -C "$leak_repo" grep -Iil --untracked -E -e "$leak_pat" 2>/dev/null)

        # Already committed at some point, even if since removed.
        while IFS= read -r leak_hit; do
            [[ -n "$leak_hit" ]] && leak_history+=("$leak_hit")
        done < <(git -C "$leak_repo" log --all --format="%h %s" -i -G"$leak_pat" 2>/dev/null)
    done

    if (( ${#leak_worktree[@]} == 0 )); then
        ok "no work identity in dotfiles working tree"
    else
        for leak_hit in ${(u)leak_worktree}; do
            if git -C "$leak_repo" ls-files --error-unmatch "$leak_hit" &>/dev/null; then
                err "work identity in tracked file: $leak_hit" "Move it to an untracked local file, then revert:" "git -C ~/dotfiles checkout -- $leak_hit"
            else
                err "work identity in untracked file: $leak_hit" "Not committed yet, but nothing is ignoring it — move it out of ~/dotfiles."
            fi
        done
    fi

    if (( ${#leak_history[@]} == 0 )); then
        ok "no work identity in git history"
    else
        for leak_hit in ${(u)leak_history}; do
            err "work identity in commit: $leak_hit" "History rewrite needed before this repo can be published (git-filter-repo)."
        done
    fi
fi

# local.conf holds the needles — it must never become a stow package itself.
[[ -e "$leak_repo/artix-doctor/.config/artix-doctor/local.conf" ]] \
    && err "local.conf is tracked in the dotfiles repo" "It holds work identity — remove it from the repo:" "git -C ~/dotfiles rm --cached artix-doctor/.config/artix-doctor/local.conf" \
    || ok "local.conf kept out of the repo"

unset leak_repo leak_patterns leak_pat leak_hit leak_worktree leak_history
