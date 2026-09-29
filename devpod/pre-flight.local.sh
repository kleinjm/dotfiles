#!/usr/bin/env bash
# Symlinked to <web-repo>/.devcontainer/pre-flight.local.sh by install.sh.
# Runs on the HOST at the start of the web repo's pre-flight.sh
# (initializeCommand), before the devcontainer config is hashed. Anything that
# writes into .devcontainer/ belongs here rather than in a script that runs
# inside the container, where a late write forces a recreate on the next start.
set -euo pipefail

# Where the symlink lives, i.e. the web repo's .devcontainer directory.
TARGET_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"

# Where this file really lives. macOS has no `readlink -f`, so walk the chain.
source_path="$0"
while [[ -L "${source_path}" ]]; do
  link_target="$(readlink "${source_path}")"
  if [[ "${link_target}" == /* ]]; then
    source_path="${link_target}"
  else
    source_path="$(dirname -- "${source_path}")/${link_target}"
  fi
done
SCRIPT_DIR="$(cd -- "$(dirname -- "${source_path}")" && pwd)"

SOURCE="${SCRIPT_DIR}/compose.override.yaml"
TARGET="${TARGET_DIR}/compose.override.yaml"

if [[ -f "${SOURCE}" ]] && ! cmp -s "${SOURCE}" "${TARGET}"; then
  echo "Updating ${TARGET} from dotfiles template..."
  cp "${SOURCE}" "${TARGET}"
fi
