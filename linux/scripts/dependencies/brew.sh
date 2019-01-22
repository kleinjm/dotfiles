#!/bin/bash

set -e
set -o pipefail

echo "***Installing Linuxbrew and Brew bundling***"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"

brew bundle --file=$DOTFILES_DIR/linux/Brewfile || true
