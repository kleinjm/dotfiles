# Plan: Show "Not Applicable" for Downstream Steps When Outcome is Set

## Summary

Update the admin decision trees show page to display "Not Applicable" for steps that come after the exit point when an outcome is already determined.

## Current Behavior

Steps show:
- "Completed" (green) - if `step_complete?` is true
- "In Progress" (yellow) - if step exists but not complete
- "Not Started" (gray) - if step doesn't exist

## Problem

When outcome is set (e.g., `filing_not_required` at Residential), downstream steps show "In Progress" or "Not Started" even though they will never be reached.

## Desired Behavior

When outcome is set, use the presenter's `exit_step` to determine which steps are downstream:

| Exit Step | Residential | Entities | Exemptions | Financing |
|-----------|-------------|----------|------------|-----------|
| :residential | Completed | N/A | N/A | N/A |
| :entities | Completed | Completed | N/A | N/A |
| :exemptions | Completed | Completed | Completed | N/A |
| :financing | Completed | Completed | Completed | Completed |

## Files to Modify

1. `app/views/admin/decision_trees/show.html.slim` - Update step status logic

## Implementation

Add logic to check if step is downstream of exit point when outcome is set:

```slim
- exit_step = @presenter.exit_step if @presenter.complete?
- residential_after_exit = exit_step && false  # residential is never after exit
- entities_after_exit = exit_step && exit_step == :residential
- exemptions_after_exit = exit_step && %i[residential entities].include?(exit_step)
- financing_after_exit = exit_step && %i[residential entities exemptions].include?(exit_step)

/ For each step, check if it's after the exit point first
- if step_after_exit
  span.badge.bg-secondary Not Applicable
- elsif step.step_complete?
  span.badge.bg-success Completed
- elsif step.present?
  span.badge.bg-warning In Progress
- else
  span.badge.bg-secondary Not Started
```

## Testing

1. Verify with browser at `/admin/decision_trees/:uuid`
2. Run existing request spec: `bundle exec rspec spec/requests/admin/decision_trees_spec.rb`
