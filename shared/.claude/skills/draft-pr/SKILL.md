---
name: draft-pr
description: Create a draft PR linked to one or more GitHub issues. Accepts issue numbers (#123) or full URLs as arguments. If no arguments provided, asks user whether to link to a task.
user-invocable: true
arguments: "[issue_refs...]"
---

You're creating a Draft Pull Request linked to GitHub issues.

## PHASE 0: Parse Arguments

The user may provide arguments in these formats (mixed is fine):
- `#123` or `123` — GitHub issue number (assumes current repo)
- `https://github.com/OWNER/REPO/issues/123` — full URL (extract owner/repo and number)
- `relate`, `relates`, or `related` — keyword that changes the link type (see below)
- Multiple issues can be provided: `#123 #456 https://github.com/EscrowSafe/web/issues/789`

**Determine link type from arguments:**
- If any argument is `relate`, `relates`, or `related` (case-insensitive): use **"Related to"** for ALL issue references
- Otherwise (default): use **"Closes"** for ALL issue references

Examples:
- `/draft-pr #123 #456` → `Closes #123`, `Closes #456`
- `/draft-pr relates #123 #456` → `Related to #123`, `Related to #456`
- `/draft-pr relates https://github.com/EscrowSafe/web/issues/2485` → `Related to #2485`

**If NO arguments are provided:**
- Ask the user: "Should this draft PR be linked to a task? If so, provide the issue number(s) or URL(s). Otherwise I'll create it without issue links."
- Wait for user response before proceeding.

Store the parsed issues as a list of `{owner, repo, number}` objects and the resolved link type (`"Closes"` or `"Related to"`) for later use.

## PHASE 1: Fetch Issue Context

For each parsed issue:
1. Fetch the issue details using `gh issue view <number>` (add `--repo OWNER/REPO` if not the default repo)
2. Read the issue title, body, labels, and state
3. Summarize the requirements from each issue — this context informs the PR title, description, and "Link to task(s)" field

If an issue cannot be fetched (404, permissions), warn the user and continue with the remaining issues.

## PHASE 2: Read the PR Template

- Read `.github/PULL_REQUEST_TEMPLATE.md` from the current repo
- If it doesn't exist, check for alternatives:
  - `.github/pull_request_template.md` (lowercase)
  - `.github/PULL_REQUEST_TEMPLATE/` (directory with multiple templates)
  - `docs/PULL_REQUEST_TEMPLATE.md`
- Understand the template structure and note required sections
- Pay special attention to any "FOR AI ASSISTANTS" section

## PHASE 3: Ensure Branch and Sync

The base branch is always `main` unless the user explicitly specifies otherwise via arguments or prior conversation context.

### 3.1 Check current branch
```bash
git branch --show-current
```

**If currently on `main` and there are uncommitted or staged changes:**
- Automatically create a new feature branch. Derive the name from the linked issue(s) or the nature of the changes (e.g., `fix-login-race-condition`, `add-plaid-webhook-handler`).
- Do NOT ask the user — just cut the branch and inform them:
  ```bash
  git checkout -b {branch-name}
  ```

**If currently on `main` with no changes but there are new commits ahead of `origin/main`:**
- Same as above — cut a new branch from the current state.

**If already on a feature branch:** proceed as-is.

### 3.2 Sync with remote
```bash
git fetch origin main:main
```

## PHASE 4: Analyze Changes

### 4.1 Gather change data
```bash
# Overall stats
git diff {base}...HEAD --stat

# Full diff for detailed analysis
git diff {base}...HEAD

# Commits included
git log {base}..HEAD --oneline

# Check for migrations
git diff {base}...HEAD --name-only | grep -E "db/migrate|migrations/" || true

# Check for test changes
git diff {base}...HEAD --name-only | grep -E "spec/|test/|tests/|__tests__/" || true
```

### 4.2 Categorize changes for template sections
Map changes to template sections:
- **Database changes** -> Migration Notes section
- **Test files** -> Testing & Quality section
- **Security-related** -> Review Focus Areas
- **Frontend changes (views, stylesheets, Stimulus controllers)** -> suggest `run:regression` label

## PHASE 5: Generate PR Content

### 5.1 Title
- Keep under 70 characters
- Use specific verbs: add, fix, refactor, update, remove
- Reflect the issue context gathered in Phase 1

### 5.2 Summary Section
- **Brief description**: One clear sentence about what changed
- **Key achievements**: 2-4 factual bullet points
  - No subjective quality descriptors
  - No marketing language ("comprehensive", "robust", "seamless")
- **Link to task(s)**: Build from parsed issues using the link type resolved in Phase 0:
  - Default: `Closes #123` (closes issue on merge)
  - With `relates` keyword: `Related to #123` (keeps issue open)
  - Multiple issues: `Closes #123, Closes #456` or `Related to #123, Related to #456`
  - Cross-repo: `Closes EscrowSafe/other-repo#123`

### 5.3 Detailed Changes (collapsible)
Structure by layer/component:
- **Database**: Migrations, model changes
- **Backend**: Service/controller modifications
- **Frontend**: UI/UX changes
- **Tests**: New/updated test files
- **Configuration**: Environment variables, settings

### 5.4 Testing & Quality (collapsible)
- **New tests**: List specific test files added
- **Updated tests**: Modified tests and why
- **Manual testing**: Steps performed (if applicable)

### 5.5 Business Impact
- Start with the problem being solved (informed by issue context)
- Use concrete impact statements
- No subjective quality claims

### 5.6 Migration Notes
Only include if there are database/deployment changes:
- Migration commands
- Deployment order
- Feature flags needed
- Rollback procedures

### 5.7 Review Focus Areas (collapsible)
- Security-sensitive code
- Performance-critical paths
- Breaking changes
- Complex logic

## PHASE 6: Create the Draft PR

Present the complete PR title and body to the user, then immediately create the PR without asking for confirmation:
```bash
gh pr create \
  --draft \
  --base {base} \
  --title "{title}" \
  --body "{body}"
```

If the PR touches views, templates, stylesheets, or frontend code, suggest adding the `run:regression` label after creation.

### Post-creation
After successful creation, capture the PR URL from `gh pr create` output. Display it prominently:

> **Draft PR created:** https://github.com/OWNER/REPO/pull/NUMBER

Then immediately proceed to Phase 8 to watch CI and fix failures.

## PHASE 8: CI Watch Loop

Poll the PR's CI checks, fix failures, push, and repeat until green.

### 8.1 Poll CI status

**IMPORTANT:** Run CI polling in the main Claude process as a foreground loop. Do NOT use the `/loop` skill, background agents, sub-agents, or `run_in_background: true` for this. The polling must happen in the foreground so the user can halt it at any time with Esc/Ctrl+C.

Between polls, use an explicit `sleep` in the foreground:
```bash
sleep 180 && gh pr checks {pr-number} --repo {owner/repo}
```

Each iteration is a single foreground Bash call that sleeps then checks. Do not set `run_in_background: true` on these calls.

**Polling interval (descending backoff):** Start at ~180 seconds, then 120, then 90, then 60. Never poll more frequently than every 60 seconds. CI duration varies, but as we get closer to completion we don't need to wait as long to check.

CI checks can be in one of three states:
- **pending/in_progress**: Keep polling. Each time you output a status update, always include the PR link so the user can find it easily (e.g., "CI still running on https://github.com/OWNER/REPO/pull/NUMBER — checking again in 90s").
- **all passed**: Go to step 8.3.
- **one or more failed**: Go to step 8.2.

### 8.2 Fix failures
When a check fails:
1. Fetch the failed check's output/logs:
   ```bash
   gh pr checks {pr-number} --repo {owner/repo} --json name,state,link
   ```
2. Pull the CI logs or run the failing test locally to reproduce:
   ```bash
   bundle exec rspec {failing_spec_file}:{line}
   ```
   or for JS:
   ```bash
   yarn test {failing_test_file}
   ```
3. Analyze the failure and apply a fix.
4. **Run the failing test(s) locally to verify the fix passes before pushing.** Do not push to CI until the relevant tests pass locally. This avoids wasting CI cycles on broken fixes.
5. Commit the fix (new commit, not amend) with a message like `fix failing {test_name} spec`.
6. Push to the branch:
   ```bash
   git push
   ```
7. Return to step 8.1 to poll again.

**Flaky test handling:**
If a failed test appears unrelated to the PR's changes (e.g., random ordering issue, intermittent timeout, race condition in unrelated code), treat it as a potential flaky test:
1. Attempt a fix for the flakiness.
2. Run the test at least **5 times** locally to confirm stability (e.g., `for i in {1..5}; do bundle exec rspec path/to/spec.rb:line; done`).
3. If all 5 runs pass, commit, push, and continue polling CI.
4. If the test still fails intermittently after the fix attempt, notify the user with details.

**Guardrails:**
- Maximum **3 fix attempts** for failures related to the PR's changes. If CI still fails after 3 rounds, stop and notify the user with a summary of what failed and what you tried.
- Only fix test/lint failures. If CI fails for infrastructure reasons (e.g., Docker build timeout, flaky external service), notify the user instead of retrying.
- Do not change application logic to make tests pass — fix the tests or fix the code that broke them, but don't paper over failures.

### 8.3 CI passed — notify and offer status change
When all checks pass, notify the user:

> "CI is green on {pr-url}. Want me to mark it as ready for review?"

- If yes: `gh pr ready {pr-number} --repo {owner/repo}`
- If no: leave as draft.

## IMPORTANT REMINDERS
- ALWAYS create as draft (`--draft` flag)
- Do NOT ask for user confirmation before creating — just present the PR content and create it immediately
- REMOVE all HTML comments from the final body
- REMOVE empty or irrelevant sections
- Keep descriptions factual and concise — no marketing language
- NEVER put issue references in commit messages — only in PR body
- Issue references default to "Closes" unless `relates`/`relate`/`related` keyword is passed as an argument
- Use `gh pr create` to create the PR
- Use `gh issue view` to fetch issue details
