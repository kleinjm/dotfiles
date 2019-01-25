#!/bin/sh

set -e
set -o pipefail

# NOTE: I tried doing these as symlinks but Mail and other apps overwrite the
# files.

DOTFILES_PREFERENCES_PATH="$PRIVATE_CONFIGS_DIR"/mac/Preferences
MAC_PREFERENCES_PATH="$HOME"/Library/Preferences

# mail rules
rm -f "$HOME"/Library/Mail/V6/MailData/SyncedRules.plist
cp "$DOTFILES_PREFERENCES_PATH"/SyncedRules.plist ~/Library/Mail/V6/MailData/SyncedRules.plist

# keyboard settings
rm -f "$MAC_PREFERENCES_PATH"/.GlobalPreferences.plist
cp "$DOTFILES_PREFERENCES_PATH"/.GlobalPreferences.plist "$MAC_PREFERENCES_PATH"/.GlobalPreferences.plist

# sequel pro settings
rm -f "$MAC_PREFERENCES_PATH"/com.sequelpro.SequelPro.plist
cp "$DOTFILES_PREFERENCES_PATH"/com.sequelpro.SequelPro.plist "$MAC_PREFERENCES_PATH"/com.sequelpro.SequelPro.plist

# sequel pro favorites
rm -f "$HOME"/Library/Application\ Support/Sequel\ Pro/Data/Favorites.plist
cp "$DOTFILES_PREFERENCES_PATH"/Favorites.plist "$HOME"/Library/Application\ Support/Sequel\ Pro/Data/Favorites.plist

# Hidden files on Mac. Requires:
defaults write com.apple.finder AppleShowAllFiles YES

echo "For hidden files, hold 'alt' key, right click Finder, Relaunch"
