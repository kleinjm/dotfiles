#!/bin/sh

# NOTE: Everything in here is order dependent

set -e
set -o pipefail

# make sure python is installed so we have pip
# NOTE: it's also a macvim dependency
pyenv versions | grep $PYENV_VERSION
if [ $? != 0 ]; then
  pyenv install $PYENV_VERSION
fi

# plugin to enable `pyenv install-latest`
ls "$(pyenv root)"/plugins/pyenv-install-latest
if [ $? != 0 ]; then
  git clone https://github.com/momo-lab/pyenv-install-latest.git "$(pyenv root)"/plugins/pyenv-install-latest
fi

pip install -r vim/.vim/pythonx/requirements.txt

# Aliased to `speed` in zsh aliases
pip install speedtest-cli
