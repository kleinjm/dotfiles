#!/bin/bash

set -e
set -o pipefail

dconf dump /org/gnome/terminal/ > $DOTFILES_DIR/linux/terminal_settings.txt
