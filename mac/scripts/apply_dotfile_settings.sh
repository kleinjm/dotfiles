#!/bin/sh

set -e
set -o pipefail

# NOTE I tried doing this as a symlink but Mail overwrites the file
# mail rules
rm ~/Library/Mail/V6/MailData/SyncedRules.plist
cp ./mac/settings/SyncedRules.plist ~/Library/Mail/V5/MailData/SyncedRules.plist

# keyboard settings
rm ~/Library/Preferences/.GlobalPreferences.plist
cp ./mac/settings/GlobalPreferences.plist ~/Library/Preferences/.GlobalPreferences.plist
