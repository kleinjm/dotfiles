---
name: sync-main
description: Merge the latest origin/main into the current branch, resolve any conflicts, and verify the merged state. Pass "push" to push the branch afterwards. Use when a branch has fallen behind main, when a PR shows CONFLICTING, or before opening a PR on a long-lived branch.
user-invocable: true
arguments: "[push]"
---

You're bringing the current branch up to date with `origin/main` and resolving whatever conflicts that surfaces.

Always **merge** — never rebase. The branch may already be pushed and shared, and a merge keeps every published SHA intact.

## PHASE 0: Parse arguments

- `push` (any case) — push the branch when the merge is done and verification passes.
- No argument — merge, resolve, verify, and stop. Leave the push to the user.

Anything else: treat it as the name of the base branch to merge from (e.g. `/sync-main develop`) and say which one you used.

## PHASE 1: Preflight

Run in a **single parallel batch**:
- `git branch --show-current`
- `git status --short`
- `git rev-parse --abbrev-ref HEAD@{upstream} 2>/dev/null || true`

**If the working tree is dirty**, stop and ask before doing anything. A merge on top of uncommitted work makes conflicts nearly impossible to reason about — you can't tell which side a hunk came from. Offer to commit the changes first or stash them, and wait for the answer. Do not stash silently.

**If already on `main`**, there is nothing to sync. Say so and stop.

## PHASE 2: Fetch

```bash
git fetch origin main
```

Fetch the remote ref only, and merge `origin/main` in the next phase. Do **not** use the `main:main` refspec: in a git worktree — which this project uses heavily — updating the local `main` branch fails outright when another worktree has it checked out.

If `git merge-base --is-ancestor origin/main HEAD` succeeds, the branch already contains main. Report "already up to date" and stop (still push if `push` was passed and the branch is ahead of its upstream).

## PHASE 3: Merge

```bash
git merge origin/main
```

**Clean merge** → straight to Phase 5.

**Conflicts** → Phase 4.

## PHASE 4: Resolve conflicts

`git status --short` lists conflicted paths with `UU` (both modified), `AA` (both added), `DU`/`UD` (delete/modify).

For each conflicted file:

1. **Read the whole conflicted region, plus enough surrounding code to understand both sides.** `git log --oneline -3 origin/main -- <path>` tells you what main was doing there and usually explains the other side's intent in one line.
2. **Preserve both intents.** This is the whole job. A conflict is two changes that touched the same lines, and the resolution almost always keeps *both* — main's new method alongside your changed line, both new config entries, both test cases. Reaching for `--ours` or `--theirs` wholesale discards someone's work silently and is nearly always wrong.
3. **Never leave a conflict marker.** After resolving, grep the file for `<<<<<<<`, `=======`, `>>>>>>>`.
4. `git add <path>`.

**When you genuinely can't tell which side should win** — the two changes are semantically incompatible, not merely adjacent — stop and ask the user, showing both sides. Guessing here silently reverts someone's deliberate change.

Once every path is staged:

```bash
git commit --no-edit
```

Keep the default merge message. Do not add issue references (see the repo's commit conventions).

### If a pre-commit hook blocks the merge commit

Check *which file* failed. A hook that fails on a file the merge merely dragged in from main — one you never touched, already failing on main — is not your commit's problem, and `git commit --no-verify --no-edit` is the right call. Say you did it and why.

If the hook fails on a file **you resolved**, that's a real failure. Fix it and commit normally.

## PHASE 5: Verify the merged state

A merge that resolves cleanly can still be semantically broken — each side was tested alone, never together. Before reporting success (and always before pushing):

1. Run the tests covering **both** sides of every conflicted file: your branch's specs for that code *and* the specs main added or changed for it. `git diff HEAD~1 --stat` on the merge commit shows what main brought in.
2. For a clean merge with no conflicts, run the specs covering the files main changed that your branch also touches. If the two sets of changed files don't overlap at all, say so and skip.
3. Lint anything you hand-resolved.

Follow the project's own commands (in this repo, `CLAUDE.md` — prefer `parallel_rspec` for several files, and note that parallel workers get their own databases while a plain `rspec` run shares the primary test DB with any other run on the machine).

**If verification fails**, fix it before pushing. A failure caused by the merge is exactly what this phase exists to catch.

## PHASE 6: Push (only with the `push` argument)

```bash
git push
```

Never `--force` or `--force-with-lease` from this skill — a merge never needs it, and a rejected push means something you don't understand yet happened on the remote. Surface the rejection and stop.

If the branch has no upstream, use `git push -u origin HEAD`.

## PHASE 7: Report

Keep it short:
- What came in from main (commit count, and the notable ones if any conflicted).
- Each conflict and how you resolved it — one line each, stating what you kept from both sides.
- Verification result: what you ran, what passed.
- Whether it was pushed.

If the branch has an open PR whose CI never ran because GitHub reported it `CONFLICTING`, mention that the merge should let CI start now — that's the usual reason for running this.
