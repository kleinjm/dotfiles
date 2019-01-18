#!/bin/bash

set -e
set -o pipefail

# WARNING: Do not try to use `apt-clone`
# It seems to work fine on the same computer but because there are drivers
# involved in the backup, they do not work between computers.

sudo apt install vim-gtk curl stow zsh ksshaskpass gnome-tweak-tool tmux rbenv
