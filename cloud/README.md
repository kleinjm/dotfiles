# Claude Code cloud sessions

`setup.sh` installs the cloud-compatible part of my personal Claude Code config into `~/.claude` in claude.ai/code sessions for EscrowSafe/web. It is idempotent and holds no secrets; this repo is public, so it is fetched anonymously.

## What it installs

- Skills: `flaky-test`, `push-for-review`
- Agents: `context-fetcher`, `date-checker`, `file-creator`, `git-workflow`, `test-runner`
- `~/.claude/CLAUDE.md`: `CLAUDE.cloud.md` + `shared/.claude/CLAUDE.md` + `shared/.claude/project-local/web.CLAUDE.local.md`
- `settings.cloud.json` merged into `~/.claude/settings.json`

Left out, because they need bb, iris/genui, wtm or the locky container: `land-pr`, `standup`, `work-overview`, `wtm-cloud`, `locky/orchestrator`, the Agent OS commands (need `~/.agent-os`), and the rest of `settings.base.json` (local paths, wtm/bb permissions, statusline).

## Environment

Sessions run on my personal **Default** environment (`env_017wUKcppWXDBZS9c1ojhuzN`). **Org Default** is shared by the whole org: never put personal setup there.

`claude --cloud` (and so `bb wtm cloud start`) picks the environment from `remote.defaultEnvironmentId`, set with `/remote-env` and kept in `shared/.claude/settings.base.json`. Choosing an environment in the web UI does not change it.

Setup script in the personal Default environment:

```bash
#!/bin/bash
for d in "$PWD" "${CLAUDE_PROJECT_DIR:-}" "$HOME"/* /home/*/* /workspace/*; do
  if [ -f "$d/bin/setup_cloud.sh" ] || [ -f "$d/bin/setup_cloud_ruby.sh" ]; then
    cd "$d" || exit 1
    break
  fi
done
if [ -f bin/setup_cloud.sh ]; then
  bash bin/setup_cloud.sh || echo "Cloud provisioning failed — see output above."
elif [ -f bin/setup_cloud_ruby.sh ]; then
  bash bin/setup_cloud_ruby.sh || echo "Ruby provisioning failed — see output above."
else
  echo "No cloud setup script found in $PWD — skipping."
fi

curl -fsSL https://raw.githubusercontent.com/kleinjm/dotfiles/main/cloud/setup.sh | bash
```

The repo is cloned to `/home/user/web`, not `/workspace`. If the loop misses it, the repo setup is skipped silently and sessions start on the image's Ruby 3.3 and Node 22. Network access must allow `github.com` and `raw.githubusercontent.com`.

## Verifying a change

`setup.sh` runs from `main`, so push first. Then start a read-only session and read its answer on claude.ai (the CLI can't read cloud transcripts):

```bash
cd /workspace/web
bb wtm cloud start --task 'Verification only: do not edit, commit, push or open a PR. Report ruby -v, node -v, the first 5 lines of ~/.claude/CLAUDE.md, ls ~/.claude/skills ~/.claude/agents, git -C ~/.dotfiles log --oneline -1, and the result of bundle exec rspec spec/models/vehicle_spec.rb.'
```
