##############################################################################
# File: zshrc
# Description: ZSH configuration to be used in a docker container
# Author: James Klein
##############################################################################

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

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

TERM=xterm-256color

# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(git bundler rake ruby docker)

# manually trigger autosuggestions
AUTOSUGGESTIONS_DIR=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestion
if [ -d "$AUTOSUGGESTIONS_DIR" ]; then
  source $AUTOSUGGESTIONS_DIR/zsh-autosuggestions.zsh
fi

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# NOTE: PATH must be before this
source $ZSH/oh-my-zsh.sh

export EDITOR='vim' # Preferred editor for local and remote sessions

# See https://github.com/zsh-users/zsh-autosuggestions#usage
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20 # turn off autosuggest for large paste
export ZSH_AUTOSUGGEST_USE_ASYNC=1 # do autosuggest async

# Git
# use the default merge message so that EDITOR does not open
export GIT_MERGE_AUTOEDIT=no

source ./zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
