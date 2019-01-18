#!/bin/bash

set -e
set -o pipefail

TPM_DIR="$HOME"/.tmux/plugins/tpm

if [ ! -d "$TPM_DIR" ]; then
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
