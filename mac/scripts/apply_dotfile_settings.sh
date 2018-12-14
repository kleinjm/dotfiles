#!/bin/sh

set -e
set -o pipefail

# NOTE: I tried doing these as symlinks but Mail and other apps overwrite the
# files.

# mail rules
rm ~/Library/Mail/V6/MailData/SyncedRules.plist
cp ./mac/settings/SyncedRules.plist ~/Library/Mail/V6/MailData/SyncedRules.plist

# keyboard settings
rm ~/Library/Preferences/.GlobalPreferences.plist
cp ./mac/settings/GlobalPreferences.plist ~/Library/Preferences/.GlobalPreferences.plist

# sequel pro settings
rm ~/Library/Preferences/com.sequelpro.SequelPro.plist
cp ./sqlpro/com.sequelpro.SequelPro.plist ~/Library/Preferences/com.sequelpro.SequelPro.plist
