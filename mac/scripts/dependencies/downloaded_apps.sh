#!/bin/sh

set -e
set -o pipefail

echo "***Installing downloaded apps***"

cd "$DOTFILES_DIR"/tmp

curl https://ftp.osuosl.org/pub/videolan/vlc/3.0.6/macosx/vlc-3.0.6.dmg -o vlc.dmg
open vlc.dmg

# dash
