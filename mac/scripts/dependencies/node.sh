#!/bin/bash

set -e
set -o pipefail

echo "***Installing NVM and Yarn packages***"

ls $HOME/.nvm > /dev/null
if [ $? != 0 ]; then
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
  chmod 755 $NVM_DIR/nvm.sh
fi

# load nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# get the latest version with "node"
nvm install node
nvm use
yarn
