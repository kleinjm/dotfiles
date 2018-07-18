#!/bin/sh

set -e
set -o pipefail

rm ~/Library/Mail/V5/MailData/SyncedRules.plist
cp ./mac_config/mail/SyncedRules.plist ~/Library/Mail/V5/MailData/SyncedRules.plist
