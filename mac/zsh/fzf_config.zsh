### FZF ###
# See http://owen.cymru/fzf-ripgrep-navigate-with-bash-faster-than-ever-before/

# --files
#   Print each file that would be searched without actually performing the search.
#   This is useful to determine whether a particular file is being search or not.
#
# --no-ignore
#   Don't respect ignore files (.gitignore, .ignore, etc.). This implies
#   --no-ignore-parent and --no-ignore-vcs.
#
# --hidden
#   Search hidden files and directories. By default, hidden files and directories
#   are skipped. Note that if a hidden file or a directory is whitelisted in an
#   ignore file, then it will be searched even if this flag isn't provided.
#
# --follow
#   When this flag is enabled, ripgrep will follow symbolic links while traversing
#   directories. This is disabled by default. Note that ripgrep will check for
#   symbolic link loops and report errors if it finds one.
#
# --glob <GLOB>...
#   Include or exclude files and directories for searching that match the given
#   glob. This always overrides any other ignore logic. Multiple glob flags may be
#   used. Globbing rules match .gitignore globs. Precede a glob with a ! to exclude
#   it.
#
# For node_module fix see
#   https://github.com/BurntSushi/ripgrep/issues/830#issuecomment-367843670
export FZF_DEFAULT_COMMAND='/usr/local/bin/rg --files --no-ignore --hidden --follow --glob "!{.git/*,node_modules/*,**/*.un~,vim/.vim/plugged}" 2> /dev/null'

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
