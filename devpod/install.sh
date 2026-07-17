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

# Sync compose.override.yaml into the web repo so the next container
# recreate picks up persistence mounts (e.g. gh CLI auth). Overwrite is
# fine — this file is owned by the dotfiles template.
WEB_OVERRIDE="/workspaces/web/.devcontainer/compose.override.yaml"
DOTFILES_OVERRIDE="${DOTFILES_DIR}/devpod/compose.override.yaml"
if [[ -d "/workspaces/web/.devcontainer" && -f "${DOTFILES_OVERRIDE}" ]]; then
  if ! cmp -s "${DOTFILES_OVERRIDE}" "${WEB_OVERRIDE}" 2>/dev/null; then
    echo "Updating ${WEB_OVERRIDE} from dotfiles template..."
    cp "${DOTFILES_OVERRIDE}" "${WEB_OVERRIDE}"
    echo "  (run 'bin/dpod recreate' from the host to apply mount changes)"
  fi
fi

# Pre-create persistence directories on the host (visible at /workspaces
# from inside this container, ~/GitHubRepos/devpod-data on the host).
mkdir -p /workspaces/devpod-data/gh

# Link configs into the home directory
if [[ -f "${DOTFILES_DIR}/devpod/link.sh" ]]; then
  echo "Linking DevPod dotfiles..."
  bash "${DOTFILES_DIR}/devpod/link.sh"
fi

# Install the local diffity fork (colorblind diff viewer) as the global
# `diffity` command, backing the `review-changes` zsh function. The fork is a
# sibling repo mounted into the container at /workspaces/diffity. Its checked-in
# node_modules carry the host's (macOS) native binaries, so we reinstall +
# rebuild better-sqlite3 for this container's platform, then build and
# `npm link` so `diffity` resolves to the fork instead of the npm release.
# Guarded so a diffity build failure never aborts the rest of dotfiles setup.
DIFFITY_DIR="/workspaces/diffity"
if [[ -d "${DIFFITY_DIR}/packages/cli" ]]; then
  echo "Installing local diffity fork from ${DIFFITY_DIR}..."
  if (
    set -e
    cd "${DIFFITY_DIR}"
    npm install
    npm rebuild better-sqlite3   # force a native rebuild for this platform
    npm run build
    cd packages/cli
    npm link
  ); then
    echo "  diffity linked ($(command -v diffity))"
  else
    echo "  WARNING: diffity setup failed; 'review-changes' will be unavailable." >&2
  fi
fi
