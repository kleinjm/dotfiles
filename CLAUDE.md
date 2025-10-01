# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository for Mac and Linux development environments. Manages configuration files for vim, tmux, zsh, git, and various development tools through symlink-based setup scripts.

## Architecture

### Directory Structure

- `mac/` - Mac-specific configurations and setup scripts
- `linux/` - Linux-specific configurations and setup scripts
- `shared/` - Cross-platform configurations (vim, zsh, tmux, git, etc.)
  - `shared/vim/` - Vim configuration and plugins
  - `shared/zsh/` - Zsh shell configuration
  - `shared/tmux/.tmuxinator/` - Tmuxinator project configurations
  - `shared/git/` - Git configuration
  - `shared/scripts/` - Shared utility scripts
- `UltiSnips/` - Vim snippet templates
- `projections.json` - Vim projectionist mappings for alternate files

### Key Environment Variables

Set in `shared/zsh/.zshenv`:
- `$DOTFILES_DIR` - Path to this repository (default: `$HOME/GitHubRepos/dotfiles`)
- `$PROJECT_DIR` - Base directory for projects (default: `$HOME/GitHubRepos`)
- `$PRIVATE_CONFIGS_DIR` - Path to private environment configurations repo

## Setup and Installation

### Mac Setup

```bash
# Main setup (must be run from repo root)
mac/make.sh
```

This runs:
1. `mac/scripts/dependencies.sh` - Installs Homebrew packages and system dependencies
2. `mac/scripts/symlink_to_dotfiles_repo.sh` - Creates symlinks from home directory to dotfiles
3. `mac/scripts/restore_settings.sh` - Applies Mac system settings

### Linux Setup

```bash
# Main setup
linux/make.sh
```

This runs:
1. `linux/scripts/dependencies.sh` - Installs system packages and dependencies
2. `linux/scripts/restore_settings.sh` - Applies Linux settings
3. `linux/scripts/symlink_to_dotfiles_repo.sh` - Creates symlinks
4. `linux/scripts/fontconfig.sh` - Configures fonts

### Manual Font Installation (Mac)

```bash
open mac/config/Fura\ Mono\ Regular\ Nerd\ Font\ Complete\ Mono\ Windows\ Compatible.otf
```

Then configure iTerm2 to use the font: Profiles > Text > Font

## Development Tools

### Linting

```bash
# JavaScript
npx eslint [files]

# CoffeeScript
npx coffeelint [files]

# SCSS/Sass
npx sass-lint [files]

# Ruby
bundle exec rubocop [files]
```

Configuration files:
- `.eslintrc.yml` - ESLint config (2-space indent, single quotes, Unix line endings)
- `.rubocop.yml` - RuboCop config

### Dependencies

Install dependencies:
```bash
# Node.js
yarn install

# Ruby
bundle install

# Python (for vim)
pip install -r vim/pythonx/requirements.txt
```

## Tmuxinator

Tmuxinator configs are stored in `shared/tmux/.tmuxinator/` and symlinked to `~/.tmuxinator/`.

Create new project config:
```bash
mac/scripts/new_tmuxinator_config.rb [project_name]
```

Start a tmux session:
```bash
tmuxinator start [project_name]
```

Debug tmuxinator config:
```bash
tmuxinator debug [project_name]
```

## Vim Configuration

Main config: `shared/.vimrc`

- Uses vim-plug for plugin management
- Plugins defined in `~/.vim/plugins.vim`
- Custom functions in `~/.vim/functions.vim`
- Lightline statusbar config in `~/.vim/lightline.vim`
- Color scheme: jellybeans
- Leader key: `<Space>`
- Supports ctags via git hooks (see README)

### Vim Projectionist

Uses `projections.json` for defining alternate files and skeletons. Examples:
- Toggle between spec and implementation: `:A` (vim-projectionist)
- Spec files (`spec/*_spec.rb`) alternate with implementation (`app/*.rb`)
- Factory files alternate with models
- Vue component skeletons available

## Security Notes

Sensitive files are gitignored (see `.gitignore`):
- `mac/.claude/.credentials.json`
- `*.credentials.json`, `*.key`, `*.pem`, `*.cert`
- `.env` and `.env.*`
- Private configs should be in separate `environment_configurations` repo

## System Preferences Backup

```bash
# Save current Mac settings to repo
mac/scripts/backup_settings.sh

# Apply repo settings to Mac (part of make.sh)
mac/scripts/restore_settings.sh
```

## NVM Configuration

System-wide `.nvmrc` symlinked to `dotfiles/nvmrc`, set to use `node` (latest version). Projects without `.nvmrc` will use latest node via directory traversal.

## Additional Notes

- Home directory is assumed to be `jklein`. If different, create symlink: `cd /Users && sudo ln -s [actual_user] jklein`
- Private environment configurations (Alfred, Sequel Pro, etc.) are stored separately in `environment_configurations` repo
- Tmux config based on [oh-my-tmux](https://github.com/gpakosz/.tmux)
- Show hidden files in Finder: `defaults write com.apple.Finder AppleShowAllFiles true && killall Finder`
