#!/bin/bash

set -e
set -o pipefail

: "${DOTFILES_DIR:=$HOME/GitHubRepos/dotfiles}"
export DOTFILES_DIR=$DOTFILES_DIR

DEPENDENCIES_SCRIPTS_PATH=$DOTFILES_DIR/linux/scripts/dependencies
SHARED_DEPENDENCIES_SCRIPTS_PATH=$DOTFILES_DIR/shared/scripts/dependencies

sudo chmod u+x "$DEPENDENCIES_SCRIPTS_PATH"
sudo chmod u+x "$SHARED_DEPENDENCIES_SCRIPTS_PATH"

# NOTE: do not use loop or sort list because
# files in the scripts dir are order dependent
#
# H - Enable ! style history substitution
# bash "$DEPENDENCIES_SCRIPTS_PATH"/apt_get.sh -H
bash "$DEPENDENCIES_SCRIPTS_PATH"/brew.sh -H
bash "$SHARED_DEPENDENCIES_SCRIPTS_PATH"/tmp.sh -H
bash "$SHARED_DEPENDENCIES_SCRIPTS_PATH"/node.sh -H
bash "$SHARED_DEPENDENCIES_SCRIPTS_PATH"/zsh_autosuggestions.sh -H
