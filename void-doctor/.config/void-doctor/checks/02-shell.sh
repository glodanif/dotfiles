section "Shell"

[[ "$SHELL" == */zsh ]] && ok "zsh is default shell ($SHELL)" || err "zsh is not default shell" "Set zsh as your login shell:" "chsh -s \$(which zsh)"
[[ -d ~/.oh-my-zsh ]] && ok "oh-my-zsh installed" || warn "oh-my-zsh not installed" "Install:" 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
[[ -f ~/.p10k.zsh ]] && ok "p10k theme configured" || warn "no p10k theme found" "Run the powerlevel10k configurator:" "p10k configure"
