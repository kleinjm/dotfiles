#!/bin/bash

set -e
set -o pipefail

echo "***Installing apt-get packages***"

# WARNING: Do not try to use `apt-clone`
# It seems to work fine on the same computer but because there are drivers
# involved in the backup, they do not work between computers.

sudo apt-add-repository ppa:rodsmith/refind
sudo apt-get update

sudo apt install vim-gtk curl stow zsh ksshaskpass gnome-tweak-tool tmux rbenv refind git-lfs jq gawk parallel
