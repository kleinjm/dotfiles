#!/usr/bin/env sh

set -e
set -o pipefail

DATE=`date +%m_%d_%Y`

cd "${GOOGLE_DRIVE_DIR}/Quiver"
zip -r ./quiver.qvlibrary_$DATE.zip quiver.qvlibrary
