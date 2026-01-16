#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "=== DevPod Dotfiles Setup ==="
echo

# Symlink Zellij layouts directory
ZELLIJ_CONFIG_DIR="${HOME}/.config/zellij"
mkdir -p "${ZELLIJ_CONFIG_DIR}"

if [[ -d "${SCRIPT_DIR}/zellij/layouts" ]]; then
  rm -rf "${ZELLIJ_CONFIG_DIR}/layouts"
  ln -sf "${SCRIPT_DIR}/zellij/layouts" "${ZELLIJ_CONFIG_DIR}/layouts"
  echo "Symlinked Zellij layouts directory"
fi

# Symlink Zellij config.kdl if it exists
if [[ -f "${SCRIPT_DIR}/zellij/config.kdl" ]]; then
  ln -sf "${SCRIPT_DIR}/zellij/config.kdl" "${ZELLIJ_CONFIG_DIR}/config.kdl"
  echo "Symlinked Zellij config"
fi

# Symlink zsh config files
if [[ -f "${SCRIPT_DIR}/zshrc" ]]; then
  ln -sf "${SCRIPT_DIR}/zshrc" "${HOME}/.zshrc"
  echo "Symlinked .zshrc"
fi

if [[ -f "${SCRIPT_DIR}/zprofile" ]]; then
  ln -sf "${SCRIPT_DIR}/zprofile" "${HOME}/.zprofile"
  echo "Symlinked .zprofile"
fi

if [[ -f "${SCRIPT_DIR}/zshenv" ]]; then
  ln -sf "${SCRIPT_DIR}/zshenv" "${HOME}/.zshenv"
  echo "Symlinked .zshenv"
fi

echo
echo "=== DevPod Dotfiles Setup Complete ==="
