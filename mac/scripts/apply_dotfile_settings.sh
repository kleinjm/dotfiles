#!/bin/sh

set -e
set -o pipefail

# NOTE: I tried doing these as symlinks but Mail and other apps overwrite the
# files.

DOTFILES_PREFERENCES_PATH=./mac/Preferences
MAC_PREFERENCES_PATH=$HOME/Library/Preferences

# mail rules
rm ~/Library/Mail/V6/MailData/SyncedRules.plist
cp $DOTFILES_PREFERENCES_PATH/SyncedRules.plist ~/Library/Mail/V6/MailData/SyncedRules.plist

# keyboard settings
rm $MAC_PREFERENCES_PATH/.GlobalPreferences.plist
cp $DOTFILES_PREFERENCES_PATH/.GlobalPreferences.plist $MAC_PREFERENCES_PATH/.GlobalPreferences.plist

# sequel pro settings
rm $MAC_PREFERENCES_PATH/com.sequelpro.SequelPro.plist
cp $DOTFILES_PREFERENCES_PATH/com.sequelpro.SequelPro.plist $MAC_PREFERENCES_PATH/com.sequelpro.SequelPro.plist
