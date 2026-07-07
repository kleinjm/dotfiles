#!/bin/bash

set -e
set -o pipefail

# v = verbose, t = target directory, d = current directory

stow -v -t "$HOME" -d shared git
stow -v -t "$HOME" -d mac git
stow -v -t "$HOME" -d mac redis
stow -v -t "$HOME" -d mac gnupg

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
stow -v -t "$HOME" -d mac zsh --ignore='.profile'

ln -sf "$DOTFILES_DIR"/mac/scripts/vendor/* /usr/local/bin

mkdir -p "$HOME"/.pyenv
ln -sf "$DOTFILES_DIR"/shared/pyenv/version "$HOME"/.pyenv/version

mkdir -p "$HOME"/.rbenv
ln -sf "$DOTFILES_DIR"/rbenv/.rbenv/version "$HOME"/.rbenv/version

# Cursor IDE settings
mkdir -p "$HOME"/Library/Application\ Support/Cursor/User
ln -sf "$DOTFILES_DIR"/mac/cursor/keybindings.json "$HOME"/Library/Application\ Support/Cursor/User/keybindings.json
ln -sf "$DOTFILES_DIR"/mac/cursor/settings.json "$HOME"/Library/Application\ Support/Cursor/User/settings.json

# May need to update permissions
# chmod -R 0755 ~/.git/git_template/hooks

# Symlink entire agent-os and claude directories
# If directory exists, do not symlink
ln -s "$DOTFILES_DIR"/mac/.agent-os "$HOME"
ln -s "$DOTFILES_DIR"/shared/.claude "$HOME"

echo "Symlinking completed successfully"
