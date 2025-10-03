### NVM ###
export NVM_DIR="$HOME/.nvm"

# Add nvm's current node version bin directory to PATH so globally installed
# npm packages are immediately available (e.g., devcontainer, claude, etc.)
if [ -d "$NVM_DIR/versions/node" ]; then
  # Find the current/default node version directory
  NODE_VERSION_DIR=$(find "$NVM_DIR/versions/node" -maxdepth 1 -type d | sort -V | tail -1)
  if [ -n "$NODE_VERSION_DIR" ]; then
    export PATH="$NODE_VERSION_DIR/bin:$PATH"
  fi
fi

# Defer initialization of nvm until nvm, node or a node-dependent command is
# run. Ensure this block is only run once if .bashrc gets sourced multiple times
# by checking whether __init_nvm is a function.
if [ -s "$NVM_DIR/nvm.sh" ] && ! type "$__init_nvm" > /dev/null; then
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  declare -a __node_commands=('nvm' 'node' 'npm' 'yarn' 'gulp' 'grunt' 'webpack')
  function __init_nvm() {
    for i in "${__node_commands[@]}"; do unalias $i; done
    . "$NVM_DIR"/nvm.sh
    unset __node_commands
    unset -f __init_nvm
  }
  for i in "${__node_commands[@]}"; do alias $i='__init_nvm && '$i; done
fi
