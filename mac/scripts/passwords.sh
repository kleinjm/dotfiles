#!/bin/bash

set -e
set -o pipefail

cd $DROPBOX_DIR

unzip unandpw.zip
vim unandpw.txt
zip -e unandpw.zip unandpw.txt # -e is encrypt

rm unandpw.txt
