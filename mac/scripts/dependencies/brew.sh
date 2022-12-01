#!/bin/sh

set -e
set -o pipefail

echo "***Installing Brew and Brew bundle***"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew bundle --file="$DOTFILES_DIR"/mac/Brewfile || true
