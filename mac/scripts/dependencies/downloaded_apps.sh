#!/bin/sh

set -e
set -o pipefail

echo "***Installing downloaded apps***"

mkdir -p "$DOTFILES_DIR"/tmp
cd "$DOTFILES_DIR"/tmp

# TODO: write a function that loops through a list and asks which things you want to install

# -L follows redirects, -o specify location
# curl -L https://ftp.osuosl.org/pub/videolan/vlc/3.0.6/macosx/vlc-3.0.6.dmg -o vlc.dmg
# open vlc.dmg

# TODO: get boost note working
# curl https://github.com/BoostIO/boost-releases/releases/download/v0.11.12/Boostnote-mac.zip -o boostnote.zip

# google drive
# chrome
# iterm
# boostnote
# dash

# refind
# open https://sourceforge.net/projects/refind/files/latest/download
