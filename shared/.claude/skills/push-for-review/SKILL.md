---
name: push-for-review
description: Push the current branch and return a GitHub compare link against the base branch (which may differ from main) so the user can review the diff before opening a PR. If currently on main, cut a new branch first. Pre-step to /draft-pr.
user-invocable: true
arguments: "[branch_name]"
---

You're pushing the current code to the remote and returning a GitHub compare link the user can click to review the diff. This is the pre-step to `/draft-pr` — no PR is opened here.

## PHASE 1: Determine current and base branch

Run in parallel:
- `git branch --show-current` — current branch
- `git rev-parse --abbrev-ref HEAD@{upstream} 2>/dev/null || true` — tracked upstream, if any
- `gh repo view --json defaultBranchRef -q .defaultBranchRef.name` — repo default branch (usually `main` or `master`)

**Determine the base branch** for the compare link:
1. If the user passed a base via a previous message or arguments, use it.
2. Else if the current branch's tracked upstream is a non-default branch on the same repo (e.g., a stacked branch), use that as base.
3. Else use the repo's default branch.

If the determination is ambiguous (e.g., the upstream is a feature branch that itself isn't merged), state your guess in one sentence and ask the user to confirm before pushing.

## PHASE 2: Cut a branch if on the default branch

If `current_branch == default_branch`:
- If the user provided a branch name as an argument, use it.
- Otherwise propose a short kebab-case branch name derived from the staged/unstaged changes (`git status --short` + `git diff --stat`) and ask the user to confirm or override before creating it.
- Create the branch with `git checkout -b <name>`. Do NOT commit anything new — only switch branches.

If the working tree has uncommitted changes, do NOT commit them yourself. Tell the user what's uncommitted and ask whether to (a) abort, (b) push only what's already committed, or (c) wait for them to commit first. Default to (c).

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

Resolve `<OWNER>/<REPO>` from `gh repo view --json nameWithOwner -q .nameWithOwner`.

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
