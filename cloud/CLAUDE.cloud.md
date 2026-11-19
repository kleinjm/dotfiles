# Cloud session notes

These lines describe Claude Code cloud sessions (claude.ai/code), which start from a fresh clone of EscrowSafe/web without the locky container or bb. The personal rules below still apply in full.

- Exception to "never push or open a PR until told", approved by James on 2026-11-19: in a cloud session the task brief is the go-ahead. Push the session branch and open its PR without asking again.
- `bb`, iris/genui cards, wtm, `$BB_THREAD_STORAGE` and `/workspace/...` paths do not exist here. Skip any step that depends on them and say so.
- There is no `$DB_HOST` Postgres container; follow the repo's own setup for running specs.

