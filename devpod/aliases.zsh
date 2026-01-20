# Shell commands (safer defaults)
alias ls="ls -Fhla --color"
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -v"
alias mkdir="mkdir -v"
alias df="df -h"
alias du="du -cksh"
alias sed="sed -E"
alias \$=''

# Editors
alias vim='nvim'
alias vi='nvim'

# Git
alias g='git'
alias ga='git add'
alias gl='git log'
alias gs='git status'

# Rails
alias rc!="spring stop && rails console"
alias rT="bundle exec rake -T | grep"
