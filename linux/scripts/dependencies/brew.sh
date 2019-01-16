#!/bin/bash

set -e
set -o pipefail

echo "***Installing Linuxbrew and Brew bundling***"

# s - silent output
which brew
if [ $? != 0 ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
fi

brew bundle --file=$DOTFILES_DIR/linux/Brewfile || true
