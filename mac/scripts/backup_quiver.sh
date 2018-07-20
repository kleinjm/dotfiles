#!/usr/bin/env sh

set -e
set -o pipefail

DATE=`date +%m_%d_%Y`

cd $DROPBOX_DIR
zip -r ./Quiver\ backup/quiver.qvlibrary_$DATE.zip quiver.qvlibrary
