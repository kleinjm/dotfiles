#!/bin/sh

set -e
set -o pipefail

# NOTE I tried doing this as a symlink but Mail overwrites the file
cp ~/Library/Mail/V5/MailData/SyncedRules.plist ./mac/mail/SyncedRules.plist
