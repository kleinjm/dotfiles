---
name: work-overview
description: Keep a live visual overview of the current task pinned beside the chat — what the change is, why, its shape, and step status — as an Iris card in $BB_THREAD_STORAGE/overview.iris pinned with iris_pin. Use at the start of every task in an EscrowSafe/web worktree thread (/workspace/web-worktrees/*), before any other work, and again whenever the plan, scope or a step's status changes. Also use when James asks "what are we working on", "remind me", or for a visual of the task.
---

# Work overview

Every worker thread keeps one pinned card that answers "what are we working
on?" at a glance. James should never need to ask.

## When

- **Before any work.** Right after reading the issue or brief, before editing
  code: write the card and pin it. Unknowns are fine; mark them as such.
- **On change.** Rewrite the file when the plan, scope or a step's status
  changes, when a commit lands, when the PR opens, or when something blocks.
- The fundamentals (title, the one-line what/why, the diagram) should rarely
  change. Steps and status move as work progresses.

## How

1. Write Iris markup to `$BB_THREAD_STORAGE/overview.iris` (the card only, no
   ``` fences).
2. Run `iris_check` on that markup. Fix every problem before going on.
3. First time only: `iris_pin` with `file: "$BB_THREAD_STORAGE/overview.iris"`
   and `id: "work-overview"`. The pin re-reads the file every 3 s, so later
   updates only rewrite the file (and re-check it). Re-pin with the same id
   only if the pin is gone (`iris_pins`).

Never put a broken card in the file: the pin shows whatever the file holds.

## Layout

One `Card`, top to bottom:

1. **Title** `#<issue>: <subject in a few words>`; `subtitle` the branch.
2. **One or two sentences**: the problem and the fix, in plain words. No
   status here; it would go stale.
3. **The shape**: a Mermaid `Diagram` of the flow being changed. For a bug
   fix, `Tabs` with `Before` and `After`; a `sequenceDiagram` for races,
   `flowchart LR` for request/branching flows. Put file:line pointers and
   why-notes in `notes` on the key nodes, not in prose.
4. **Steps**: the plan with `done | current | todo | blocked` and a `detail`
   on anything current or blocked (what it waits on: specs, James, CI).
   Include the commit, push and PR steps so the end state is visible.
5. **Live data, never retyped**: `<Changes />` (in a `Details` to keep the
   card short) and, once a PR exists, `<PullRequest />`. Don't copy shas,
   file lists, check counts or review status into text.

Keep it to these parts. Questions for James and action items stay in chat
replies, not the card.

## Example

```iris
<Card title="#6201: stale submit on a completed Form 593" subtitle="legacy-form593-stale-submit-guard">
A stale upload tab could still POST `submit` on a completed Form 593 and overwrite `esigned`. Guard it under the escrow lock.
<Tabs>
<Tab label="Before">
<Diagram notes={{ S: "Overwrites esigned; can switch a mid-signing cosigner's flow" }}>
flowchart LR
  T[Stale tab] -->|POST submit| S[save esigned]
</Diagram>
</Tab>
<Tab label="After">
<Diagram notes={{ C: "app/controllers/customers/form593_controller.rb:70" }}>
flowchart LR
  T[Stale tab] -->|POST submit| L[escrow lock]
  L --> C{completed?}
  C -->|yes| R[redirect, nothing saved]
  C -->|no| S[save esigned]
</Diagram>
</Tab>
</Tabs>
<Steps items={[
  { title: "Read the issue and the controller", status: "done" },
  { title: "Guard inside the escrow lock", status: "done" },
  { title: "Request spec for a stale No", status: "current" },
  { title: "Commit locally" },
  { title: "Push and open the PR", detail: "Waiting for James", status: "blocked" }
]} />
<Details title="Changes"><Changes /></Details>
<PullRequest />
</Card>
```
