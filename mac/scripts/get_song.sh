#!/usr/bin/env sh

set -e
set -o pipefail

ORIGINAL_PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# download to Downloads folder. There is no automatically add to Music folder
cd ~/Downloads
youtube-dl -x --audio-format mp3 $1

# fire off remote sync script
$ORIGINAL_PWD/upload_music.sh
