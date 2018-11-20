#!/bin/sh

set -e
set -o pipefail

# NOTE I tried doing this as a symlink but Mail overwrites the file
# mail rules
cp ~/Library/Mail/V6/MailData/SyncedRules.plist ./mac/settings/SyncedRules.plist
# keyboard settings
cp ~/Library/Preferences/.GlobalPreferences.plist ./mac/settings/GlobalPreferences.plist
