---
name: sync-main
description: Merge the latest origin/main into the current branch, resolve any conflicts, and verify the merged state. If the branch is stacked on another branch, syncs the whole stack from main upwards. Pass "push" to push the branches afterwards. Use when a branch has fallen behind main, when a PR shows CONFLICTING, or before opening a PR on a long-lived branch.
user-invocable: true
arguments: "[push]"
---

You're bringing the current branch up to date with `origin/main` and resolving whatever conflicts that surfaces.

If the current branch is **stacked** — its PR targets a branch other than `main` — you're syncing the entire stack: main into the bottom branch, then each branch into the one above it, up to the current branch. A sync that only touches the top branch is useless there: it pulls main's commits in past the branches below, so every PR in the stack shows a diff full of main's changes.

Always **merge** — never rebase. The branch may already be pushed and shared, and a merge keeps every published SHA intact.

## PHASE 0: Parse arguments

- `push` (any case) — push each branch you touched when the merges are done and verification passes.
- No argument — merge, resolve, verify, and stop. Leave the push to the user.

Anything else: treat it as the name of the root branch to merge from (e.g. `/sync-main develop`) and say which one you used. Everywhere below that says `main`, use that branch instead.

## PHASE 1: Preflight

Run in a **single parallel batch**:
- `git branch --show-current`
- `git status --short`
- `git rev-parse --abbrev-ref HEAD@{upstream} 2>/dev/null || true`

**If the working tree is dirty**, stop and ask before doing anything. A merge on top of uncommitted work makes conflicts nearly impossible to reason about — you can't tell which side a hunk came from. Offer to commit the changes first or stash them, and wait for the answer. Do not stash silently.

**If already on `main`**, there is nothing to sync. Say so and stop.

## PHASE 1.5: Discover the stack

The current branch may be stacked on another branch rather than on `main`. Find out before merging anything.

```bash
gh pr view <branch> --json baseRefName,number,title -q '.baseRefName'
```

Walk downwards: ask for the current branch's base; if that base isn't `main`, ask for *its* base; repeat until you reach `main` or a branch with no PR. Guard the walk — if you revisit a branch you've already seen, the chain is cyclic; stop and report it rather than looping.

Order the result bottom-up, so `main` is first and the branch you started on is last. That list is the **stack**.

- **No PR for the current branch, or its base is `main`** → the stack is just `[main, current]`. This is the ordinary case; the phases below collapse to a single merge and read exactly as they did before.
- **A base branch exists only on the remote** (no local branch) → that's fine, merge `origin/<base>` into the branch above it. Never check out or create a local branch to do this.

Fetch every branch in the stack in one go, and confirm each one is where you think it is:

```bash
git fetch origin main <base-1> <base-2> ...
```

State the stack you found before you start merging — `main → feature-a → feature-b (current)` — so the user can stop you if it's wrong.

**If any branch in the stack other than the current one is checked out in another worktree**, you can still merge *from* it (you only ever read `origin/<branch>`), but say so: the local checkout there will be behind after this.

## PHASE 2: Fetch

Already done in Phase 1.5 if you fetched the stack there; otherwise:

```bash
git fetch origin main
```

Fetch the remote refs only, and merge `origin/<branch>` in the next phase. Do **not** use the `main:main` refspec: in a git worktree — which this project uses heavily — updating a local branch fails outright when another worktree has it checked out.

For each pair in the stack, `git merge-base --is-ancestor origin/<lower> <upper>` tells you whether that merge is a no-op. If **every** pair is already an ancestor, the whole stack is up to date. Report "already up to date" and stop (still push if `push` was passed and a branch is ahead of its upstream).

## PHASE 3: Merge

Work **bottom-up**, one pair at a time: merge each branch's base into it, finishing that branch completely (resolve, commit, and push if `push` was passed) before moving to the branch above it. Pushing as you go is what makes the next merge see the resolved state and keeps each PR's diff clean.

For each step, with `<lower>` the branch below and `<upper>` the branch above:

```bash
git checkout <upper>          # skip if already there
git merge origin/<lower>
```

Merge `origin/<lower>` — the pushed state — not the local branch, so every stack member merges the same commits the PRs are built on. This is why each branch has to be pushed before the one above it merges from it; if `push` wasn't passed, merge the local `<lower>` you just committed instead, and say that the stack is resolved locally but unpushed.

Remember which branch you started on and `git checkout` back to it at the end, whatever happens.

**Clean merge** → next pair, then Phase 5.

**Conflicts** → Phase 4, then continue with the next pair.

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

Verify **once, on the top branch**, after the whole stack is merged — that's the state that has to work. The lower branches are checkpoints on the way there, and re-running the suite at each level costs far more than it catches.

1. Run the tests covering **both** sides of every conflicted file, across every merge in the stack: your branches' specs for that code *and* the specs main added or changed for it. `git diff HEAD~1 --stat` on each merge commit shows what came in.
2. For a clean merge with no conflicts, run the specs covering the files main changed that the stack also touches. If the two sets of changed files don't overlap at all, say so and skip.
3. Lint anything you hand-resolved.

Follow the project's own commands (in this repo, `CLAUDE.md` — prefer `parallel_rspec` for several files, and note that parallel workers get their own databases while a plain `rspec` run shares the primary test DB with any other run on the machine).

**If verification fails**, fix it before pushing. A failure caused by the merge is exactly what this phase exists to catch.

## PHASE 6: Push (only with the `push` argument)

```bash
git push
```

Push each branch you merged into, bottom-up, as you finish it in Phase 3 — not all at once at the end. Never `--force` or `--force-with-lease` from this skill — a merge never needs it, and a rejected push means something you don't understand yet happened on the remote. Surface the rejection and stop.

If a branch has no upstream, use `git push -u origin HEAD`.

A rejected push part-way up the stack leaves the stack half-synced. Stop there, report which branches made it and which didn't, and don't merge the remaining pairs — they'd be built on a base you couldn't publish.

## PHASE 7: Report

Keep it short:
- The stack, if there was one: `main → feature-a → feature-b`.
- What came in from main (commit count, and the notable ones if any conflicted), per branch when the stack has more than one.
- Each conflict and how you resolved it — one line each, stating what you kept from both sides and which branch it was on.
- Verification result: what you ran, what passed.
- Which branches were pushed.

If a branch has an open PR whose CI never ran because GitHub reported it `CONFLICTING`, mention that the merge should let CI start now — that's the usual reason for running this.
