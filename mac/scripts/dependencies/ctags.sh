#!/bin/sh

set -e
set -o pipefail

echo "***Installing Ctags***"

# see https://github.com/tpope/rbenv-ctags
until
  rbenv ctags
  [ "$?" -ne 127  ]
do
  mkdir -p ~/.rbenv/plugins
  git clone git://github.com/tpope/rbenv-ctags.git \
    ~/.rbenv/plugins/rbenv-ctags
done
