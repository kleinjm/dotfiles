#!/bin/sh

set -e
set -o pipefail

ORIGINAL_PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# download to itunes directly to trigger import
cd ~/Music/iTunes/iTunes\ Media/Automatically\ Add\ to\ iTunes.localized
youtube-dl -x --audio-format mp3 $1

# cleanup
rm -rf ~/Music/iTunes/iTunes\ Media/Automatically\ Add\ to\ iTunes.localized/Not\ Added/

# fire off remote sync script
$ORIGINAL_PWD/upload_music.sh
