#!/bin/sh

set -e
set -o pipefail

echo "***Installing downloaded apps***"

mkdir "$DOTFILES_DIR"/tmp
cd "$DOTFILES_DIR"/tmp

curl https://ftp.osuosl.org/pub/videolan/vlc/3.0.6/macosx/vlc-3.0.6.dmg -o vlc.dmg
open vlc.dmg

# TODO: get boost note working
# curl https://github.com/BoostIO/boost-releases/releases/download/v0.11.12/Boostnote-mac.zip -o boostnote.zip

# dropbox
# chrome
