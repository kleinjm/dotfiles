---
name: standup
description: Generate a concise "Yesterday:" standup summary from your GitHub PRs and issues — naming each piece of work and where it sits in the dev process (WIP, needs CR, deployed), with a Slack-hyperlinked PR for every item. Pulls items you authored or are assigned to, dedups linked/related items, and outputs a short bullet list. On Mondays the window reaches back to the start of Friday.
user-invocable: true
arguments: ""
---

You're generating a standup-style recap of the user's recent GitHub activity (PRs and issues). The output is a short bullet list, always prefixed with `**Yesterday**:`. The audience is the user's team, who already have a sense of what they're working on — so each bullet names **the thing** and **where it is in the process**, not an explanation of what it does.

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

Bucket each item by where it sits in the dev process. This drives the emoji + label prefix on each bullet:

- **WIP** → `:construction: WIP:` — work still in **development or draft**. Draft PRs, and open PRs/issues you're actively building. This covers anything not yet ready to ship — even if it's technically already up for a first review. (In the user's world, a drafted PR awaiting initial CR is still WIP.)
- **Needs CR** → `:eyes: Needs CR:` — open, **non-draft** PRs that are finished and waiting on code review (e.g. `reviewDecision` of `REVIEW_REQUIRED`).
- **Deployed** → `:ship: Deployed:` — PRs **merged** (or issues closed) within the window. Always say "Deployed", never "merged".

Use `gh pr view` (Phase 2 fallback) to resolve draft vs. ready vs. merged when the search JSON is ambiguous.

## PHASE 4: Dedup linked / related items

Collapse items that refer to the same piece of work:

- A PR and the issue it closes (look for `Closes #`, `Fixes #`, `Related to #` in the body) → one bullet, linking the PR.
- Multiple PRs on the same topic (same feature, same component, near-identical titles) → one bullet with both PRs linked, joined by `, and ` (see Phase 5).
- Prefer the PR over the issue as the thing to link.

When in doubt, merge rather than duplicate — the list should read as distinct threads of work, not raw GitHub rows.

## PHASE 5: Write the list

Start with the literal line `**Yesterday**:`, then a blank line, then the bullets. Each bullet is:

```
- <emoji> <label>: <link>
```

where `<emoji> <label>` comes from Phase 3 (`:construction: WIP:`, `:eyes: Needs CR:`, `:ship: Deployed:`) and `<link>` is a **Slack hyperlink** to the PR.

**Link syntax — use Slack's, not Markdown's.** Slack links are `<url|text>`, e.g. `<https://github.com/EscrowSafe/web/pull/4015|RPA product page>`. Do **not** emit `[text](url)`.

Style rules:
- **Name the thing, don't explain it.** The link text is a short noun phrase for the work — "Form 1099 redirect after signing", "Document-exchange upload content-type allowlist". The team already knows the context; don't describe what the change does or why.
- **Every item gets a PR link.** If a thread has more than one PR, combine them in one bullet joined with `, and `:
  `- :ship: Deployed: <url1|thing one>, and <url2|thing two>`
- Group by status — typically WIP first, then Needs CR, then Deployed.
- Plain and factual. No marketing words ("comprehensive", "robust", "seamless").
- Keep it tight: typically 3–6 bullets.

Reference example (the target shape — note the short names and Slack link syntax):

```
**Yesterday**:

- :construction: WIP: <https://github.com/EscrowSafe/web/pull/4001|Form 1099 redirect after signing>
- :construction: WIP: <https://github.com/EscrowSafe/web/pull/4002|Document-exchange upload content-type allowlist>
- :construction: WIP: <https://github.com/EscrowSafe/web/pull/4003|Seller Loan Information form fixes and polish>
- :ship: Deployed: <https://github.com/EscrowSafe/web/pull/4010|Officer SOI review page navigation alignment>, and <https://github.com/EscrowSafe/web/pull/4011|unified signed-signature visuals across opening package review pages>
- :ship: Deployed: <https://github.com/EscrowSafe/web/pull/4015|RPA product page>
- :ship: Deployed: <https://github.com/EscrowSafe/web/pull/4020|Opening-package seed data>, and <https://github.com/EscrowSafe/web/pull/4021|ngrok in the devcontainer image>
```

Output only the `**Yesterday**:` block — no preamble, no trailing commentary.
