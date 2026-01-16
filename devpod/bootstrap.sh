#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/.dotfiles"
DOTFILES_REPO="https://github.com/kleinjm/dotfiles.git"

# Clone dotfiles (re-clone fresh each time for latest)
if [[ -d "${DOTFILES_DIR}" ]]; then
  echo "Removing existing dotfiles..."
  rm -rf "${DOTFILES_DIR}"
fi

echo "Cloning dotfiles..."
git clone "${DOTFILES_REPO}" "${DOTFILES_DIR}"

# Run DevPod-specific setup script
if [[ -f "${DOTFILES_DIR}/devpod/setup.sh" ]]; then
  echo "Running DevPod dotfiles setup..."
  bash "${DOTFILES_DIR}/devpod/setup.sh"
fi
