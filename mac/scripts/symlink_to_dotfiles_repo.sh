#!/bin/bash

set -e
set -o pipefail

echo "Include private configurations? (stored in environment_configurations repo)"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
          : "${PRIVATE_CONFIGS_DIR:=$HOME/GitHubRepos/environment_configurations}"

          stow -v -t "$HOME" -d "$PRIVATE_CONFIGS_DIR" bundle --ignore='.bundle/cache/*'
          stow -v -t "$HOME" -d "$PRIVATE_CONFIGS_DIR" aws

          mkdir -p "$HOME"/.ssh
          stow -v -t "$HOME"/.ssh -d "$PRIVATE_CONFIGS_DIR"/mac/ssh .ssh
          stow -v -t "$HOME"/.ssh -d "$PRIVATE_CONFIGS_DIR"/ssh .ssh

          break;;
        No ) break;;
    esac
done

# v = verbose, t = target directory, d = current directory

stow -v -t "$HOME" -d shared git
stow -v -t "$HOME" -d mac git
stow -v -t "$HOME" -d mac redis

stow -v -t "$HOME" nvm
stow -v -t "$HOME" pry
stow -v -t "$HOME" psql
stow -v -t "$HOME" -d shared ag
stow -v -t "$HOME" -d shared tmux
stow -v -t "$HOME" -d mac tmux

stow -v -t "$HOME" -d shared vim
stow -v -t "$HOME" -d mac vim

mkdir -p "$HOME"/.config/nvim
stow -v -t "$HOME"/.config/nvim -d mac nvim

# may need to `rm $HOME/.zshrc`
stow -v -t "$HOME" -d shared zsh
stow -v -t "$HOME" -d mac zsh

# sudo needed to delete and write hosts file
# Symlink cannot be used. Must use a hard link
# https://superuser.com/a/1362442
sudo rm /etc/hosts
sudo ln -f "$PRIVATE_CONFIGS_DIR"/mac/etc/hosts /etc/hosts

ln -sf "$DOTFILES_DIR"/mac/scripts/vendor/* /usr/local/bin

mkdir -p "$HOME"/.pyenv
ln -sf "$DOTFILES_DIR"/shared/pyenv/version "$HOME"/.pyenv/version

mkdir -p "$HOME"/.rbenv
ln -sf "$DOTFILES_DIR"/rbenv/.rbenv/version "$HOME"/.rbenv/version

mkdir -p "$HOME"/Library/Application\ Support/Cursor/User
ln -sf "$DOTFILES_DIR"/mac/cursor/keybindings.json "$HOME"/Library/Application\ Support/Cursor/User/keybindings.json

# May need to update permissions
# chmod -R 0755 ~/.git/git_template/hooks

echo "Symlinking completed successfully"
