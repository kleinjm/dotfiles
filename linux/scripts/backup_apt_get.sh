#!/bin/bash

set -e
set -o pipefail

# WARNING: This script has broken the wifi drivers between computers.
# It seems to work fine on the same computer but because there are drivers
# involved in the backup, they do not work between computers.

# : "${DOTFILES_DIR:=$HOME/GitHubRepos/dotfiles}"
# CONFIG_PATH=$DOTFILES_DIR/linux/config
#
# sudo apt-get install apt-clone
# sudo apt-clone clone "$CONFIG_PATH"/apt-clone-state-ubuntu-"$(lsb_release -sr)".tar.gz
#
# echo "Finshed backing up apt get packages"
