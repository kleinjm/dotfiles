#!/usr/bin/env sh

DEPENDENCIES_SCRIPTS_PATH=$DOTFILES_DIR/linux/scripts/dependencies

# NOTE: do not use loop or sort list because
# files in the scripts dir are order dependent
#
# H - Enable ! style history substitution
bash $DEPENDENCIES_SCRIPTS_PATH/apt_get.sh -H
bash $DEPENDENCIES_SCRIPTS_PATH/brew.sh -H
