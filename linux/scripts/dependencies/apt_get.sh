#!/bin/bash

set -e
set -o pipefail

echo "***Installing apt-get packages***"

CONFIG_PATH=$DOTFILES_DIR/linux/config

# Taken from https://askubuntu.com/a/99151/911936
# NOTE: these lists are build from the linux/scripts/backup_apt_get.sh script
sudo apt-key add $CONFIG_PATH/Repo.keys
sudo cp -R $CONFIG_PATH/sources.list* /etc/apt/
sudo apt-get update
sudo apt-get install dselect
sudo dselect update

# apt-cache dumpavail > ~/temp_avail
# sudo dpkg --merge-avail ~/temp_avail
# rm ~/temp_avail

sudo dpkg --set-selections < $CONFIG_PATH/Package.list
sudo apt-get dselect-upgrade -y
