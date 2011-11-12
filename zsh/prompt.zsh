setopt prompt_subst
autoload colors
colors
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '%F{green}%s%F{7} %F{2}(%F{blue}%b%F{2})%f '
zstyle ':vcs_info:*' enable git svn

PS1="%F{green}%n@%m%k %F{blue}%1~ %# %b%f%k"
RPROMPT='${vcs_info_msg_0_}'

precmd() {
   title "zsh" "%m" "%55<...<%~"
   vcs_info 'prompt'
 }
