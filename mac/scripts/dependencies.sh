#!/bin/bash

set -e
set -o pipefail

: "${DOTFILES_DIR:=$HOME/GitHubRepos/dotfiles}"
export DOTFILES_DIR=$DOTFILES_DIR

DEPENDENCIES_SCRIPTS_PATH=$DOTFILES_DIR/mac/scripts/dependencies
SHARED_DEPENDENCIES_SCRIPTS_PATH=$DOTFILES_DIR/shared/scripts/dependencies

sudo chmod u+x "$DEPENDENCIES_SCRIPTS_PATH"
sudo chmod u+x "$SHARED_DEPENDENCIES_SCRIPTS_PATH"

# NOTE: do not use loop or sort list because
# files in the scripts dir are order dependent
#
# H - Enable ! style history substitution
bash "$DEPENDENCIES_SCRIPTS_PATH"/brew.sh -H

echo "Open XCode, accept the agreement, and let extensions install"
read -n 1 -s -r -p  "Press any key to continue"
echo

bash "$DEPENDENCIES_SCRIPTS_PATH"/zsh.sh -H
bash "$DEPENDENCIES_SCRIPTS_PATH"/ctags.sh -H
bash "$SHARED_DEPENDENCIES_SCRIPTS_PATH"/gems.sh -H
bash "$SHARED_DEPENDENCIES_SCRIPTS_PATH"/node.sh -H
bash "$SHARED_DEPENDENCIES_SCRIPTS_PATH"/zsh_autosuggestions.sh -H
bash "$DEPENDENCIES_SCRIPTS_PATH"/phoenix.sh -H
bash "$DEPENDENCIES_SCRIPTS_PATH"/downloaded_apps.sh -H
