---
name: flaky-test
description: >-
  Debug and fix flaky RSpec tests. Accepts a spec file path with line number
  (e.g. spec/models/foo_spec.rb:42), a full test error report pasted inline,
  or a GitHub PR URL. Diagnoses the root cause, applies a fix, commits, and
  verifies stability by running the spec file 5+ times.
argument-hint: "<spec/path:line | error report | PR URL>"
---

## Purpose

Diagnose and fix flaky (intermittently failing) RSpec tests. The skill accepts
one of three input types, identifies the root cause, applies a targeted fix,
commits to the appropriate branch, and validates stability.

## Usage

```bash
# Specific test location
/flaky-test spec/system/escrows/create_escrow_spec.rb:47

# Paste an error report (copy the full failure output)
/flaky-test <pasted RSpec failure output>

# GitHub PR with failing CI
/flaky-test https://github.com/EscrowSafe/web/pull/3198
```

## Instructions for Claude

### Step 0: Parse Input

Determine which input type was provided in `$ARGUMENTS`:

| Pattern | Type |
|---|---|
| Matches `https://github.com/.*/pull/\d+` | **PR URL** |
| Contains `spec/` and a file path ending in `_spec.rb` (with optional `:line`) | **Spec path** |
| Everything else (multi-line text, RSpec failure output) | **Error report** |

#### PR URL Input
1. Extract the PR number and repo from the URL.
2. Fetch CI check status:
   ```bash
   gh pr checks <number> --repo <owner/repo>
   ```
3. If checks are still running, inform the user and wait for completion.
4. For failed checks, fetch the CI log to find the failing spec:
   ```bash
   gh run view <run_id> --log-failed --repo <owner/repo>
   ```
5. Parse the log output to identify the failing spec file and line number.
6. If the PR branch is not checked out locally, check it out:
   ```bash
   gh pr checkout <number>
   ```
7. Continue to Step 1 with the identified spec path.

#### Error Report Input
1. Parse the error output to extract the spec file path and line number.
2. Look for patterns like `./spec/path/to/file_spec.rb:123` or `rspec spec/path/to/file_spec.rb:123`.
3. Continue to Step 1 with the extracted spec path.

#### Spec Path Input
1. Use the path directly. Continue to Step 1.

### Step 1: Reproduce and Understand the Failure

1. **Read the failing spec file** in full to understand its structure and intent.
2. **Run the specific test** to see current behavior:
   ```bash
   bundle exec rspec spec/path/to/file_spec.rb:LINE
   ```
3. **Run the test multiple times** (3-5 times) to observe if failure is intermittent:
   ```bash
   for i in {1..5}; do echo "=== Run $i ==="; bundle exec rspec spec/path/to/file_spec.rb:LINE 2>&1 | tail -5; done
   ```
4. If the test passes every time locally, note this — the flake may depend on parallel execution, database state, or timing. Proceed with static analysis.

### Step 2: Diagnose Root Cause

Systematically check for these common flaky test causes, **in order of likelihood**:

#### A. Timing and Asynchronous Issues (Most Common in System Specs)
- **Missing Capybara waits**: Using `find` or `all` without allowing time for async content.
  Check for `have_content` immediately after actions that trigger Turbo/Stimulus updates.
- **Race conditions with Turbo**: Page navigations via Turbo may not be complete when assertions run.
  Look for missing `have_current_path` or `have_css` waits after clicks.
- **JavaScript not finished executing**: Stimulus controllers may not have connected yet.
  Look for interactions with elements controlled by Stimulus immediately after page load.
- **Animation/transition interference**: Elements may be present but not yet interactable.

**Fixes:**
- Add explicit Capybara matchers that wait: `expect(page).to have_content(...)` before interacting.
- Use `have_current_path` after navigation actions.
- Use `find(selector, wait: 10)` for slow-loading elements.
- Avoid `sleep` — use Capybara's built-in waiting instead.

#### B. Database and State Issues
- **Shared state between tests**: Data leaking between tests via non-transactional fixtures or global state.
- **Factory sequence collisions**: Factories generating duplicate values across parallel test processes.
- **Missing database cleanup**: Records persisted across tests.
- **Dependent test ordering**: Test assumes state created by a prior test.
- **Seeded data assumptions**: Test assumes specific seeded records exist or don't exist.

**Fixes:**
- Ensure test creates all data it needs — never depend on other tests' side effects.
- Use unique values in factories (sequences, `SecureRandom.uuid`).
- Check for `before(:all)` or `before(:suite)` blocks that persist state.

