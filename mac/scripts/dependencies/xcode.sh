#!/bin/sh

set -e
set -o pipefail

echo "***Installing XCode***"

sudo xcodebuild -license accept
xcode-select --install 2> /dev/null || true
