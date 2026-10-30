---
name: standup
description: Write James's daily standup — PRs from bin/standup.rb plus the workstreams that never had a PR or task — and leave it as an unsent Slack draft in #daily-updates. Use when he asks for a standup, a daily update, or "what did I do yesterday".
---

# Standup

Produce a Slack-ready standup and leave it as a **draft**. Never send it.

`bin/standup.rb` covers PRs and linked tasks only. Most of a day's work does not
appear there: plugin and container config, audits posted as issue comments,
investigations that end in an artifact, branches with no PR yet. Those are the
reason this skill exists — gather them yourself.

## 1. The PR spine

    cd /workspace/web && bin/standup.rb

Takes ~60s. Its output is the `**Yesterday**:` PR list. Keep its emoji labels
(`:construction: WIP:`, `:eyes: Needs CR:`, `:merge: Ready to Deploy:`,
`:ship: Deployed:`) and its PR-plus-task link shape.

## 2. The window problem — read before gathering

`bin/standup.rb` uses yesterday's **date** (or Friday, on a Monday). James
regularly works past midnight, so the tail of "yesterday" carries today's date
and the script silently drops it. Sweep from the start of yesterday through
**now**, then place work by which working session it belonged to, not by date.
Say so if you move something across the boundary.

## 3. Everything the script misses

Run these together; each is one line per stream, so skim for what is real work
rather than noise.

    # Commits across every worktree and branch, both days
    cd /workspace/web && git log --all --since="<yesterday> 00:00" --format='%h %cI %s'

    # Personal config, tooling, container setup
    cd /workspace/dotfiles && git log --since="<yesterday> 00:00" --format='%h %cI %s'

    # Audits and long comments posted to issues
    gh api repos/EscrowSafe/web/issues/<n>/comments \
      --jq '.[] | select(.created_at >= "<yesterday>") | "\(.created_at) \(.user.login) \(.body[0:80])"'

Then the threads, for branches that exist but have no PR:

    bb thread list
    bb thread show <id> --work-status --json | jq -c '{branch:.environment.branchName, work:.workStatus.mergeBase}'

`--work-status` gives commits, file counts and ahead/behind. A branch with
commits and no PR is a workstream; name it and say the PR is not open yet.

## 4. Pull findings from investigation threads

Investigations produce conclusions that live only in a thread's transcript, and
there is no command that reads one. Ask:

    bb thread tell <id> --message-file - <<'EOF'
    Send a short status summary to thread <this thread id> with:
        bb thread tell <this thread id> --message-file - <<'SUMMARY'
        ...
        SUMMARY
    Under 200 words: what you concluded, what you could NOT determine and what
    James must check, and your branch state. Facts only. Do not start new work.
    EOF

Replies arrive as messages. Wait for them before writing — a thread's status is
stale the moment you read it, and `idle` does not mean it did nothing.

## 5. Write it

One sentence per workstream. Link every PR, issue, task and artifact. Slack link
syntax, not Markdown:

    <https://github.com/EscrowSafe/web/pull/5790|Locky - Support macOS with Docker Desktop>

Shape, exactly — note the blank line under each heading:

    **Yesterday**:

    - :ship: Deployed: <url|Title>
    - A stream with no PR, in one sentence.

    **Today**:

    - :construction: <issue url|Title (Task #NNNN)>
    - :construction: A thread with no task, named in a few words.

On a Friday the message ends with one more blank line and an empty heading:

    **Weekend**:

Two sections, `**Yesterday**:` and `**Today**:`. The draft tool renders
STANDARD MARKDOWN, not Slack mrkdwn, so `*x*` comes out italic — use `**x**`
for bold. Put a BLANK LINE after each heading, or the first bullet runs onto
the heading's line.

- `**Yesterday**:` — the PR spine from step 1, then the streams with no PR or
  task as further bullets in the same list. Do not give them their own heading;
  they are the same day's work and read better together.
- `**Today**:` — WHAT he is working on, not how it is going. The tasks he is
  assigned (`bin/standup.rb` already prints these under its own `*Today*`
  heading — keep them), then any thread he is working without a task, named
  the same way. Names only: no status, no blockers, no what-is-left. A
  coworker should see at a glance what he is on, not where he is in it.
  Anything that needs a decision from him belongs in a direct message, not
  here.
- `**Weekend**:` — ON FRIDAY ONLY, and left EMPTY. A blank line after the last
  Today bullet, then the heading on its own with nothing under it. James fills
  it in himself before sending. Do not add it any other day, and never guess
  at its contents.

Rules that matter:

- One sentence each. If a stream needs two, it wants its own ticket.
- Name branches that have no PR; do not invent links for them.
- Under Yesterday, state what is blocked and on whom. "Blocked on whether
  MEMCACHIER_SERVERS is set" is the useful sentence; "investigating rate
  limiting" is not. Under Today, say none of that — Today is a list of names.
- Leave out findings that belong on an audit checklist rather than in standup.

## 6. Draft it, never send

    slack_send_message_draft(channel_id="C09P90TUJEL", message=...)

`C09P90TUJEL` is `#daily-updates`. The draft lands in Drafts & Sent for James to
edit and send himself.

One attached draft per channel: `attached_draft_exists` means yesterday's is
still sitting there unsent — tell him rather than clearing it. Never use
`slack_send_message` or `slack_schedule_message` for a standup.

Show him the full text in chat as well as drafting it, so he can correct it
without opening Slack.
