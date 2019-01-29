#!/bin/bash

set -e
set -o pipefail

echo "***Installing powerline fonts***"

# See https://github.com/powerline/powerline/blob/6257332372bf9f64d928b6a3b53d2842d9c7e01f/docs/source/installation/linux.rst#fonts-installation
wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
mv PowerlineSymbols.otf ~/.local/share/fonts/
fc-cache -vf ~/.local/share/fonts/
mv 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/

echo "***Fonts installed - Log out and back in***"
