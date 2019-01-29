#!/bin/sh

set -e
set -o pipefail

echo "***Installing Oh-my-zsh***"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sudo chmod -R 755 "$ZSH"/plugins
