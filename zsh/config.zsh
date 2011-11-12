
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
REPORTTIME=10
eval `dircolors -b`

setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt CORRECT
setopt COMPLETE_IN_WORD

bindkey '^P' reverse-menu-complete
bindkey '^N' expand-or-complete

export EDITOR="vim"
export PATH=$PATH:$ZSH/bin
