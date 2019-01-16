#!/bin/bash

set -e
set -o pipefail

echo "***Installing NVM and Yarn packages***"

# if the $HOME/.nvm directory doesn't exist
if [ ! -d "$NVM_DIR" ]; then
  unset NVM_DIR # cannot be set before installing
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
  NVM_DIR="$HOME"/.nvm
  chmod 755 "$NVM_DIR"/nvm.sh
fi

# load nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# get the latest version with "node"
nvm install node
nvm use
yarn
