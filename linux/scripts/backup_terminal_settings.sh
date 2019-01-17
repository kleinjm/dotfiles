#!/bin/bash

set -e
set -o pipefail

dconf dump /org/gnome/terminal/ > $DOTFILES_DIR/linux/config/terminal_settings.txt
