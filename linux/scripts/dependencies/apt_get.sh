#!/bin/bash

set -e
set -o pipefail

echo "***Installing apt-get packages***"

CONFIG_PATH=$DOTFILES_DIR/linux/config

# Taken from https://askubuntu.com/a/486634/911936
# NOTE: if this script is failing, you're on a different release
sudo apt-clone restore "$CONFIG_PATH"/apt-clone-state-ubuntu-"$(lsb_release -sr)".tar.gz

# Restore to newer release
# sudo apt-clone restore-new-distro path-to/apt-clone-state-ubuntu.tar.gz $(lsb_release -sc)

echo "Finshed restoring apt get packages"
