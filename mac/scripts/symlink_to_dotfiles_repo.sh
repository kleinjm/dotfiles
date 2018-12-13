#!/bin/sh

set -e
set -o pipefail

# TODO: fix this `stow: ERROR: Slashes are not permitted in package names`
SUBLIME_USER_DIR="${HOME}/Library/Application\ Support/Sublime\ Text\ 3/Packages/User"

# v = verbose, t = target directory, d = current directory
stow -v -t $HOME -d $PRIVATE_CONFIGS_DIR bundler
stow -v -t $HOME docker
stow -v -t $HOME git
stow -v -t $HOME nvm
stow -v -t $HOME pry
stow -v -t $HOME psql
stow -v -t $HOME pyenv
stow -v -t $HOME rbenv
stow -v -t $HOME tmux
stow -v -t $HOME vim
stow -v -t $HOME zsh
stow -v -t $HOME/Library/Application\ Support/Sublime\ Text\ 3/Packages/User sublime
sudo stow -v -t $HOME -d $PRIVATE_CONFIGS_DIR ssh

# May need to update permissions
# chmod -R 0755 ~/.git/git_template/hooks

# Hidden files on Mac. Requires: hold 'alt' key, right click Finder, Relaunch
defaults write com.apple.finder AppleShowAllFiles YES
