# Global Claude Code Instructions

These are James's preferences, and they apply in every project and every
session. On the Mac `~/.claude` *is* `dotfiles/shared/.claude`, so this file is
live there without any linking; in the locky container `locky/setup.local.sh`
links it into `~/.claude/CLAUDE.md`.

Project-specific rules go in that project's `CLAUDE.md` or `CLAUDE.local.md`,
which Claude Code loads in addition to this file. Anything that only makes
sense for one codebase — its test commands, its review bots, its architectural
patterns — belongs there, not here.

## Communication

Keep output concise and to the point. James will ask if more detail is needed
on a specific point. Lead with the result; skip the preamble and the closing
recap.

Call out anything critical with formatting — **bold**, or `>> arrows <<` for
something he must not scroll past.

Structure a response around whichever of these apply, and omit the rest:

- **Outcomes** — what changed.
- **Action items** — what needs to happen next, and who does it.
- **Questions** — what Claude needs from James to proceed, with the options
  where there are any. Always a numbered list, never bullets, so he can answer
  by number. One decision per number: never bundle two decisions into one item
  ("rewrite X, and keep Y?"), because he answers by number and a bundled item
  cannot be answered that way.
- **Options** — where there is a real choice, list them with the cost or
  consequence of each, and say which one Claude would pick.

**Always hyperlink an issue or PR**, never a bare `#number`, and say what it
is: `[#5841](https://github.com/<owner>/<repo>/pull/5841)`. A bare number
forces him to look it up. This applies everywhere — chat replies, Questions and
Options lists, headings, PR bodies and summaries — so check the whole message
before sending, not just its prose. Get `/issues/` vs `/pull/` right; `gh` will
say which it is.

**Write every time in America/Denver**, labelled: "10:55 am MDT". MDT is UTC-6
in summer, MST is UTC-7 after DST ends on the first Sunday of November. When the
source is UTC — logs, Scout, Heroku, GitHub — convert before reporting, and give
the UTC value in parentheses only when it is needed to cross-reference a log.
Use `TZ=America/Denver date` rather than converting by hand so the DST switch
takes care of itself.

Question assumptions and say what is missing rather than guessing.

## Code

- Default to no comments. Add one only where the code cannot carry the meaning,
  and never to record build or change context — that belongs in the PR
  description.

## Git

- Never `git push` or open a PR until explicitly told to. Committing locally
  without asking is fine.
- Open PRs under my own account, never through a GitHub App, even when a
  helper script prints a token.
- Never comment or reply on a PR or issue thread unless asked. "Address a
  comment" means change the code, nothing else.
- Branch names are descriptive kebab-case with no personal prefix
  (`escrow-instructions-tagging-entered-once`). Related PRs share a
  feature-name prefix.
- Split large branches into vertical functional slices — each one a working
  feature end to end — not by layer. Migrations, models, docs, and refactors
  are the exception and can land as their own foundational PR.
