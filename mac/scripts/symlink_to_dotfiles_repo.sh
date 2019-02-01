#!/bin/bash

set -e
set -o pipefail

: "${PRIVATE_CONFIGS_DIR:=$HOME/Dropbox/EnvironmentConfigurations}"

# v = verbose, t = target directory, d = current directory
stow -v -t "$HOME" -d "$PRIVATE_CONFIGS_DIR" bundle
stow -v -t "$HOME" -d "$PRIVATE_CONFIGS_DIR" aws
stow -v -t "$HOME" -d mac docker
stow -v -t "$HOME" -d shared git
stow -v -t "$HOME" -d mac git
stow -v -t "$HOME" nvm
stow -v -t "$HOME" pry
stow -v -t "$HOME" psql
stow -v -t "$HOME" pyenv
stow -v -t "$HOME" rbenv
stow -v -t "$HOME" tmux
stow -v -t "$HOME" -d shared vim
stow -v -t "$HOME" -d mac vim
# may need to `rm $HOME/.zshrc`
stow -v -t "$HOME" -d shared zsh
stow -v -t "$HOME" -d mac zsh
sudo stow -v -t "$HOME" -d "$PRIVATE_CONFIGS_DIR" ssh

# May need to update permissions
# chmod -R 0755 ~/.git/git_template/hooks
