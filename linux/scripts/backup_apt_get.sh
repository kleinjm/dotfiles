#!/bin/bash

set -e
set -o pipefail

: "${DOTFILES_DIR:=$HOME/GitHubRepos/dotfiles}"
CONFIG_PATH=$DOTFILES_DIR/linux/config

# WARNING: ensure `deinstall`-ed packages are not included.
# They be necessary on one system and not another.
# If they are included, the following should remove them.
# Taken from https://askubuntu.com/a/486026/911936
sudo dpkg --purge "$(dpkg --get-selections | grep deinstall | cut -f1)" 2> /dev/null || true

# Backup script taken from https://askubuntu.com/a/99151/911936
# NOTE: these lists are installed with linux/scripts/dependencies/apt_get.sh
dpkg --get-selections > "$CONFIG_PATH"/Package.list
sudo cp -R /etc/apt/sources.list* "$CONFIG_PATH"/
sudo apt-key exportall | sudo tee -a "$CONFIG_PATH"/Repo.keys > /dev/null

echo "Finshed backing up apt get packages"
