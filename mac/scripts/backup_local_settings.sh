#!/bin/sh

set -e
set -o pipefail

# NOTE: I tried doing these as symlinks but Mail and other apps overwrite the
# files.

# mail rules
cp ~/Library/Mail/V6/MailData/SyncedRules.plist ./mac/settings/SyncedRules.plist

# keyboard settings
cp ~/Library/Preferences/.GlobalPreferences.plist ./mac/settings/GlobalPreferences.plist

# sequel pro settings
cp ~/Library/Preferences/com.sequelpro.SequelPro.plist ./sqlpro/com.sequelpro.SequelPro.plist
