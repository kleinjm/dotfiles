#!/usr/bin/env sh

set -e
set -o pipefail

cd ~/Dropbox

unzip unandpw.zip
vim unandpw.txt
zip -e unandpw.zip unandpw.txt # -e is encrypt

rm unandpw.txt
