# DevPod Configuration

Personal dotfiles for DevPod development containers.

## Setup

1. Copy `setup.local.sh` to the web repo:
   ```bash
   cp ~/.dotfiles/devpod/setup.local.sh /path/to/web/.devcontainer-devpod/setup.local.sh
   ```

2. Recreate the DevPod container:
   ```bash
   bin/dpod recreate
   ```

The setup runs automatically via the `setup.local.sh` hook in the devcontainer.

## Files

| File | Purpose |
|------|---------|
| `setup.local.sh` | Bootstrap script - copy to web repo |
| `bootstrap.sh` | Clones dotfiles and runs setup.sh |
| `setup.sh` | Symlinks configs to home directory |
| `zshrc` | Zsh configuration (symlinked to ~/.zshrc) |
| `zprofile` | Zsh profile (symlinked to ~/.zprofile) |
| `zellij/` | Zellij configs and layouts |

## How It Works

1. DevPod runs `.devcontainer-devpod/setup.sh` after container creation
2. `setup.sh` checks for `setup.local.sh` and runs it
3. `setup.local.sh` curls and runs `bootstrap.sh`
4. `bootstrap.sh` clones dotfiles to `~/.dotfiles`
5. `setup.sh` symlinks configs to the right locations
