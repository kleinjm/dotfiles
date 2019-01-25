#!/bin/sh

set -e
set -o pipefail

echo "***Installing Python and Requirements***"

# make sure python is installed so we have pip
# NOTE: it's also a macvim dependency
pyenv install "$PYENV_VERSION"

pip install -r shared/vim/.vim/pythonx/requirements.txt
pip install -r requirements.txt
