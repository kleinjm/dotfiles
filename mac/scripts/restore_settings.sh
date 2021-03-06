#!/bin/sh

set -e
set -o pipefail

# NOTE: I tried doing these as symlinks but Mail and other apps overwrite the
# files.

DOTFILES_PREFERENCES_PATH="$PRIVATE_CONFIGS_DIR"/mac/Preferences
MAC_PREFERENCES_PATH="$HOME"/Library/Preferences

# keyboard settings
rm -f "$MAC_PREFERENCES_PATH"/.GlobalPreferences.plist
cp "$DOTFILES_PREFERENCES_PATH"/.GlobalPreferences.plist "$MAC_PREFERENCES_PATH"/.GlobalPreferences.plist

# Finder settings
rm -f "$MAC_PREFERENCES_PATH"/com.apple.finder.plist
cp "$DOTFILES_PREFERENCES_PATH"/com.apple.finder.plist "$MAC_PREFERENCES_PATH"/com.apple.finder.plist

# sequel pro settings
rm -f "$MAC_PREFERENCES_PATH"/com.sequelpro.SequelPro.plist
cp "$DOTFILES_PREFERENCES_PATH"/com.sequelpro.SequelPro.plist "$MAC_PREFERENCES_PATH"/com.sequelpro.SequelPro.plist

# sequel pro favorites
TARGET_PATH="$HOME"/Library/Application\ Support/Sequel\ Pro/Data
rm -f "$TARGET_PATH"/Favorites.plist
mkdir -p "$TARGET_PATH"
cp "$DOTFILES_PREFERENCES_PATH"/Favorites.plist "$TARGET_PATH"/Favorites.plist

# Hidden files on Mac. Requires:
defaults write com.apple.finder AppleShowAllFiles YES

echo "For hidden files, hold 'alt' key, right click Finder, Relaunch"
