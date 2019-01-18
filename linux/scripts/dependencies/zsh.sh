#!/bin/bash

set -e
set -o pipefail

echo "***Installing oh-my-zsh***"

# NOTE: zsh should be installed from apt_get script
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
