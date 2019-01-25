#!/bin/bash

set -e
set -o pipefail

echo "Backing up settings"

CONFIG_PATH="$DOTFILES_DIR"/linux/config

# terminal settings
dconf dump /org/gnome/terminal/ > "$CONFIG_PATH"/terminal_settings.txt

# gnome tweak settings
# See https://askubuntu.com/a/1056392
dconf dump / > "$CONFIG_PATH"/gnome_tweaks_settings.dconf

# All user settings
dconf dump / > "$CONFIG_PATH"/user.conf
