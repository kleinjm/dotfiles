#!/bin/bash

set -e
set -o pipefail

echo "***Installing apt-get packages***"

# WARNING: Do not try to use `apt-clone`
# It seems to work fine on the same computer but because there are drivers
# involved in the backup, they do not work between computers.

sudo apt-add-repository ppa:rodsmith/refind
sudo apt-get update

# Ensure packages added here are not part of the brew bundle
sudo apt install vim-gtk curl zsh ksshaskpass gnome-tweak-tool refind
