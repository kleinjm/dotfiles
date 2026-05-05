#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/.dotfiles"
DOTFILES_REPO="https://github.com/kleinjm/dotfiles.git"
WORKSPACE_DOTFILES="/workspaces/dotfiles"

# Remove existing dotfiles dir/symlink
if [[ -e "${DOTFILES_DIR}" || -L "${DOTFILES_DIR}" ]]; then
  echo "Removing existing dotfiles..."
  rm -rf "${DOTFILES_DIR}"
fi

# If workspace dotfiles exist (DevPod), symlink to them for persistence
if [[ -d "${WORKSPACE_DOTFILES}" ]]; then
  echo "Symlinking dotfiles to workspace (changes will persist)..."
  ln -sf "${WORKSPACE_DOTFILES}" "${DOTFILES_DIR}"
else
  echo "Cloning dotfiles..."
  git clone "${DOTFILES_REPO}" "${DOTFILES_DIR}"
fi

# Link configs into the home directory
if [[ -f "${DOTFILES_DIR}/devpod/link.sh" ]]; then
  echo "Linking DevPod dotfiles..."
  bash "${DOTFILES_DIR}/devpod/link.sh"
fi
