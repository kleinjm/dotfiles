#!/bin/bash

set -e
set -o pipefail

echo "***Installing apt-get packages***"

sudo apt-get install --assume-yes xclip
