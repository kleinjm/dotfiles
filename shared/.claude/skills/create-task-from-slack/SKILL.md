---
name: create-task-from-slack
description: Create a Todo task on the EscrowSafe "Web" GitHub project (org project #1) from a Slack message link. Reads the linked Slack message (and its thread) via the Slack MCP, drafts a title and body, adds a draft item to the project with status Todo, then replies in the source Slack thread with a link to the task. Accepts a Slack message/permalink URL as the argument.
user-invocable: true
arguments: "<slack_message_url>"
---

You're turning a Slack message into a task on the EscrowSafe **Web** GitHub project (org project #1), with status **Todo**.

## PHASE 0: Parse the argument

The argument is a Slack message link, e.g.:

```
https://escrowsafe.slack.com/archives/C071VSC0LVC/p1783012785622979
```

Extract two values from it:

- **channel_id** — the segment after `/archives/` (e.g. `C071VSC0LVC`). May also be a DM (`D…`) or group (`G…`) id.
- **message_ts** — the `p<digits>` segment. Convert to Slack `ts` format by inserting a decimal point **6 digits from the right**: `p1783012785622979` → `1783012785.622979`.
- If the URL has a `?thread_ts=<ts>&cid=<id>` query, the message is a threaded reply — use that `thread_ts` as the parent and note the specific reply `ts`.

If no argument is given, ask the user for the Slack link. Do not guess.

## PHASE 1: Read the Slack message

The Slack tools are provided by the **claude.ai Slack** MCP connector (deferred tools). Load them with ToolSearch first, e.g.:

```
ToolSearch: select:mcp__claude_ai_Slack__slack_read_thread,mcp__claude_ai_Slack__slack_read_channel
```

Then read the message and its thread:

- `mcp__claude_ai_Slack__slack_read_thread` with `channel_id` and `message_ts` — returns the parent message plus all replies. Use this by default so the task captures the full discussion.
- If the connector isn't authenticated, it returns an instruction to run `/mcp` and select **claude.ai Slack**. Relay that to the user and stop — you can't authenticate on their behalf.

Read the full message text, the author, and any replies. Note attachments/files by name (you can't embed images in the task, so reference them).

## PHASE 2: Draft the task

From the message content, compose:

- **Title** — a concise, specific imperative summary (not the raw first line). Aim for < ~80 chars.
- **Body** — include:
  - A short restatement of what needs to happen.
  - Relevant context/decisions from the thread (quote the key points; attribute by first name).
  - A link back to the source Slack message (the original URL).
  - Note any attachments by filename.

Keep it factual and technical — no marketing language (per repo communication standards).

Show the user the drafted title and body and confirm before creating, unless they said to just create it.

## PHASE 3: Create the project item with status Todo

Project constants (EscrowSafe org project #1, titled "Web"):

- Project ID: `PVT_kwDOCbpDA84Ag05e`
- Project number / owner: `1` / `EscrowSafe`
- Status field ID: `PVTSSF_lADOCbpDA84Ag05ezgV6J9w`
- Status option **Todo**: `f75ad846`

> These IDs are stable but if any `gh` call fails with a not-found/field error, re-discover them:
> `gh project field-list 1 --owner EscrowSafe --format json` and `gh project view 1 --owner EscrowSafe --format json`.

Create a **draft item**, then set its status. `gh` must be authenticated with `project` scope (it is, via the `kleinjm` account).

```bash
# 1. Create the draft item (body via --body). Capture the returned item id.
ITEM_ID=$(gh project item-create 1 --owner EscrowSafe \
  --title "<TITLE>" \
  --body "<BODY>" \
  --format json --jq '.id')

# 2. Set its Status to Todo
gh project item-edit \
  --project-id PVT_kwDOCbpDA84Ag05e \
  --id "$ITEM_ID" \
  --field-id PVTSSF_lADOCbpDA84Ag05ezgV6J9w \
  --single-select-option-id f75ad846
```

If the body is long or multi-line, write it to a temp file in the scratchpad and pass with `--body "$(cat <file>)"` to avoid shell-quoting issues.

## PHASE 4: Post the task link back to Slack

Reply in the source message's thread with a link to the task. Replying to a message with its `thread_ts` set to the message's own `ts` posts into that message's thread, creating the thread if one doesn't exist yet.

Load the send tool: `ToolSearch: select:mcp__claude_ai_Slack__slack_send_message`, then:

- `mcp__claude_ai_Slack__slack_send_message` with:
  - `channel_id` — the channel from PHASE 0
  - `thread_ts` — the **parent** message's `ts` (the `message_ts` you parsed; if the link was itself a threaded reply, use the thread's parent `ts`)
  - `text` — e.g. `📋 Task created: <task-url>` (a short line plus the project item URL)

Keep the reply to one short line with the URL. If posting fails (e.g. missing write scope), report that to the user but still return the task URL — task creation already succeeded.

## PHASE 5: Report

Return the project item's URL (from the `item-create` JSON, field `url`) so the user can click through, confirm the status is set to Todo, and confirm the Slack reply was posted. If `item-create` didn't return a URL, link the project board: https://github.com/orgs/EscrowSafe/projects/1

## Notes

- Default output is a **draft** project item (no repo required). If the user asks for a real, assignable GitHub issue instead, create the issue in the relevant repo with `gh issue create`, then add it with `gh project item-add 1 --owner EscrowSafe --url <issue-url>` and set status the same way.
- The only thing this skill writes to Slack is the single task-link reply in PHASE 4. It never posts anywhere else.
