---
name: push-for-review
description: Push the current branch and return a GitHub compare link against the base branch (which may differ from main) so the user can review the diff before opening a PR. If currently on main, cut a new branch first. Pre-step to /draft-pr.
user-invocable: true
arguments: "[branch_name]"
---

You're pushing the current code to the remote and returning a GitHub compare link the user can click to review the diff. This is the pre-step to `/draft-pr` — no PR is opened here.

## PHASE 1: Determine current and base branch

Run all of these in a **single parallel batch** (one message, multiple tool calls — never one-at-a-time):
- `git branch --show-current` — current branch
- `git rev-parse --abbrev-ref HEAD@{upstream} 2>/dev/null || true` — tracked upstream, if any
- `git status --short` and `git diff --stat` — so you already have what you need for Phase 2/2.5 without a second round-trip
- `gh repo view --json defaultBranchRef,nameWithOwner` — repo default branch **and** `owner/repo` in one call (used again in Phase 4; do not call `gh repo view` a second time)

**Determine the base branch** for the compare link:
1. If the user passed a base via a previous message or arguments, use it.
2. Else if the current branch's tracked upstream is a non-default branch on the same repo (e.g., a stacked branch), use that as base.
3. Else use the repo's default branch.

If the determination is ambiguous (e.g., the upstream is a feature branch that itself isn't merged), state your guess in one sentence and ask the user to confirm before pushing.

## PHASE 2: Cut a branch if on the default branch — do not block on the user

If `current_branch == default_branch`:
- If the user provided a branch name as an argument, use it.
- Otherwise derive a short kebab-case branch name from the changes (`git status --short`, `git diff --stat`, and the conversation context). Use your best judgment — do NOT ask the user to confirm. Inform them of the name you chose in one line.
- Create the branch with `git checkout -b <name>`.

## PHASE 2.5: Commit uncommitted work — do not block on the user

If the working tree has staged or unstaged changes that relate to the work this session has been doing, commit them yourself before pushing. Use your best judgment:

- Stage the relevant files explicitly by name (never `git add -A` / `git add .` — avoid pulling in unrelated local junk, secrets, or large binaries).
- If multiple unrelated changes are present, split them into separate commits with focused messages. If they're all part of one coherent change, a single commit is fine.
- Write commit messages that follow the project's recent style (`git log -5 --oneline` to check). Specific verbs ("add", "fix", "update", "refactor"); no issue references in the commit message itself.
- If there are clearly out-of-scope local files (e.g., a stray scratch file, an unrelated config tweak the user didn't ask for), leave them uncommitted and mention them in the final output so the user knows they weren't pushed.

Do NOT pause to ask the user whether to commit. The whole point of this skill is to be a fast pre-PR push — your job is to make a reasonable call and proceed.

## PHASE 3: Push

Push the current branch to `origin` with upstream tracking if it has none:

```bash
git push -u origin HEAD
```

If the branch already has an upstream, just `git push`. Never use `--force` or `--force-with-lease` from this skill — if the push is rejected, surface the rejection to the user and stop.

## PHASE 4: Return the compare link

Construct a GitHub compare URL against the chosen base:

```
https://github.com/<OWNER>/<REPO>/compare/<BASE>...<HEAD_BRANCH>
```

Use the `nameWithOwner` you already fetched in Phase 1 for `<OWNER>/<REPO>` — do not call `gh repo view` again.

Output a single short message containing:
1. The base branch used (so the user can spot if it's wrong).
2. The compare link.
3. A one-line reminder that they can run `/draft-pr` next to open a draft PR.

Example output:

> Pushed `feat/foo-bar`. Compare against `main`:
> https://github.com/EscrowSafe/web/compare/main...feat/foo-bar
>
> Run `/draft-pr` to open a draft PR from this branch.

Keep the response to that — no extra commentary, no summary of changes.
