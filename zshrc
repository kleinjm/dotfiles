##############################################################################
# File: zshrc
# Description: ZSH configuration used with oh-my-zsh
# Author: James Klein
##############################################################################

# On slow systems, checking the cached .zcompdump file to see if it must be
# regenerated adds a noticable delay to zsh startup.  This little hack restricts
# it to once a day.  It should be pasted into your own completion file.
#
# The globbing is a little complicated here:
# - '#q' is an explicit glob qualifier that makes globbing work within zsh's [[ ]] construct.
# - 'N' makes the glob pattern evaluate to nothing when it doesn't match (rather than throw a globbing error)
# - '.' matches "regular files"
# - 'mh+24' matches files (or directories or whatever) that are older than 24 hours.
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
fi;

platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='mac'
fi

# Path to your oh-my-zsh installation.
if [ $platform = 'mac' ]; then
  DEFAULT_USER=`whoami`
  export ZSH=/Users/$DEFAULT_USER/.oh-my-zsh
elif [ $platform = 'linux' ]; then
  export ZSH=/home/vagrant/.oh-my-zsh
fi

# set a project dir for use by things like tmuxinator
if [ $platform = 'mac' ]; then
  export PROJECT_DIR=~/GitHubRepos
elif [ $platform = 'linux' ]; then
  export PROJECT_DIR=~/work
fi

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# make _ and - interchangeable
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="mm/dd/yyyy"

# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# NOTE: zsh-autosuggestions zsh-syntax-highlighting need to go last!
plugins=(git bundler osx rake ruby tmux docker zsh-autosuggestions zsh-syntax-highlighting)

# QT added to path to fix gem install capybara-webkit issue
export PATH=~/Qt5.5.1/5.5/clang_64/bin:~/.rbenv/shims:/usr/local/bin:/usr/bin:$PATH

# NOTE: PATH must be before this
source $ZSH/oh-my-zsh.sh

# source local env vars if they exist
if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi

# tmuxinator autocomplete - allows `mux` in CLI
source $PROJECT_DIR/dotfiles/tmuxinator/tmuxinator.zsh

# Preferred editor for local and remote sessions
export EDITOR='vim'
# ssh
export SSH_KEY_PATH="~/.ssh/rsa_id"

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export MYVIMRC='~/.vimrc'

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

# Git
alias gpom='git pull origin master'
alias gpod='git pull origin develop'
alias master='git fetch --prune && git checkout master && git pull origin master'
alias develop='git fetch --prune && git checkout develop && git pull origin develop'

# NodeJS, NPM
alias sequelize="node_modules/.bin/sequelize"

# Misc, Personal
alias passwords="~/Dropbox/passwords.sh"
alias speed="speedtest-cli" # run a speedtest
alias pack="ruby ~/GitHubRepos/packing_checklist/app/run.rb"

# Doximity
alias dox='cd ~/GitHubRepos/doximity'
alias doxserver='bin/rails s webrick -p5000'
alias doxstart='~/GitHubRepos/dotfiles/tmuxinator/start_doximity.sh'
alias e2e-single="TEST_WEBDRIVER_TIMEOUT=99999999 SKIP_OAUTH=true ./node_modules/.bin/wdio --spec"

eval $(thefuck --alias)
# https://github.com/rbenv/rbenv/issues/142
eval "$(rbenv init -)"


export FZF_DEFAULT_COMMAND='/usr/local/bin/rg --files --follow --hidden -g "" 2> /dev/null'
# TODO: look at fzf documentation
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
# export FZF_ALT_C_COMMAND="bfs -type d -nohidden"
# export FZF_ALT_C_OPTS='--no-preview'
export FZF_CTRL_R_OPTS='--no-preview'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# export FZF_CTRL_T_OPTS='--preview "(highlight -O ansi -l {} || cat {}) 2> /dev/null | head -5000"'



### NVM ###
export NVM_DIR="$HOME/.nvm"

# Defer initialization of nvm until nvm, node or a node-dependent command is
# run. Ensure this block is only run once if .bashrc gets sourced multiple times
# by checking whether __init_nvm is a function.
if [ -s "$NVM_DIR/nvm.sh" ] && [ ! "$(whence -w __init_nvm)" = function ]; then
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  declare -a __node_commands=('nvm' 'node' 'npm' 'yarn' 'gulp' 'grunt' 'webpack')
  function __init_nvm() {
    for i in "${__node_commands[@]}"; do unalias $i; done
    . "$NVM_DIR"/nvm.sh
    unset __node_commands
    unset -f __init_nvm
  }
  for i in "${__node_commands[@]}"; do alias $i='__init_nvm && '$i; done
fi
