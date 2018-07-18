#!/bin/sh

set -e
set -o pipefail

# NOTE I tried doing this as a symlink but Mail overwrites the file
rm ~/Library/Mail/V5/MailData/SyncedRules.plist
cp ./mac/mail/SyncedRules.plist ~/Library/Mail/V5/MailData/SyncedRules.plist
