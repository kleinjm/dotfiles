# Personal Claude Code Instructions — web

Generic preferences (communication, code style, git basics) live in
`dotfiles/shared/.claude/CLAUDE.md` and load in every session. This file is
only what is specific to this repository: its review bots, its PR workflow and
its test commands.

## Git and PRs

- **Open PRs ready for review, not as a draft.** This overrides the draft default in `.agents/skills/create-pr/SKILL.md` (step 8's `gh pr create --draft` and step 9's "leave the PR as a draft"). Drop `--draft`, and do not ask whether to mark it ready.
- **Bot reviews are pre-approved for me — never block on asking.** This overrides the per-request yes in `create-pr` steps 8, 9 and 10 and in `cr-feedback-review`:
  - **CodeRabbit** reviews automatically once the PR is open and ready, so do not post `@coderabbitai review` on the first round. Post it only to ask for a re-review after a fix push, and `@coderabbitai full review` only after a base merge or a rewrite. Never post `@coderabbitai approve` or `@coderabbitai resolve` yourself: approving is a human call. Keep the two-round cap as the skill has it; do not spend a third round to clear nits. When CodeRabbit still withholds approval after the cap, stop and tell me so I can decide whether to post `@coderabbitai approve` myself.
  - **Copilot**: request it without asking (`gh pr edit <PR-NUMBER> --add-reviewer @copilot`, as me, never with `GH_TOKEN`) whenever the `Risk` tags include `auth`, `pii`, or `credentials` — the bottom row of the step 8 table. For any other tag set, skip Copilot and say which tags decided it, as the table already specifies. Re-request on later rounds under the same rule.
  - Report each request and its outcome; I will override in one line when I want the other call.
- Exception to the global "never comment on a PR thread unless asked": top-level PR comments that are commands to CodeRabbit (`@coderabbitai review` and the like) are fine unprompted, and on bot-authored review threads (CodeRabbit, Copilot) reply and resolve without asking, as `cr-feedback-review` does — a short reply saying what changed or why a finding is declined, then resolve. Human-authored threads stay untouched.
- **PR description approval is waived for me.** This overrides the approval gate in `AGENTS.md`, `CLAUDE.md`, and `.agents/skills/create-pr/SKILL.md` (Phase 6 and the checklist line). Once I have told you to open a PR, write the title and body and open it without pausing for sign-off, then print what you used so I can edit it. This waives the description review only — "never push or open a PR until told" still stands.
- Issue and PR links for this repo: `[#5841](https://github.com/EscrowSafe/web/pull/5841)`.

## Testing

- Never run the full suite locally; CI does that. Run targeted specs for the files in play.
- Run those targeted specs before pushing, so CI cycles are not spent on a known failure.
- Never skip or re-run a flaky test to get it green. Diagnose the root cause and fix it, even when the flake is pre-existing and unrelated to the current work.
- Poll CI in the main thread. No background agents or background commands for it.

## Code

- Write logic belongs in an `ApplicationService`, not in `before_save` / `after_save` callbacks.
