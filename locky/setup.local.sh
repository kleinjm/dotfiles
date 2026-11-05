#!/usr/bin/env bash
# Personal boot hook for the locky container. Symlink it into the web repo,
# where it is git-ignored and run on every container start:
#
#   ln -s /workspace/dotfiles/locky/setup.local.sh /workspace/web/.locky/setup.local.sh
#
# Home is the container's writable layer, so a recreate drops what this writes
# and the next boot writes it again. Keep every step idempotent.
set -euo pipefail

dotfiles=/workspace/dotfiles
data_dir="${DATA_DIR:-/workspace/docker-data}"

line="source ${dotfiles}/locky/shell.zsh"
grep -qxF "$line" ~/.zshrc 2>/dev/null || echo "$line" >>~/.zshrc

autosuggest="${data_dir}/zsh/zsh-autosuggestions"
if [ ! -d "$autosuggest" ]; then
  mkdir -p "$(dirname "$autosuggest")"
  git clone -q --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$autosuggest" ||
    echo "zsh-autosuggestions clone failed; retrying next boot" >&2
fi

# Config only. Sessions, history and credentials stay in the container's own
# ~/.claude, so the Mac and the container never write the same state files.
# settings.local.json is Mac-only: it allows Bash(*).
claude_src="${dotfiles}/shared/.claude"
claude_dst="${HOME}/.claude"
mkdir -p "${claude_dst}/skills"
link() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "${dst}.pre-dotfiles"
  fi
  ln -sfn "$src" "$dst"
}
link "${claude_src}/settings.json" "${claude_dst}/settings.json"
link "${claude_src}/statusline-command.sh" "${claude_dst}/statusline-command.sh"
link "${claude_src}/agents" "${claude_dst}/agents"
link "${claude_src}/commands" "${claude_dst}/commands"
# skills/synced is each environment's own claude.ai sync bucket; never link it.
for skill in "${claude_src}"/skills/*/; do
  name="$(basename "$skill")"
  [ "$name" = synced ] && continue
  link "${skill%/}" "${claude_dst}/skills/${name}"
done

# Orchestrator instructions for the control thread. bb reads
# <workspace-root>/.bb/AGENTS.md for every thread rooted there and does not walk
# parent directories, so this reaches the orchestrator thread (rooted at the main
# checkout) and no worktree thread. Copy, never symlink: a symlinked .bb/AGENTS.md
# broke bb on 2026-10-28. It stays untracked via .git/info/exclude so it is never
# committed and fresh worktrees never inherit it.
web=/workspace/web
if [ -d "$web/.git" ]; then
  mkdir -p "$web/.bb"
  cp --remove-destination "${dotfiles}/locky/orchestrator/AGENTS.md" "$web/.bb/AGENTS.md"
  grep -qxF '.bb/' "$web/.git/info/exclude" 2>/dev/null || echo '.bb/' >>"$web/.git/info/exclude"
fi

# Editor: nvim reuses the shared vim config and Vundle bundles, with locky
# overrides (rg instead of ag) in locky/vim/vimrc.
link "${dotfiles}/locky/vim/vimrc" "${HOME}/.vimrc"
link "${dotfiles}/shared/vim/.vim" "${HOME}/.vim"
mkdir -p "${HOME}/.config/nvim"
link "${dotfiles}/locky/vim/init.vim" "${HOME}/.config/nvim/init.vim"

# fzf for the shell. Personal, so installed outside the image's mise config:
# `mise use -g` would write into the shared /opt/mise/config.toml.
fzf_version=0.74.5
if mise install -q "fzf@${fzf_version}" 2>/dev/null; then
  mkdir -p "${HOME}/.local/bin"
  ln -sfn "$(mise where "fzf@${fzf_version}")/fzf" "${HOME}/.local/bin/fzf"
else
  echo "fzf install failed; retrying next boot" >&2
fi

# Git aliases and preferences. include.path stacks on the identity 60-git writes.
git config --global --get-all include.path 2>/dev/null | grep -qxF "${dotfiles}/locky/gitconfig" ||
  git config --global --add include.path "${dotfiles}/locky/gitconfig"

# Host credentials kept from the devpod era, reached through the /workspace bind
# mount rather than extra compose mounts.
devpod_data=/workspace/devpod-data
[ -d "${devpod_data}/aws" ] && link "${devpod_data}/aws" "${HOME}/.aws"
[ -f "${devpod_data}/rollbar/.rollbar-mcp.json" ] &&
  link "${devpod_data}/rollbar/.rollbar-mcp.json" "${HOME}/.rollbar-mcp.json"

if command -v claude >/dev/null 2>&1 && ! claude mcp get rollbar >/dev/null 2>&1; then
  claude mcp add --scope user rollbar -- npx -y @rollbar/mcp-server@latest >/dev/null ||
    echo "Rollbar MCP registration failed; retrying next boot" >&2
fi
