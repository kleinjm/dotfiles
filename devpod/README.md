# DevPod Configuration

Personal dotfiles for DevPod development containers.

## Setup

1. Copy `setup.local.sh` to the web repo:
   ```bash
   cp ~/.dotfiles/devpod/setup.local.sh /path/to/web/.devcontainer-devpod/setup.local.sh
   ```

2. Copy `compose.override.yaml` to the web repo:
   ```bash
   cp ~/.dotfiles/devpod/compose.override.yaml /path/to/web/.devcontainer-devpod/compose.override.yaml
   ```

3. Copy Claude settings to the web repo:
   ```bash
   cp ~/.dotfiles/devpod/claude/settings.local.json /path/to/web/.claude/settings.local.json
   ```

4. Recreate the DevPod container:
   ```bash
   bin/dpod recreate
   ```

The setup runs automatically via the `setup.local.sh` hook in the devcontainer.

## Files

| File | Purpose |
|------|---------|
| `setup.local.sh` | Bootstrap script - copy to web repo |
| `compose.override.yaml` | Docker Compose overrides (GPG mount) - copy to web repo |
| `claude/settings.local.json` | Claude Code permissions - copy to web repo |
| `bootstrap.sh` | Symlinks or clones dotfiles, runs setup.sh |
| `setup.sh` | Symlinks configs to home directory |
| `zshrc` | Zsh configuration (symlinked to ~/.zshrc) |
| `zprofile` | Zsh profile (symlinked to ~/.zprofile) |
| `aliases.zsh` | Shell aliases (sourced by zshrc) |
| `functions.zsh` | Shell functions (sourced by zshrc) |
| `git/.gitconfig` | Git config with aliases (symlinked to ~/.gitconfig) |
| `zellij/` | Zellij configs and layouts |

## How It Works

1. DevPod runs `.devcontainer-devpod/setup.sh` after container creation
2. `setup.sh` checks for `setup.local.sh` and runs it
3. `setup.local.sh` curls and runs `bootstrap.sh`
4. `bootstrap.sh` sets up `~/.dotfiles`:
   - If `/workspaces/dotfiles` exists (DevPod): symlinks `~/.dotfiles` to it
   - Otherwise: clones fresh from GitHub
5. `setup.sh` symlinks configs to the right locations

## Persistence

In DevPod environments, `~/.dotfiles` is a symlink to `/workspaces/dotfiles`, which is a persisted workspace mount. This means any changes to dotfiles persist across container restarts without needing to commit and push.
