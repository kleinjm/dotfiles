#!/bin/sh

set -e
set -o pipefail

# NOTE: I tried doing these as symlinks but Mail and other apps overwrite the
# files.

DOTFILES_PREFERENCES_PATH=$PRIVATE_CONFIGS_DIR/mac/Preferences
MAC_PREFERENCES_PATH=$HOME/Library/Preferences

# mail rules
cp $HOME/Library/Mail/V6/MailData/SyncedRules.plist $DOTFILES_PREFERENCES_PATH/SyncedRules.plist

# keyboard settings
cp $MAC_PREFERENCES_PATH/.GlobalPreferences.plist $DOTFILES_PREFERENCES_PATH/.GlobalPreferences.plist

# sequel pro settings
cp $MAC_PREFERENCES_PATH/com.sequelpro.SequelPro.plist $DOTFILES_PREFERENCES_PATH/com.sequelpro.SequelPro.plist

# sequel pro favorites
cp $HOME/Library/Application\ Support/Sequel\ Pro/Data/Favorites.plist $DOTFILES_PREFERENCES_PATH/Favorites.plist
