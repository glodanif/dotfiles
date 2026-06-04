if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting sudo)

source $ZSH/oh-my-zsh.sh
export GPG_TTY=$(tty)
eval "$(fzf --zsh)"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias lg='lazygit'
alias ffs='sudo'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias ls='eza --icons'
alias ll='eza -la --icons --git'
alias la='eza -la --icons'

v() { if [ "$#" -eq 0 ]; then command nvim . ; else command nvim "$@"; fi; }
sudov() { if [ "$#" -eq 0 ]; then sudo nvim . ; else sudo nvim "$@"; fi; }

autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

HISTFILE="$HOME/.zsh_history"
HISTSIZE=32768
SAVEHIST=32768
