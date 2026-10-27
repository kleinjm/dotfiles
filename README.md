# Dotfiles

[![CI](https://github.com/kleinjm/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/kleinjm/dotfiles/actions/workflows/ci.yml)

Personal dotfiles for Mac development environments. Manages vim, tmux, zsh, git, and various development tool configurations.

## Quick Start

### Mac
```bash
# Prerequisites
# - Latest Mac OS

# Run main setup script
mac/make.sh
```

## Directory Structure

- `mac/` - Mac-specific configurations and scripts
- `devpod/` - Devcontainer/devpod environment configurations and scripts
- `locky/` - Configuration for the locky container (bb running in Docker/podman for the web repo)
- `shared/` - Cross-platform configurations (vim, zsh, tmux, git)

## Setup Details

### Mac
* Make sure you're on the latest Mac OS
* Run `mac/make.sh` which executes:
  1. `mac/scripts/dependencies.sh` - Install Homebrew packages
  2. `mac/scripts/symlink_to_dotfiles_repo.sh` - Create symlinks to dotfiles
  3. `mac/scripts/restore_settings.sh` - Apply Mac system settings
* This repo assumes the home dir is `jklein`. If it's not, symlink it with:
  ```sh
  cd /Users
  sudo ln -s james jklein
  ```
* Show hidden files in Finder with `defaults write com.apple.Finder AppleShowAllFiles true && killall Finder`

### Installing Fonts
* Open the font file and install it to the Mac Font Book
  * `open mac/config/Fura\ Mono\ Regular\ Nerd\ Font\ Complete\ Mono\ Windows\ Compatible.otf`
* In iTerm, set the font to that font for the current profile. Profiles > Text > Font
* Restart vim and you should see devicons

### Syncing Settings
* To apply repo settings to the local machine: `mac/scripts/restore_settings.sh` (part of `make` script)

### Sequel Pro
- Dark query scheme found in `mac/config/sequel-pro/`

### Additional environment configurations
* Chrome theme - Dark Theme v3

### Userscripts
Stored in bookmarks on my google chrome account.

### NVM
I set the system ~/.nvmrc -> dotfiles/nvmrc and have that fetching `node` which is the latest node version. Any project without a .nvmrc will use the latest since it will traverse up the dirs to find my root one

### TMUX & Tmuxinator
Default tmux config taken from [oh-my-tmux](https://github.com/gpakosz/.tmux)

Tmuxinator project configurations are stored in `shared/tmux/.tmuxinator/` and symlinked to `~/.tmuxinator/`.

#### Usage
```bash
# Create new tmuxinator config
mac/scripts/new_tmuxinator_config.rb [project_name]

# Start a tmux session
tmuxinator start [project_name]
# or shorthand:
mux [project_name]

# Debug tmuxinator config
tmuxinator debug [project_name]
```

### Alfred
- Settings are stored in the private env config path in Google Drive.
- This should already be stored in settings but if not, use [this script](https://github.com/stuartcryan/custom-iterm-applescripts-for-alfred) to get Alfred <> iTerm2 integration

### VIM
- Main config located in `shared/.vimrc`
- Uses vim-plug for plugin management
- Followed [this guide](https://tbaggery.com/2011/08/08/effortless-ctags-with-git.html) to set up ctags using git hooks
- Uses [vim-projectionist](https://github.com/tpope/vim-projectionist) to define alternate files as explained [here](https://noahfrederick.com/log/vim-templates-with-ultisnips-and-projectionist). Each project has a `.projections.json` defined and globally git ignored.
- Install pythonx dependencies with the following. Note that `vim-pyenv` takes care of using the pyenv, not system version of python:
```sh
pip install -r shared/vim/.vim/pythonx/requirements.txt
```

### iTunes
- For Alfred iTunes miniplayer: In iTunes go to Preferences > Advanced > Share iTunes Library XML with other applications

### SSH
To set up ssh and rsync without asking for a password. See [this guide](https://www.thegeekstuff.com/2011/07/rsync-over-ssh-without-password/)
NOTE: the same `id_rsa.pub` is shared so this should not be necessary
```
ssh-copy-id -i ~/.ssh/id_rsa.pub jamesmkl@jamesmklein.com
```

### Neovim
I'm not using neovim currently but to get it set up I used the following
```
brew install neovim
created ~/.config/nvm/init.vim

# run :checkhealth

# https://github.com/zchee/deoplete-jedi/wiki/Setting-up-Python-for-Neovim
sudo pip2 install --user neovim
sudo pip3 install --user neovim

gem install neovim
```

### Quiver
- Quiver settings are stored in `mac/config/Quiver-settings.json`

### bb (locky)
`locky/bb/` keeps bb's configuration so a fresh bb can be rebuilt: `plugins.json` lists the plugins installed on top of bb's built-ins (with their sources) and every plugin's enabled state, and `settings.json` holds the general settings, theme, UI preferences changed from their defaults, and keyboard overrides. Credentials (`auth.json`, `auth-secret`, plugin tokens) and `bb.db` are never exported.

Both scripts run inside the locky container (`bin/locky shell` from the web repo, or any bb terminal), with bb running:

* **Back up** after installing a plugin or changing a setting, then commit the two JSON files:
  ```sh
  bash /workspace/dotfiles/locky/bb/export.sh
  ```
* **Restore** onto a fresh bb, after `bin/locky up` has finished provisioning (the `wtm` plugin and `escrowsafe` theme come from the web repo's `.locky/`, so they must exist first):
  ```sh
  bash /workspace/dotfiles/locky/bb/restore.sh
  ```
  It is idempotent: installed plugins are skipped and settings are set to the same value again. A few keys `bb settings show` reports are read-only and are skipped. It exits 1 if any step failed.

Restoring installs third-party plugins from their recorded git sources, so a plugin that has since published a new version within its semver range installs that version, not the one that was running when exported.

### Shell (locky)
`locky/setup.local.sh` is the container's personal boot hook. Link it once from the host or the container: `ln -s /workspace/dotfiles/locky/setup.local.sh /workspace/web/.locky/setup.local.sh`. On every boot it adds `source /workspace/dotfiles/locky/shell.zsh` to `~/.zshrc`. `shell.zsh` defines `ghpub`, which runs `gh` with the classic `public_repo` token in `docker-data/gh-public-token` (mode 600, outside every repo) for issues and PRs on repos outside EscrowSafe; plain `gh` keeps the EscrowSafe token.

## Security

Machine-local secrets (API tokens, PATs) live in `~/.secrets.zshenv`, which is
**not** in this repo. `shared/zsh/.zshenv` sources it if present, so the exports
reach every shell — interactive, non-interactive, and scripts.

```sh
touch ~/.secrets.zshenv && chmod 600 ~/.secrets.zshenv
# then add lines like:
#   export NOTION_PAT="ntn_..."
```

Store the tokens themselves in 1Password; the file is just a cache so a new
machine can be rebuilt from the vault. Never `stow` it and never move it into
`shared/zsh/` — that directory is tracked.

Sensitive files are additionally excluded via `.gitignore`:
- `mac/.claude/.credentials.json` and related credential files
- `*.key`, `*.pem`, `*.cert`
- `.env` and `.env.*` files

## Troubleshooting
- If you're getting a message about `__init_nvm` not being defined, nvm likely added something to the .zshrc. Check the bottom of the file.
