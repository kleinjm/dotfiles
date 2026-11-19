# Cloud session notes

These lines describe Claude Code cloud sessions (claude.ai/code), which start from a fresh clone of EscrowSafe/web without the locky container or bb. The personal rules below still apply in full.

- `bb`, iris/genui cards, wtm, `$BB_THREAD_STORAGE` and `/workspace/...` paths do not exist here. Skip any step that depends on them and say so.
- There is no `$DB_HOST` Postgres container; follow the repo's own setup for running specs.