#### C. Time-Dependent Failures
- **Time zone sensitivity**: Tests that assume a specific timezone or break near midnight.
- **Date boundary issues**: Tests using `Date.today` or `Time.now` that fail at certain times.
- **Expiration/TTL logic**: Tests that depend on time passing.

**Fixes:**
- Use `travel_to` or `freeze_time` to pin time in tests.
- Avoid `Date.today` / `Time.now` — use frozen time references.
- Be explicit about timezones.

#### D. External Dependencies
- **Unstubbed HTTP calls**: Tests making real network requests that timeout or return different data.
- **File system race conditions**: Temp files not cleaned up or colliding.
- **Redis/cache state**: Shared cache polluting between tests.

**Fixes:**
- Stub all external HTTP calls with WebMock/VCR.
- Use unique temp file paths.
- Clear caches in test setup.

#### E. Parallel Execution Issues
- **Database row locking**: Tests competing for the same database rows.
- **Port conflicts**: Multiple test processes binding the same port.
- **Global mutable state**: Class variables or module-level state shared across processes.

**Fixes:**
- Ensure factories produce unique records.
- Avoid global mutable state in tests.

#### F. Capybara-Specific Issues (System Specs)
- **Stale element references**: DOM elements replaced by Turbo after a `find` call.
  Use `within` blocks or re-find elements after page mutations.
- **Ambiguous selectors**: `find('button')` matching multiple elements.
  Use more specific selectors or `find('button', text: 'Save')`.
- **Modal/overlay interference**: Capybara clicking on an overlay instead of the target element.
- **Scroll position**: Element exists but is outside viewport and not clickable.

**Fixes:**
- Use unique, specific selectors.
- Add `scroll_to` before clicking elements that may be off-screen.
- Use `accept_confirm` or `dismiss_confirm` for modals.

### Step 3: Investigate Related Code

1. **Read the source code** that the test exercises (controller, service, model).
2. **Check for recent changes** to the test or source:
   ```bash
   git log --oneline -10 -- spec/path/to/file_spec.rb
   git log --oneline -10 -- app/path/to/source.rb
   ```
3. **Check if the test was recently added or modified** — new tests are more likely to be poorly written.
4. **Look at similar passing tests** in the same file for patterns that work.

### Step 4: Apply the Fix

1. **Make the minimal fix** — change only what is needed to eliminate the flake.
2. **Follow project testing standards** from `docs/claude/testing.md`:
   - Never use `let`, `let!`, `before` blocks, or `@` instance variables.
   - Use `I18n.t()` for string assertions, never hardcoded English.
   - Use `visible: :visible` not `visible: true` in Capybara.
   - Use `instance_double` not `double`.
   - Use `described_class` not the class name directly.
3. **Do NOT refactor or optimize** beyond fixing the flake. This is a targeted fix, not a cleanup pass.
4. **Add a brief inline comment** only if the fix is non-obvious (e.g., `# Wait for Turbo to replace the frame before asserting`).

### Step 5: Verify Stability

Run the **entire spec file** at least 5 times to confirm the fix is stable:

```bash
for i in {1..5}; do echo "=== Run $i ===" && bundle exec rspec spec/path/to/file_spec.rb && echo "PASSED" || echo "FAILED"; done
```

- All 5 runs must pass.
- If any run fails, return to Step 2 and re-diagnose.
- If the test is a system spec and the flake only manifests under parallel execution, also run with parallel_rspec:
  ```bash
  PARALLEL_TEST_PROCESSORS=2 bundle exec parallel_rspec spec/path/to/file_spec.rb
  ```

### Step 6: Commit

1. **Check current branch**:
   ```bash
   git branch --show-current
   ```
2. **If on `main`**, create a new branch:
   ```bash
   git checkout -b fix/flaky-SPECNAME
   ```
   where `SPECNAME` is a short identifier derived from the spec file (e.g., `fix/flaky-create-escrow`).
3. **If on a feature branch**, stay on it.
4. **Stage and commit** the fix:
   ```bash
   git add spec/path/to/file_spec.rb
   git commit -m "$(cat <<'EOF'
   fix: stabilize flaky spec in FILENAME

   Root cause: BRIEF_DESCRIPTION_OF_ROOT_CAUSE
   Fix: BRIEF_DESCRIPTION_OF_WHAT_CHANGED
   EOF
   )"
   ```
5. If source code also needed changes, include those files in the commit too.

### Step 7: Report

Provide a brief summary to the user:
- **File**: which spec was fixed
- **Root cause**: one-sentence explanation
- **Fix applied**: what changed
- **Stability**: confirmation that 5/5 runs passed
