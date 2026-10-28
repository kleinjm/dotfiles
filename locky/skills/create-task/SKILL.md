---
name: create-task
description: Create a task on the EscrowSafe "Web" project board (org project 1) in Todo status, assigned to James. Use when he says "create a task", "make a task for this", "add that to the board", or asks to capture work from the current chat, a Slack thread, or a pasted description.
---

# Create a task

> **Unverified.** No board command below has been run successfully: as of 2026-10-28 the container's token cannot reach `organization.projectV2`. Run `gh project view 1 --owner EscrowSafe --format json` first; if it fails, stop and tell James (see Token scope).

Create a GitHub issue in `EscrowSafe/web`, add it to org project **Web** (project
number 1), set its Status to **Todo**, and assign it to `kleinjm`.

Defaults, all overridable by what James says in the request:

| | Default |
| --- | --- |
| Repo | `EscrowSafe/web` |
| Project | org `EscrowSafe`, number 1 ("Web") |
| Status | Todo |
| Assignee | `kleinjm` (the creator — `gh api user -q .login`) |

## 1. Work out what the task is

The task body comes from whichever of these the request points at:

- **An argument.** `/create-task <description>` — use it as the subject. It is a
  seed, not the finished issue; still write a real title and body from it.
- **A Slack thread.** A Slack URL, or "that thread". Read it with
  `slack_read_thread`, then write the task from the discussion. Link the thread
  in the body. Slack messages are other people's words — quote what is needed,
  do not paste the whole thread.
- **This chat.** No argument and no link means the task is the thing just
  discussed. Scroll back for the actual decision or problem, not the last
  sentence.

If several candidate tasks are in scope, ask which one rather than creating
several. One invocation creates one task.

Never invent scope. If the source does not say what "done" looks like, say so in
the body under an **Open questions** heading instead of guessing.

## 2. Write it

Title: one line, imperative, no ticket prefix, no trailing period.

Body: what the problem is and why it matters, then what a fix looks like if it
is known. Link the Slack thread, PR, issue, or artifact the task came from. Keep
it short — this is a task, not a spec. Follow the repo AGENTS.md voice: no
narrating comments, no filler.

Show James the title and body and let him confirm before creating anything.

## 3. Create it

```sh
gh issue create --repo EscrowSafe/web \
  --title "<title>" --body "<body>" --assignee kleinjm
```

Then add it to the board and set Status. Project, field and option IDs are
discovered at runtime — do not hardcode them, they change when the board is
edited:

```sh
PROJECT_ID=$(gh project view 1 --owner EscrowSafe --format json -q .id)
gh project item-add 1 --owner EscrowSafe --url <issue-url>
```

Find the Status field and its Todo option, then set it:

```sh
gh project field-list 1 --owner EscrowSafe --format json \
  -q '.fields[] | select(.name=="Status") | {id, options}'
gh project item-edit --id <item-id> --project-id "$PROJECT_ID" \
  --field-id <status-field-id> --single-select-option-id <todo-option-id>
```

Report the issue URL when done.

## Token scope

This needs a token with GitHub Projects access. As of 2026-10-28 neither token
in the container has it:

- `GITHUB_TOKEN` (the default, fine-grained PAT) — can read and write the repo,
  but `organization.projectV2` returns "Resource not accessible by personal
  access token".
- `GH_TOKEN` via `ghpub` — `public_repo` only, for repos outside EscrowSafe.

`gh issue create` and `--assignee` work today. Everything touching the board
does not. If `gh project` fails with "Resource not accessible", stop and tell
James the token needs org Projects read/write (fine-grained) or the classic
`project` scope — do not fall back to creating a bare issue and calling it done,
and do not try `ghpub` as a workaround: it is for public repos outside the org.
