---
name: land-pr
description: Take the current worktree branch's open PR on EscrowSafe/web all the way to merged — watch CI and bot reviews, fix failures, triage bot threads, merge through Trunk — then ask the orchestrator thread to clean up the worktree. Use when James says "land it", "land this PR", "merge this and clean up", or runs /land-pr from a worker thread.
argument-hint: "[PR number | PR URL]"
---

# Land PR

Run from a worker thread rooted in `/workspace/web-worktrees/<name>`. Ends with
the PR merged and one cleanup request sent to the orchestrator. Never cleans up
the worktree itself: the orchestrator archives this thread first, then runs
`wtm cleanup`.

**Running this skill is James's approval to merge this PR.** It overrides the
"never merge unless asked" rule in his instructions for this one PR, and also
authorizes the `/trunk merge` PR comment. Every other rule stands: no force
push, no rewriting reviewed history, no replies on human-authored threads, no
`@coderabbitai approve`.

## 1. Find the PR

    pwd                      # must be under /workspace/web-worktrees/
    basename "$PWD"          # the worktree NAME; not always the branch name
    gh pr view ${ARGUMENTS:-} --json number,url,state,headRefName,baseRefName,isDraft,reviewDecision,mergeStateStatus

Stop and tell James if: there is no open PR, the cwd is not a web worktree, the
PR's base is not `main` (a stacked PR lands after its parent), or the PR is a
draft (ask before marking it ready). If `state` is already `MERGED`, skip to
step 4.

Push any local commits first only if they are this PR's work (`git log @{u}..`);
otherwise ask.

## 2. Converge: CI and bot reviews

Poll in the foreground of this thread. No background agents, no background
commands, no Monitor — James's `CLAUDE.local.md` forbids them for CI.

Loop until CI is green on the head commit **and** no unresolved bot thread is
left:

- **CI.** `gh pr checks <n> --watch --interval 60` (foreground, with a long
  Bash timeout), or `gh run list --branch <branch>` per
  `.agents/skills/create-pr/references/ci-watch.md`. On a failure, read the log
  (`gh run view <id> --log-failed`), reproduce with targeted specs, fix, run
  those specs, commit, push.
- **Flakes.** Never re-run a job to get it green, even for a pre-existing,
  unrelated flake. Diagnose and fix the root cause (the `flaky-test` skill),
  scoped to the spec.
- **Bot reviews.** CodeRabbit and Copilot are not Actions runs (Copilot's
  request is; its review lands separately), so poll
  `gh api repos/EscrowSafe/web/pulls/<n>/reviews` and unresolved review threads
  too, for at least 10 minutes after CI goes green or until a review posts.
  When bot threads land, run `cr-feedback-review <n> auto`. It applies,
  declines, replies and resolves bot threads, and keeps the two-round cap and
  the `@coderabbitai review` re-request rules.
- **Base drift.** If GitHub reports the branch behind or conflicting, merge
  `main` in through `sync-main` (merge, never rebase). On a conflict, stop and
  show James the resolution before pushing.
- **Human threads.** Leave them alone: no reply, no resolve, no code change on
  their behalf. List each (author, file:line, link) for James in the final
  report. An unresolved human thread or a human `CHANGES_REQUESTED` review
  blocks the merge: stop and report.

Stop and hand back to James, without merging, when: CodeRabbit still withholds
approval after its round cap (he decides whether to post `@coderabbitai
approve`), a CI failure needs a product or scope decision, or the fix would
touch code outside this PR's purpose.

## 3. Merge through Trunk

Merge when all of these hold on the current head commit:

- every required check passes (`gh pr checks <n>`),
- `reviewDecision` is `APPROVED` — a bot approval (CodeRabbit or Copilot)
  counts,
- no unresolved bot thread, no blocking human thread or review.

`mergeStateStatus: BLOCKED` is expected and is not a missing approval: branch
rules forbid direct merges because merges go through Trunk. Never use
`gh pr merge` or the GitHub merge button.

Queue it by posting the Trunk command as a PR comment, as James:

    gh pr comment <n> --body '/trunk merge'

Then poll in the foreground (~60s interval) until
`gh pr view <n> --json state,mergeCommit` shows `MERGED`. If Trunk kicks the PR
out of the queue (a failed queue run, a conflict), treat it like a CI failure:
diagnose, fix, push, return to step 2, and re-queue.

## 4. Verify the branch is safe to delete

    git fetch origin
    gh pr view <n> --json state,mergeCommit,url --jq '{state, sha: .mergeCommit.oid, url}'
    git status --porcelain                      # must be empty
    git log @{u}..                              # must be empty
    git merge-base --is-ancestor HEAD origin/main && echo merged

Trunk squash-merges, so `HEAD` may not be an ancestor of `origin/main`. When
that check fails, `git diff origin/main...HEAD` must be empty — the branch then
contributes nothing that is not on `main` — or `git diff HEAD <merge-sha>`
should show only commits from `main`. If anything is uncommitted, unpushed, or
genuinely not on `main`, stop and report; do not send the cleanup request.

## 5. Ask the orchestrator to clean up

Send exactly one message:

    bb thread tell thr_ysw4iryrc2 --message-file - <<'EOF2'
    Cleanup request from land-pr: <worktree-name>
    PR: <pr-url> (MERGED)
    Merge commit: <merge-sha>
    Thread: <$BB_THREAD_ID>
    Branch checks passed: clean status, nothing unpushed, merged into origin/main.
    EOF2

`<worktree-name>` is `basename "$PWD"`, not the branch name.

Then stop. Do not run more commands in the worktree: the orchestrator archives
this thread and deletes the directory, and a live session in it can recreate
files under the removed path.

## Final report

- PR link, merge commit, and when it merged (America/Denver).
- What was fixed along the way (CI fixes, flake root causes, bot findings
  applied/declined).
- **Human threads** left for James, each linked — or "none".
- That the cleanup request went to @thread:thr_ysw4iryrc2.
