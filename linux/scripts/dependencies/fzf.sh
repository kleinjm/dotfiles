#!/bin/bash

set -e
set -o pipefail

echo "***Installing fzf***"

# See https://github.com/junegunn/fzf.vim/issues/1#issuecomment-422456830
# The vim part of this is backed up in the dotfiles
if [ ! -d "$PROJECT_DIR"/fzf ]; then
  git clone https://github.com/junegunn/fzf "$PROJECT_DIR"/fzf
  cd "$PROJECT_DIR"/fzf
  ./install
  sudo mv bin/fzf /bin
fi
