#!/bin/bash

set -e
set -o pipefail

: "${DOTFILES_DIR:=$HOME/GitHubRepos/dotfiles}"
CONFIG_PATH=$DOTFILES_DIR/linux/config

sudo apt-get install apt-clone
sudo apt-clone clone "$CONFIG_PATH"/apt-clone-state-ubuntu-"$(lsb_release -sr)".tar.gz

echo "Finshed backing up apt get packages"
