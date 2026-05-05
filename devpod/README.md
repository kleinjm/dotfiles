# DevPod Configuration

Personal dotfiles for DevPod development containers.

## Which script do I run?

| Situation | Run | What happens |
|-----------|-----|--------------|
| Brand new container, dotfiles aren't on disk yet | `install.sh` | Clones (or symlinks to `/workspaces/dotfiles`) into `~/.dotfiles`, then calls `link.sh` |
| Container restarted, dotfiles already on disk | `link.sh` | Re-symlinks all the configs into `~` (idempotent, safe to re-run anytime) |

`install.sh` is also safe to re-run — it just delegates to `link.sh` once the repo is in place. If in doubt, run `install.sh`.

## One-time setup (per machine)

1. Copy `setup.local.sh` into the web repo (this is the only file you need
   to copy by hand — `compose.override.yaml` is kept in sync automatically
   by `install.sh`, see below):
   ```bash
   cp ~/.dotfiles/devpod/setup.local.sh /path/to/web/.devcontainer/setup.local.sh
   ```

2. Recreate the DevPod container:
   ```bash
   bin/dpod recreate
   ```

After that, `setup.local.sh` runs automatically when the container is
created and curls `install.sh` from GitHub. `install.sh` then writes
`compose.override.yaml` into `web/.devcontainer/` from the dotfiles
template — so any time you update the template here, the next container
recreate picks up the change.

## Files

| File | Purpose |
|------|---------|
| `install.sh` | First-run entry point. Sets up `~/.dotfiles`, syncs `compose.override.yaml` into the web repo, calls `link.sh`. |
| `link.sh` | Symlinks configs into `~`. Run this on container restart. |
| `setup.local.sh` | DevPod hook (must keep this name). Curls `install.sh` from GitHub. Copy to web repo once. |
| `compose.override.yaml` | Docker Compose overrides. Master copy lives here; `install.sh` syncs it into the web repo. |
| `zshrc` | Zsh configuration (symlinked to `~/.zshrc`) |
| `zprofile` | Zsh profile (symlinked to `~/.zprofile`) |
| `aliases.zsh` | Shell aliases (sourced by zshrc) |
| `functions.zsh` | Shell functions (sourced by zshrc) |
| `git/.gitconfig` | Git config with aliases (symlinked to `~/.gitconfig`) |
| `zellij/` | Zellij configs and layouts |
| `tmux/` | Tmux config and tmuxinator project configs |
| `vim/` | Vim config (sources `shared/.vimrc`) |
| `nvim/` | Neovim config (reuses vim setup) |

## How it works (initial container creation)

1. DevPod runs the web repo's `.devcontainer/setup.sh` after the container is created.
2. That script invokes `setup.local.sh` (the user-customizable hook).
3. `setup.local.sh` curls `install.sh` from this repo on GitHub.
4. `install.sh`:
   - Sets up `~/.dotfiles` — symlink to `/workspaces/dotfiles` if present, else clone from GitHub.
   - Syncs `devpod/compose.override.yaml` into `web/.devcontainer/compose.override.yaml` so the next recreate picks up any changes.
   - Pre-creates `~/GitHubRepos/devpod-data/gh` on the host (visible at `/workspaces/devpod-data/gh` from inside the container).
   - Calls `link.sh`.
5. `link.sh` symlinks every config into `~`.

On restart, `~/.dotfiles` is already set up (it's the persisted workspace mount), so just running `link.sh` is enough to relink the home-directory configs. Run `install.sh` again only when you want to re-sync the compose override into the web repo.

## Claude Code Config

The devpod container mounts `devpod-data/claude` as `~/.claude` (see `compose.yaml`). On the host Mac, this directory should be a symlink to the shared dotfiles config so both environments use the same settings:

```bash
# From your host Mac (one-time setup)
ln -sf ~/GitHubRepos/dotfiles/shared/.claude ~/GitHubRepos/devpod-data/claude
```

## SSH Keys for GitHub (push/pull AND commit signing)

The same SSH key is used for both git transport and commit signing. Copy it to the persistent volume so it's mounted into every container:

```bash
# From your host Mac
cp ~/.ssh/id_ed25519 /path/to/devpod-data/ssh/
cp ~/.ssh/id_ed25519.pub /path/to/devpod-data/ssh/
chmod 600 /path/to/devpod-data/ssh/id_ed25519
```

The `devpod-data` directory is a sibling to the web repo (e.g., `~/GitHubRepos/devpod-data/`). The SSH agent starts automatically on shell startup via `zshrc`.

### Commit signing (SSH, not GPG)

Git is configured to sign commits with `~/.ssh/id_ed25519.pub` (see `git/.gitconfig` — `gpg.format = ssh`). This avoids the GPG socket headaches that plague bind-mounted `~/.gnupg` directories.

For GitHub to verify signatures as **Verified**, register the same `id_ed25519.pub` as a *Signing Key* (separate list from authentication keys):

1. Go to https://github.com/settings/ssh/new
2. Set **Key type** to `Signing Key`
3. Paste the contents of `id_ed25519.pub`

Test it from inside the container:
```bash
git commit --allow-empty -m "test ssh signing" && git log --show-signature -1
```
You should see `Good "git" signature ...`.

## GitHub CLI (`gh`) auth persistence

`gh` stores its auth token at `~/.config/gh/hosts.yml`. Without persistence,
that file is wiped on container restart and you'd have to re-run
`gh auth login` every time.

`compose.override.yaml` mounts `~/GitHubRepos/devpod-data/gh` over
`~/.config/gh` in the container, so the token survives restarts.
`install.sh` creates the host directory for you, so first-time setup is
just one command after `bin/dpod recreate`:

```bash
gh auth login
```

After that, `gh` just works on every container restart.

We deliberately do **not** prompt for `gh auth login` from `link.sh` —
it's an interactive browser flow and would block startup on every restart.
Persisting the token via volume mount is the correct fix.

## Tmux

Use `bin/dpod exec` instead of `bin/dpod ssh` for tmux sessions. DevPod's SSH proxy has rendering issues with tmux pane splitting, but docker exec works correctly.

```bash
# From host Mac
bin/dpod exec

# Inside container
mux dotfiles      # Start tmuxinator dotfiles session
mux escrowsafe    # Start tmuxinator escrowsafe session
```

Tmux config uses oh-my-tmux with these key bindings:
- Prefix: `Ctrl+S`
- Split panes: `\` (horizontal), `-` (vertical)
- Navigate panes: `Ctrl+h/j/k/l` (vim-tmux-navigator)
- Resize panes: `Ctrl+arrows`
- Toggle light/dark theme: `Ctrl+S T` (light theme for outdoor use)
- Install plugins: `Ctrl+S I`

## Persistence

In DevPod environments, `~/.dotfiles` is a symlink to `/workspaces/dotfiles`, which is a persisted workspace mount. This means any changes to dotfiles persist across container restarts without needing to commit and push.
