---
name: standup
description: Generate a concise "Yesterday:" standup summary from your GitHub PRs and issues — what's in progress, needs review, and was completed in the recent window. Pulls items you authored or are assigned to, dedups linked/related items, and outputs a short bullet list. On Mondays the window reaches back to the start of Friday.
user-invocable: true
arguments: ""
---

You're generating a standup-style recap of the user's recent GitHub activity (PRs and issues). The output is a short bullet list, always prefixed with `Yesterday:`.

## PHASE 1: Determine the time window

Today's date is available in context. Compute the lookback window:

- **Default (Tue–Fri, or any non-Monday):** look back **24 hours** — from the start of yesterday to now.
- **If today is Monday:** look back to **the start of last Friday** (so the window covers Fri/Sat/Sun work).

Translate this into a GitHub search date. GitHub search supports relative anchors:
- Non-Monday: `created:>@today-2d` and `updated:>@today-2d` (the `-2d` gives a safe 24h+ margin).
- Monday: `created:>@today-4d` and `updated:>@today-4d` (reaches back to Friday).

Use your judgment on the exact day-offset based on today's actual date — the goal is "since yesterday" normally, "since Friday morning" on Mondays.

## PHASE 2: Fetch the items

Run these searches in parallel with `gh search`. Cover both **authored** and **assigned** items, across PRs and issues. Use `--json` for structured output.

```bash
# Items I authored (PRs + issues), recently created or updated
gh search prs --author "@me" --updated ">@today-2d" --json number,title,url,state,repository,isDraft,labels,body --limit 50
gh search issues --author "@me" --updated ">@today-2d" --json number,title,url,state,repository,labels,body --limit 50

# Items assigned to me
gh search prs --assignee "@me" --updated ">@today-2d" --json number,title,url,state,repository,isDraft,labels,body --limit 50
gh search issues --assignee "@me" --updated ">@today-2d" --json number,title,url,state,repository,labels,body --limit 50

# PRs where my review is requested (needs review surfacing)
gh search prs --review-requested "@me" --state open --json number,title,url,repository,labels,body --limit 50
```

Adjust the `>@today-Nd` offset per Phase 1 (use `-4d` on Mondays). If a search errors (e.g. auth), note it and continue with whatever succeeded.

For each PR, you may also need its merge/CR status. If a PR's state isn't clear from the search JSON, fall back to `gh pr view <number> --repo <owner/repo> --json state,isDraft,reviewDecision,mergedAt`.

## PHASE 3: Classify each item

Bucket each item into one of:

- **In progress** — open PRs (especially drafts) or open issues you're actively working, updated in-window.
- **Needs review / CR** — open non-draft PRs awaiting review, PRs with `reviewDecision` of `REVIEW_REQUIRED`, or anything you'd hand off. Mark these explicitly (e.g. trailing `— needs CR`).
- **Completed** — PRs merged or issues closed within the window.

You don't need to print the bucket names — the classification informs the phrasing of each bullet (e.g. completed items read as done, review items end with `— needs CR`).

## PHASE 4: Dedup linked / related items

Collapse items that refer to the same piece of work:

- A PR and the issue it closes (look for `Closes #`, `Fixes #`, `Related to #` in the body) → one bullet.
- Multiple PRs/issues on the same topic (same feature, same component, near-identical titles) → one bullet, mentioning the combined work.
- Prefer the most representative item (usually the PR) as the canonical entry.

When in doubt, merge rather than duplicate — the list should read as distinct threads of work, not raw GitHub rows.

## PHASE 5: Write the list

Output format — **always** start with the literal line `Yesterday:` followed by a blank line, then the bullets:

```
Yesterday:

- <concise description of the work, with a brief explanation>
- <next item> — needs CR
- ...
```

Style rules (match the user's example):
- One bullet per distinct thread of work.
- Each bullet is a short phrase + brief explanation of what/why — not a title dump.
- Plain, factual, first-person-implied voice. No marketing words ("comprehensive", "robust", "seamless").
- Items needing review end with `— needs CR` (or similar short marker).
- Completed work reads as finished ("Refactor of...", "Wiring up...").
- No links, issue numbers, or repo names in the bullets unless they add clarity — keep it human-readable.
- Keep the whole list tight: typically 3–6 bullets.

Reference example (the target shape):

```
Yesterday:

- Small, quick improvement to fill in MFA text codes on Mac from iMessage
- Refactor of our dev console methods to help with local testing & get rid of more mod tasks buyer/seller code
- Rabbit hole on SSN input during 1099 QA - landed on a new SSN input component
- Wiring up the 1099 form to new component + rejiggering fields to match Figma - needs CR
```

Output only the `Yesterday:` block — no preamble, no trailing commentary.
