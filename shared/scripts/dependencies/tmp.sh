#!/bin/bash

set -e
set -o pipefail

TMP_DIR="$HOME"/.tmux/plugins/tpm

if [ ! -d "$TMP_DIR" ]; then
  git clone https://github.com/tmux-plugins/tpm "$TMP_DIR"
fi
