#!/bin/bash

set -e
set -o pipefail

dconf load /org/gnome/terminal/ < $DOTFILES_DIR/linux/terminal_settings.txt
