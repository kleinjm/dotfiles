#!/bin/bash

set -e
set -o pipefail

echo "***Installing zsh-autosuggestions***"

INSTALL_DIR=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestion
if [ ! -d "$INSTALL_DIR" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$INSTALL_DIR"
fi
