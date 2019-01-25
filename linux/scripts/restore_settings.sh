#!/bin/bash

set -e
set -o pipefail

CONFIG_PATH="$DOTFILES_DIR"/linux/config

# terminal settings
dconf load /org/gnome/terminal/ < "$CONFIG_PATH"/terminal_settings.txt

# gnome tweak settings
# See https://askubuntu.com/a/1056392
dconf load / < "$CONFIG_PATH"/gnome_tweaks_settings.dconf

# All user settings
# See https://askubuntu.com/a/746262/911936
dconf load / < "$CONFIG_PATH"/user.conf
