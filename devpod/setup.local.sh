#!/usr/bin/env bash
# Copy this file to: <web-repo>/.devcontainer/setup.local.sh
# (gitignored there). It runs automatically from the web repo's setup.sh
# during container creation, and from there pulls and runs install.sh.
bash <(curl -fsSL https://raw.githubusercontent.com/kleinjm/dotfiles/main/devpod/install.sh)
