### FZF ###
export FZF_DEFAULT_COMMAND='/usr/local/bin/rg --files --follow --hidden -g "" 2> /dev/null'
export FZF_DEFAULT_OPTS="--height 100% --reverse --bind \"\
ctrl-b:page-up,\
ctrl-d:preview-page-down,\
ctrl-f:page-down,\
ctrl-h:unix-line-discard,\
ctrl-l:jump,\
ctrl-q:toggle-preview,\
ctrl-u:preview-page-up,\
down:preview-down,\
up:preview-up\
\""
export FZF_CTRL_R_OPTS='--no-preview'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS='--preview "(highlight -O ansi -l {} || cat {}) 2> /dev/null | head -5000"'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
