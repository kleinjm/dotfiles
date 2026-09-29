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

# Link the host-side pre-flight hook into the web repo, which syncs
# compose.override.yaml from this repo before the devcontainer config is
# hashed. The link is relative so it resolves both here and on the host, where
# the two repos are siblings.
WEB_DEVCONTAINER="/workspaces/web/.devcontainer"
if [[ -d "${WEB_DEVCONTAINER}" && -f "${DOTFILES_DIR}/devpod/pre-flight.local.sh" ]]; then
  ln -sfn ../../dotfiles/devpod/pre-flight.local.sh "${WEB_DEVCONTAINER}/pre-flight.local.sh"
  echo "Linked ${WEB_DEVCONTAINER}/pre-flight.local.sh"
fi

# Pre-create persistence directories on the host (visible at /workspaces
# from inside this container, ~/GitHubRepos/devpod-data on the host).
mkdir -p /workspaces/devpod-data/gh
mkdir -p /workspaces/devpod-data/gh-app

# Link configs into the home directory
if [[ -f "${DOTFILES_DIR}/devpod/link.sh" ]]; then
  echo "Linking DevPod dotfiles..."
  bash "${DOTFILES_DIR}/devpod/link.sh"
fi

