#!/bin/sh

set -e
set -o pipefail

echo "***Installing Brew and Brew bundle***"

# s - silent output
which -s brew
if [ $? != 0 ]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  mkdir -p /usr/local/include
  sudo chmod 777 /usr/local
fi

brew bundle || true
