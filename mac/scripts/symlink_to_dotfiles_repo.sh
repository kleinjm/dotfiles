#!/bin/bash

set -e
set -o pipefail

: "${PRIVATE_CONFIGS_DIR:=$HOME/Google\ Drive/EnvironmentConfigurations}"

# v = verbose, t = target directory, d = current directory
stow -v -t "$HOME" -d "$PRIVATE_CONFIGS_DIR" bundle --ignore='.bundle/cache/*'
stow -v -t "$HOME" -d "$PRIVATE_CONFIGS_DIR" aws

stow -v -t "$HOME" -d shared git
stow -v -t "$HOME" -d mac git

stow -v -t "$HOME" nvm
stow -v -t "$HOME" pry
stow -v -t "$HOME" psql
stow -v -t "$HOME" rbenv
stow -v -t "$HOME" -d shared ag
stow -v -t "$HOME" -d shared tmux
stow -v -t "$HOME" -d mac tmux

stow -v -t "$HOME" -d shared vim
stow -v -t "$HOME" -d mac vim

# may need to `rm $HOME/.zshrc`
stow -v -t "$HOME" -d shared zsh
stow -v -t "$HOME" -d mac zsh

mkdir -p "$HOME"/.ssh
stow -v -t "$HOME"/.ssh -d "$PRIVATE_CONFIGS_DIR"/mac/ssh .ssh
stow -v -t "$HOME"/.ssh -d "$PRIVATE_CONFIGS_DIR"/ssh .ssh

ln -sf "$DOTFILES_DIR"/mac/scripts/vendor/* /usr/local/bin

mkdir -p "$HOME"/.pyenv
ln -sf "$DOTFILES_DIR"/shared/pyenv/version "$HOME"/.pyenv/version

# May need to update permissions
# chmod -R 0755 ~/.git/git_template/hooks

echo "Symlinking completed successfully"
