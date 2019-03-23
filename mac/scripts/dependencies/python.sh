#!/bin/sh

set -e
set -o pipefail

echo "***Installing Python and Requirements***"

# make sure python is installed so we have pip
# See: https://github.com/pyenv/pyenv/issues/1219#issuecomment-428793012
< "$DOTFILES_DIR"/pyenv/.pyenv/version pyenv install

pip install -r shared/vim/.vim/pythonx/requirements.txt
pip install -r requirements.txt
