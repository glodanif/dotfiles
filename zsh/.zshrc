if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting sudo)

source $ZSH/oh-my-zsh.sh
export GPG_TTY=$(tty)

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias lg='lazygit'
alias ffs='sudo'
alias rewaybar='pkill waybar; nohup waybar > /dev/null 2>&1 &'

alias dl='yt-dlp -P "~/Downloads/Videos" --cookies-from-browser "brave+gnomekeyring"'
alias dl-batch='yt-dlp -P "~/Downloads/Videos" --cookies-from-browser "brave+gnomekeyring" --batch-file'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias personal-claude="CLAUDE_CONFIG_DIR=$HOME/.claude-personal command claude"
alias work-claude="CLAUDE_CONFIG_DIR=$HOME/.claude-work command claude"

alias java17='export JAVA_HOME=/usr/lib/jvm/java-17-openjdk; export PATH=$JAVA_HOME/bin:$PATH'
alias java26='export JAVA_HOME=$HOME/.jdks/openjdk-26; export PATH=$JAVA_HOME/bin:$PATH'

v() { if [ "$#" -eq 0 ]; then command nvim . ; else command nvim "$@"; fi; }
sudov() { if [ "$#" -eq 0 ]; then sudo nvim . ; else sudo nvim "$@"; fi; }

autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

HISTSIZE=32768
HISTFILESIZE=32768

