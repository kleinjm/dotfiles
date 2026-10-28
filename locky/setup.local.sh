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
