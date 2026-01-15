# Plan: Display Partial Identity Verification Results

## Goal
Show identity verification results to escrow officers as soon as the ID/document check completes, even if the selfie check is still pending.

## User Requirements
- New "pending" status with distinct visual indicator for in-progress checks
- Inline indicators only (no banner)
- Manual page refresh when selfie completes

---

## Implementation Steps

### Step 1: Add "pending" Result Status
**File:** `app/models/customers/identity_report_check.rb`

- Add "pending" to the result validation: `%w[passed failed flagged skipped unknown ignored pending]`
- Add `pending?` convenience method

### Step 2: Allow Partial Report Generation
**File:** `app/models/customers/identity_verification.rb`

- Add `documentary_verification_complete?` method:
  ```ruby
  def documentary_verification_complete?
    steps&.dig('documentary_verification') == 'success'
  end
  ```

- Modify line 223 early return:
  ```ruby
  # FROM:
  return self unless completed?

  # TO:
  return self unless completed? || documentary_verification_complete?
  ```

- Update document/selfie ingestion logic (lines 230-234) to only ingest selfies when completed

### Step 3: Update Checks Runner for Pending Selfie Status
**File:** `app/models/customers/identity_report_checks_runner.rb`

- Add helper method to detect pending selfie state:
  ```ruby
  def selfie_step_pending?
    status = @ctx.idv_step_status_for(:selfie_check)
    %w[active waiting_for_prerequisite].include?(status) ||
      (status.nil? && !@ctx.idv.completed?)
  end
  ```

- Update `run_selfie_liveness_check`, `run_selfie_video_check`, `run_selfie_document_match_check` to return "pending" when `selfie_step_pending?`

- Update `run_selfie_checks` aggregation to set `data_raw['pending'] = true` when pending

- Update `aggregate_checks_results` to handle "pending" (takes priority over "unknown")

- Update `run_customer_summary_selfie_check` to return "pending" when appropriate

### Step 4: Add Visual Indicators for Pending Status
**File:** `app/helpers/application_helper.rb` (or relevant helper)

- Update `icon_for_check` to show gray/neutral icon for "pending"
- Update `class_for_check_pill` to show gray styling for "pending"
- Update `class_for_check_circle` to show gray for "pending"

### Step 5: Update View for Pending Selfie Section
**File:** `app/views/escrows/identities/show.html.slim`

- In selfie section (around line 290), add conditional for pending state:
  ```slim
  - if selfie_check.data['pending']
    .d-flex.align-items-center.gap-2.fs-8.m-0.text-medium-grey
      = inline_svg 'icons/icon-circle-minus.svg', class: 'icon-svg-sm icon-medium-grey'
      | Selfie verification in progress. Refresh page when customer completes this step.
  ```

### Step 6: Add Locale Translations
**File:** `config/locales/en.yml`

Add translations for pending selfie states under `id_report.explain`

### Step 7: Update Tests
**Files:**
- `spec/models/customers/identity_report_check_spec.rb` - Add "pending" to validation test, add `pending?` test
- `spec/models/customers/identity_verification_spec.rb` - Add tests for `documentary_verification_complete?`
- `spec/models/customers/identity_report_checks_runner_spec.rb` - Add tests for pending selfie scenarios

### Step 8: Add Factory Trait
**File:** `spec/factories/customers/identity_verifications.rb`

Add `:documentary_complete_selfie_pending` trait for testing partial completion state

---

## Critical Files
| File | Changes |
|------|---------|
| `app/models/customers/identity_verification.rb` | Add `documentary_verification_complete?`, modify early return on line 223 |
| `app/models/customers/identity_report_checks_runner.rb` | Add `selfie_step_pending?`, update selfie check methods, update aggregation |
| `app/models/customers/identity_report_check.rb` | Add "pending" to validation, add `pending?` method |
| `app/helpers/application_helper.rb` | Update icon/color helpers for "pending" |
| `app/views/escrows/identities/show.html.slim` | Add pending state display |

---

## Edge Cases Handled
1. **Selfie not required**: Already handled by `not_applicable` status → "skipped"
2. **IDV already completed**: `completed?` check ensures normal flow
3. **Multiple refreshes**: `find_or_initialize_by` pattern is idempotent
4. **Redacted IDV**: Sets `completed_at`, bypasses partial logic
5. **Refresh after selfie completes**: Existing `refresh!` regenerates all checks
