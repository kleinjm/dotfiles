#!/bin/bash

set -e
set -o pipefail

echo "***Setting up everything***"

: "${DOTFILES_DIR:=$HOME/GitHubRepos/dotfiles}"
export DOTFILES_DIR=$DOTFILES_DIR

"$DOTFILES_DIR"/mac/scripts/dependencies.sh
"$DOTFILES_DIR"/mac/scripts/symlink_to_dotfiles_repo.sh
"$DOTFILES_DIR"/mac/scripts/restore_settings.sh

echo "Everything set up"
