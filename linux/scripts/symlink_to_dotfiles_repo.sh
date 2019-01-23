#!/bin/bash

set -e
set -o pipefail

# v = verbose, t = target directory, d = current directory
stow -v -t "$HOME" -d "$PRIVATE_CONFIGS_DIR" bundle
stow -v -t "$HOME" -d "$PRIVATE_CONFIGS_DIR" aws
stow -v -t "$HOME" -d "$PRIVATE_CONFIGS_DIR"/linux docker
stow -v -t "$HOME" -d shared git
stow -v -t "$HOME" -d linux git
stow -v -t "$HOME" -d shared zsh
stow -v -t "$HOME" -d linux zsh
stow -v -t "$HOME" -d shared vim
stow -v -t "$HOME" -d linux vim
stow -v -t /etc -d linux etc # may need sudo access
stow -v -t "$HOME" nvm
stow -v -t "$HOME" pry
stow -v -t "$HOME" psql
stow -v -t "$HOME" pyenv
stow -v -t "$HOME" rbenv
stow -v -t "$HOME" tmux
stow -v -t "$HOME" -d $PRIVATE_CONFIGS_DIR ssh
