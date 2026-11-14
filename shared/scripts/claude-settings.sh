#!/usr/bin/env bash
# Writes Claude Code's settings.json: shared/.claude/settings.base.json deep-merged
# with one machine's overlay, overlay keys winning. Rerun after editing either.
#   claude-settings.sh <overlay.json> <destination>
set -euo pipefail
dotfiles="$(cd "$(dirname "$0")/../.." && pwd)"
overlay="$1" dest="$2"
[ -L "$dest" ] && rm "$dest"
jq -s '.[0] * .[1]' "${dotfiles}/shared/.claude/settings.base.json" "$overlay" > "${dest}.tmp"
mv "${dest}.tmp" "$dest"
