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

# Symlink git config
if [[ -f "${SCRIPT_DIR}/git/.gitconfig" ]]; then
  ln -sf "${SCRIPT_DIR}/git/.gitconfig" "${HOME}/.gitconfig"
  echo "Symlinked .gitconfig"
fi

# Install zsh-autosuggestions if not present
ZSH_AUTOSUGGESTIONS="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [[ ! -d "$ZSH_AUTOSUGGESTIONS" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS"
  echo "Installed zsh-autosuggestions"
fi

# Symlink nvim config directory
NVIM_CONFIG_DIR="${HOME}/.config/nvim/lua"
if [[ -d "${SCRIPT_DIR}/nvim/config" ]]; then
  mkdir -p "${NVIM_CONFIG_DIR}"
  rm -rf "${NVIM_CONFIG_DIR}/config"
  ln -sf "${SCRIPT_DIR}/nvim/config" "${NVIM_CONFIG_DIR}/config"
  echo "Symlinked nvim config directory"
fi

# Symlink nvim plugin files (individual files, not directory)
if [[ -d "${SCRIPT_DIR}/nvim/plugins" ]]; then
  mkdir -p "${NVIM_CONFIG_DIR}/plugins"
  for plugin_file in "${SCRIPT_DIR}"/nvim/plugins/*.lua; do
    if [[ -f "$plugin_file" ]]; then
      filename=$(basename "$plugin_file")
      ln -sf "$plugin_file" "${NVIM_CONFIG_DIR}/plugins/${filename}"
      echo "Symlinked nvim plugin: ${filename}"
    fi
  done
fi

echo
echo "=== DevPod Dotfiles Setup Complete ==="
