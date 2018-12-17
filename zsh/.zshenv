# This file loads in non-interactive shells
# I've found that using this file slows down the shell, specifically
# vim-tmux navigation. Instead, favor zshrc.

# Load all .zshenv config files in this dir
# aliases.zshenv should be available in all shells, not just interactive ones.
# Ie. vim should have aliases

export ZSH=$HOME/.oh-my-zsh # Path to your oh-my-zsh installation.
export PROJECT_DIR=$HOME/GitHubRepos
export DOTFILES_DIR=$PROJECT_DIR/dotfiles
export DROPBOX_DIR=$HOME/Dropbox
export PRIVATE_CONFIGS_DIR=$HOME/Dropbox/EnvironmentConfigurations

### PYENV and Python - https://github.com/pyenv/pyenv#homebrew-on-mac-os-x ###
# https://github.com/pyenv/pyenv#basic-github-checkout
export PYENV_VERSION=3.7.0
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

for file in $DOTFILES_DIR/zsh/*.zshenv; do
  source "$file"
done
