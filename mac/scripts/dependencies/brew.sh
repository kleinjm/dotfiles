#!/bin/sh

set -e
set -o pipefail

echo "***Installing Brew and Brew bundle***"

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
mkdir -p /usr/local/include
sudo chmod 777 /usr/local

brew bundle --file="$DOTFILES_DIR"/mac/Brewfile || true
