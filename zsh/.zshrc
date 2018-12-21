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
# - 'mh+24' matches files (or directories or whatever) that are older than 24 hours.
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
# NOTE: Follow the oh-my-zsh install instructions and check out `develop` branch
# https://github.com/zsh-users/zsh-autosuggestions#oh-my-zsh
# Currently there is an issue on master
# See https://github.com/zsh-users/zsh-autosuggestions/issues/241
plugins=(git bundler osx rake ruby rails tmux docker zsh-autosuggestions)

# QT added to path to fix gem install capybara-webkit issue
# openssl added to fix issue with brew installing over the system version
# mysql added to fix issue with brew linking
export PATH=/usr/local/opt/mysql@5.7/bin:/usr/local/opt/openssl/bin:$PATH

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

export EDITOR='vim' # Preferred editor for local and remote sessions
export SSH_KEY_PATH="~/.ssh/rsa_id" # ssh
export MYVIMRC='~/.vimrc'

# See https://github.com/zsh-users/zsh-autosuggestions#usage
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20 # turn off autosuggest for large paste
export ZSH_AUTOSUGGEST_USE_ASYNC=1 # do autosuggest async

# Git
# use the default merge message so that EDITOR does not open
export GIT_MERGE_AUTOEDIT=no

# Load all .zsh config files in this dir
# NOTE: must come after oh-my-zsh.sh is sourced
for file in $DOTFILES_DIR/zsh/*.zsh; do
  source "$file"
done

source $HOME/.oh-my-zsh/custom/plugins/*.zsh

# Doximity specific
eval "$("$PROJECT_DIR/dox-compose/bin/dox-init")"

# https://github.com/rbenv/rbenv/issues/142
eval "$(rbenv init -)"

### PYENV and Python - https://github.com/pyenv/pyenv#homebrew-on-mac-os-x ###
# NOTE: Step #2 & #3 here says to place in zshenv rather than zshrc but that did
# not work. Leave it here
# https://github.com/pyenv/pyenv#basic-github-checkout
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
