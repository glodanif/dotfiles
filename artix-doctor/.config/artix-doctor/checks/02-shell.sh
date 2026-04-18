section "Shell"

[[ "$SHELL" == */zsh ]] && ok "zsh is default shell ($SHELL)" || err "zsh is not default shell"
[[ -d ~/.oh-my-zsh ]] && ok "oh-my-zsh installed" || warn "oh-my-zsh not installed"
[[ -f ~/.p10k.zsh ]] && ok "prompt theme configured" || warn "no prompt theme detected"
