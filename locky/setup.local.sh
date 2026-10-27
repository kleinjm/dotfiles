#!/usr/bin/env bash
# Personal boot hook for the locky container. Symlink it into the web repo,
# where it is git-ignored and run on every container start:
#
#   ln -s /workspace/dotfiles/locky/setup.local.sh /workspace/web/.locky/setup.local.sh
#
# Home is the container's writable layer, so a recreate drops what this writes
# and the next boot writes it again. Keep every step idempotent.
set -euo pipefail

line='source /workspace/dotfiles/locky/shell.zsh'
grep -qxF "$line" ~/.zshrc 2>/dev/null || echo "$line" >>~/.zshrc
