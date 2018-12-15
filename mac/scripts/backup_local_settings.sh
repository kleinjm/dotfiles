#!/bin/sh

set -e
set -o pipefail

# NOTE: I tried doing these as symlinks but Mail and other apps overwrite the
# files.

DOTFILES_PREFERENCES_PATH=./mac/Preferences
MAC_PREFERENCES_PATH=./mac/Preferences

# mail rules
cp ~/Library/Mail/V6/MailData/SyncedRules.plist $DOTFILES_PREFERENCES_PATH/SyncedRules.plist

# keyboard settings
cp $MAC_PREFERENCES_PATH/.GlobalPreferences.plist $DOTFILES_PREFERENCES_PATH/GlobalPreferences.plist

# sequel pro settings
cp $MAC_PREFERENCES_PATH/com.sequelpro.SequelPro.plist $DOTFILES_PREFERENCES_PATH/com.sequelpro.SequelPro.plist
