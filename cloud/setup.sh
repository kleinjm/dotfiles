#!/usr/bin/env bash
# Installs James's cloud-compatible personal Claude Code config into ~/.claude.
# claude.ai cloud environment setup script:
#   curl -fsSL https://raw.githubusercontent.com/kleinjm/dotfiles/main/cloud/setup.sh | bash
# Idempotent: safe to run on every session start. Contains no secrets.
set -euo pipefail

REPO_URL="${DOTFILES_REPO_URL:-https://github.com/kleinjm/dotfiles.git}"
DEST="${DOTFILES_CLOUD_DIR:-$HOME/.dotfiles}"
CLAUDE_DIR="$HOME/.claude"

if [ -d "$DEST/.git" ]; then
  git -C "$DEST" fetch --quiet --depth 1 origin main
  git -C "$DEST" reset --quiet --hard FETCH_HEAD
else
  git clone --quiet --depth 1 "$REPO_URL" "$DEST"
fi

mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents"

# Skills that work without bb, wtm or the locky container.
for skill in flaky-test push-for-review; do
  rm -rf "${CLAUDE_DIR:?}/skills/$skill"
  cp -R "$DEST/shared/.claude/skills/$skill" "$CLAUDE_DIR/skills/$skill"
done

# Subagents: plain prompts with no local tooling.
for agent in context-fetcher date-checker file-creator git-workflow test-runner; do
  cp "$DEST/shared/.claude/agents/$agent.md" "$CLAUDE_DIR/agents/$agent.md"
done

# User-level CLAUDE.md. The cloud sandbox has no project checkout to carry a
# CLAUDE.local.md, so everything has to be concatenated into the user file:
# cloud notes, the generic preferences, then web's project rules.
cat "$DEST/cloud/CLAUDE.cloud.md" \
  "$DEST/shared/.claude/CLAUDE.md" \
  "$DEST/shared/.claude/project-local/web.CLAUDE.local.md" \
  > "$CLAUDE_DIR/CLAUDE.md"

# Settings: merge the portable preferences into whatever the image already has.
SETTINGS="$CLAUDE_DIR/settings.json"
[ -s "$SETTINGS" ] || echo '{}' > "$SETTINGS"
python3 - "$SETTINGS" "$DEST/cloud/settings.cloud.json" <<'PY'
import json, sys
path, overlay = sys.argv[1], sys.argv[2]
with open(path) as f:
    data = json.load(f)
with open(overlay) as f:
    data.update(json.load(f))
with open(path, "w") as f:
    json.dump(data, f, indent=2)
PY

echo "dotfiles cloud setup: $(git -C "$DEST" rev-parse --short HEAD) installed into $CLAUDE_DIR"
