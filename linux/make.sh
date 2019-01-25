#!/bin/bash

set -e
set -o pipefail

echo "***Setting up everything***"

: "${DOTFILES_DIR:=$HOME/GitHubRepos/dotfiles}"
export DOTFILES_DIR=$DOTFILES_DIR

"$DOTFILES_DIR"/linux/scripts/dependencies.sh
"$DOTFILES_DIR"/linux/scripts/restore_settings.sh
"$DOTFILES_DIR"/linux/scripts/symlink_to_dotfiles_repo.sh
"$DOTFILES_DIR"/linux/scripts/fontconfig.sh

echo "Everything set up. Check linux/scripts for any additional setup"
