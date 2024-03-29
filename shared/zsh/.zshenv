# This file loads in non-interactive shells
# I've found that using this file slows down the shell, specifically
# vim-tmux navigation. Instead, favor zshrc.

# Load all .zshenv config files in this dir
# aliases.zshenv should be available in all shells, not just interactive ones.
# Ie. vim should have aliases

export ZSH=$HOME/.oh-my-zsh # Path to your oh-my-zsh installation.
export PROJECT_DIR=$HOME/GitHubRepos
export DOTFILES_DIR=$PROJECT_DIR/dotfiles
export PRIVATE_CONFIGS_DIR=$HOME/GitHubRepos/environment_configurations

### PYENV and Python - https://github.com/pyenv/pyenv#homebrew-on-mac-os-x ###
# https://github.com/pyenv/pyenv#basic-github-checkout
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# See https://stackoverflow.com/a/49462622/2418828
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE="true"

for file in $DOTFILES_DIR/shared/zsh/*.zshenv; do
  source "$file"
done
