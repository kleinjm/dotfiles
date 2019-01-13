#!/usr/bin/env sh

# This script gets powerline fonts working.
# See https://powerline.readthedocs.io/en/latest/installation/linux.html#fonts-installation
# NOTE: detach and reattach to tmux session to see the fonts appear

wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf

FONT_DIR=/usr/share/fonts/X11/misc

mv PowerlineSymbols.otf $FONT_DIR

fc-cache -vf $FONT_DIR

mv 10-powerline-symbols.conf $HOME/.config/fontconfig/conf.d
