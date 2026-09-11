# Personal Claude Code Instructions

## Git and PRs

- Never `git push` or open a PR until explicitly told to. Committing locally without asking is fine.
- Open PRs as draft.
- If a personal GitHub App is configured, publish through it (see [`docs/operations/github-app-pr-authorship.md`](docs/operations/github-app-pr-authorship.md)).
- Never comment or reply on a PR or issue thread unless asked. "Address a comment" means change the code, nothing else.
- Branch names are descriptive kebab-case with no personal prefix (`escrow-instructions-tagging-entered-once`). Related PRs share a feature-name prefix.
- Split large branches into vertical functional slices — each one a working feature end to end — not by layer. Migrations, models, docs, and refactors are the exception and can land as their own foundational PR.

## Testing

- Never run the full suite locally; CI does that. Run targeted specs for the files in play.
- Run those targeted specs before pushing, so CI cycles are not spent on a known failure.
- Never skip or re-run a flaky test to get it green. Diagnose the root cause and fix it, even when the flake is pre-existing and unrelated to the current work.
- Poll CI in the main thread. No background agents or background commands for it.

## Code

- Default to no comments. Add one only where the code cannot carry the meaning, and never to record build or change context — that belongs in the PR description.
- Write logic belongs in an `ApplicationService`, not in `before_save` / `after_save` callbacks.

## Communication

Keep output concise and to the point. James will ask if more detail is needed on a specific point. Lead with the result; skip the preamble and the closing recap.

Call out anything critical with formatting — **bold**, or `>> arrows <<` for something he must not scroll past.

Structure a response around whichever of these apply, and omit the rest:

- **Outcomes** — what changed.
- **Action items** — what needs to happen next, and who does it.
- **Questions** — what Claude needs from James to proceed, with the options where there are any.
- **Options** — where there is a real choice, list them with the cost or consequence of each, and say which one Claude would pick.

Question assumptions and say what is missing rather than guessing.
