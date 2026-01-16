#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "=== DevPod Dotfiles Setup ==="
echo

# Symlink Zellij layouts
ZELLIJ_CONFIG_DIR="${HOME}/.config/zellij"
mkdir -p "${ZELLIJ_CONFIG_DIR}/layouts"

# Symlink entire layouts directory or individual files
if [[ -d "${SCRIPT_DIR}/zellij/layouts" ]]; then
  for layout in "${SCRIPT_DIR}/zellij/layouts"/*.kdl; do
    [[ -e "$layout" ]] || continue
    name=$(basename "$layout")
    ln -sf "$layout" "${ZELLIJ_CONFIG_DIR}/layouts/${name}"
    echo "Symlinked Zellij layout: ${name}"
  done
fi

# Symlink Zellij config.kdl if it exists
if [[ -f "${SCRIPT_DIR}/zellij/config.kdl" ]]; then
  ln -sf "${SCRIPT_DIR}/zellij/config.kdl" "${ZELLIJ_CONFIG_DIR}/config.kdl"
  echo "Symlinked Zellij config"
fi

# Source DevPod bashrc from ~/.bashrc
BASHRC_SOURCE="source ${SCRIPT_DIR}/bashrc"
if [[ -f "${SCRIPT_DIR}/bashrc" ]] && ! grep -qF "${BASHRC_SOURCE}" "${HOME}/.bashrc" 2>/dev/null; then
  echo "" >> "${HOME}/.bashrc"
  echo "# DevPod dotfiles" >> "${HOME}/.bashrc"
  echo "${BASHRC_SOURCE}" >> "${HOME}/.bashrc"
  echo "Added DevPod bashrc to ~/.bashrc"
fi

echo
echo "=== DevPod Dotfiles Setup Complete ==="
