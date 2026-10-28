# Sourced from ~/.zshrc in the locky container by locky/setup.local.sh. The
# image and .locky provisioning already set mise, history, the prompt, the
# vim/EDITOR aliases and wtm completion; this adds only personal config.

# gh with the classic public_repo token, for issues and PRs on repos outside
# EscrowSafe. Plain gh keeps the EscrowSafe token from web/.env.
ghpub() {
  GH_TOKEN="$(cat /workspace/docker-data/gh-public-token)" gh "$@"
}

export GIT_MERGE_AUTOEDIT=no

# Shell commands (safer defaults)
alias ls="ls -Fhla --color"
alias cp="cp -v" # no -i: it hangs non-interactive scripts on overwrite
alias mv="mv -iv"
alias rm="rm -v"
alias mkdir="mkdir -v"
alias df="df -h"
alias du="du -cksh"
alias sed="sed -E"
alias \$=''
alias -g G="| rg "

# Tools
alias zellij='zellij -l welcome'
alias standup='ruby /workspace/dotfiles/shared/scripts/standup.rb'

# Git
alias gd='git add -N . && git diff; git reset >/dev/null 2>&1'
alias g='git'
alias ga='git add'
alias gl='git log'
alias gs='git status'
alias main='git main'
alias update="main && gprune && bundle && yarn && spring stop && rails db:migrate && rails restart"

# Rails
alias rc!="spring stop && rails console"
alias rT="bundle exec rake -T | grep"

# Git: delete local branches that don't exist on origin
gprune() {
  git fetch --prune
  local worktree_branches=$(git worktree list --porcelain 2>/dev/null | awk '/^branch / {sub(/^refs\/heads\//, "", $2); print $2}')
  git branch -vv | grep ': gone]' | awk '{gsub(/^[* +]+/, ""); print $1}' |
    grep -vxF "$worktree_branches" | xargs -r git branch -D
}

# Git: pull latest and merge main
gupdate() {
  git pull && git pull origin main
}

# Load .env vars into shell
load_dotenv_vars() {
  set -o allexport; source .env; set +o allexport
}

# Autosuggestions (cloned by setup.local.sh onto the docker-data bind mount)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1
__autosuggest="${DATA_DIR:-/workspace/docker-data}/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -r "$__autosuggest" ]] && source "$__autosuggest"
unset __autosuggest
