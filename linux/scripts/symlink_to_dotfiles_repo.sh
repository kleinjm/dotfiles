#!/bin/bash

set -e
set -o pipefail

# v = verbose, t = target directory, d = current directory
# stow -v -t "$HOME" -d $PRIVATE_CONFIGS_DIR bundle
# stow -v -t "$HOME" -d $PRIVATE_CONFIGS_DIR aws
# stow -v -t "$HOME" docker
stow -v -t "$HOME" -d shared git
stow -v -t "$HOME" -d linux git
stow -v -t "$HOME" -d shared zsh
stow -v -t "$HOME" -d linux zsh
stow -v -t "$HOME" -d shared vim
stow -v -t "$HOME" -d linux vim
sudo stow -v -t /etc -d linux etc
stow -v -t "$HOME" nvm
# stow -v -t "$HOME" pry
# stow -v -t "$HOME" psql
# stow -v -t "$HOME" pyenv
# stow -v -t "$HOME" rbenv
stow -v -t "$HOME" tmux
# sudo stow -v -t "$HOME" -d $PRIVATE_CONFIGS_DIR ssh

# May need to update permissions
# chmod -R 0755 ~/.git/git_template/hooks
