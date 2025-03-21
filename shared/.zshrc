##############################################################################
# File: zshrc
# Description: ZSH configuration used with oh-my-zsh
# Author: James Klein
##############################################################################

# On slow systems, checking the cached .zcompdump file to see if it must be
# regenerated adds a noticable delay to zsh startup.  This little hack restricts
# it to once a day.  It should be pasted into your own completion file.
# See https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2767420
#
# The globbing is a little complicated here:
# - '#q' is an explicit glob qualifier that makes globbing work within zsh's [[ ]] construct.
# - 'N' makes the glob pattern evaluate to nothing when it doesn't match (rather than throw a globbing error)
# - '.' matches "regular files"
# - 'm1' matches files (or directories or whatever) that are older than 24 hours.
autoload -Uz compinit
setopt EXTENDEDGLOB
for dump in $HOME/.zcompdump(#qN.m1); do
  compinit
  if [[ -s "$dump" && (! -s "$dump.zwc" || "$dump" -nt "$dump.zwc") ]]; then
    zcompile "$dump"
  fi
done
unsetopt EXTENDEDGLOB
compinit -C

# Allows running rake commands in ZSH with arguments.
# See https://thoughtbot.com/blog/how-to-use-arguments-in-a-rake-task
unsetopt nomatch

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="jamesklein"

# make _ and - interchangeable
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# ignore insecure completion-dependent directories
ZSH_DISABLE_COMPFIX=true

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="mm/dd/yyyy"

HISTSIZE=1000000 # amount of commands saved in history

# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# NOTE: zsh-syntax-highlighting was affecting boot performance
# NOTE: rails plugin temporarily removed because `rg` shortcut messed
# with ripgrep
plugins=(docker-compose git bundler rake ruby tmux docker command-not-found colored-man-pages)

# manually trigger autosuggestions
AUTOSUGGESTIONS_DIR=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
if [ -d "$AUTOSUGGESTIONS_DIR" ]; then
  source $AUTOSUGGESTIONS_DIR/zsh-autosuggestions.zsh
fi

# QT added to path to fix gem install capybara-webkit issue
# openssl added to fix issue with brew installing over the system version
# mysql added to fix issue with brew linking
export PATH=$HOME/.rbenv/bin:/usr/local/sbin:/usr/local/opt/mysql@5.7/bin:/usr/local/opt/openssl/bin:$PATH

# NOTE: PATH must be before this
source $ZSH/oh-my-zsh.sh

# source local env vars if they exist.
# NOTE: oh-my-zsh overrides some things ie. `ls` at
# https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/theme-and-appearance.zsh#L24
# thus, these files need to be defined after sourcing oh-my-zsh.sh
# See https://github.com/robbyrussell/oh-my-zsh/issues/5783#issuecomment-275614664
export LOCAL_CONFIG=$PRIVATE_CONFIGS_DIR/zshrc.local
if [ -f $LOCAL_CONFIG ]; then
  source $LOCAL_CONFIG
fi

export EDITOR='nvim' # Preferred editor for local and remote sessions
export SSH_KEY_PATH="~/.ssh/rsa_id" # ssh
# something was setting RBENV_VERSION and it was preventing using .ruby-version
export RBENV_VERSION=

# See https://github.com/zsh-users/zsh-autosuggestions#usage
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20 # turn off autosuggest for large paste
export ZSH_AUTOSUGGEST_USE_ASYNC=1 # do autosuggest async

# Git
# use the default merge message so that EDITOR does not open
export GIT_MERGE_AUTOEDIT=no

# Load all .zsh config files in this dir
# NOTE: must come after oh-my-zsh.sh is sourced
for file in $HOME/*.zsh; do
  source "$file"
done

source $HOME/.oh-my-zsh/custom/plugins/*.zsh

### PYENV and Python - https://github.com/pyenv/pyenv#homebrew-on-mac-os-x ###
# NOTE: Step #2 & #3 here says to place in zshenv rather than zshrc but that did
# not work. Leave it here
# https://github.com/pyenv/pyenv#basic-github-checkout
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Always put new terminal sessions in a tmux session if not already in one
# (3/17/25) Disabled due to conflict with Cursor/VS Code
# if [[ -z "$TMUX" ]]; then
#   tmux new-session -A -s "$USER"
# fi

# Terraform autocomplete installed via `terraform -install-autocomplete`
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

eval "$(rbenv init -)"
