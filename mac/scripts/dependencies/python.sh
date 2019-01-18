#!/bin/bash

set -e
set -o pipefail

echo "***Installing Python and Requirements***"

# make sure python is installed so we have pip
# NOTE: it's also a macvim dependency
(pyenv versions | grep "$PYENV_VERSION") 2> /dev/null
echo $?
# if [ $? != 0 ]; then
#   pyenv install "$PYENV_VERSION"
# fi
#
# # plugin to enable `pyenv install-latest`
# ls "$(pyenv root)"/plugins/pyenv-install-latest > /dev/null
# if [ $? != 0 ]; then
#   git clone https://github.com/momo-lab/pyenv-install-latest.git "$(pyenv root)"/plugins/pyenv-install-latest
# fi
#
# pip install -r vim/.vim/pythonx/requirements.txt
# pip install -r requirements.txt
