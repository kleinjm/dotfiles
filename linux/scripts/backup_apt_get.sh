#!/bin/bash

set -e
set -o pipefail

CONFIG_PATH=$DOTFILES_DIR/linux/config

# Taken from https://askubuntu.com/a/99151/911936
# NOTE: these lists are installed with linux/scripts/dependencies/apt_get.sh
dpkg --get-selections > $CONFIG_PATH/Package.list
sudo cp -R /etc/apt/sources.list* $CONFIG_PATH/
sudo apt-key exportall > $CONFIG_PATH/Repo.keys

echo "Finshed backing up apt get packages"
