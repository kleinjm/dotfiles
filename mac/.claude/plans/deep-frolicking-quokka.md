# FinCEN Integration into ModularTasks UI

**Status**: ✅ Phase 1 Complete
**Last Updated**: 2026-01-14

## Overview

Integrate the FinCEN reporting feature (`:fincen` flag) into the ModularTasks UI (`:modular_tasks` flag). Focus is on the **escrow officer-facing** workflow only.

**User Decisions**:
- Entry point: New FinCEN landing page (not existing property edit)
- Navigation: Update dynamically with `# TODO(mod-tasks):` comment for future cleanup
- Decision tree link: Placeholder for now (`new_fincen_decision_tree_path`)

---

## Implementation Plan

### Phase 1: Add Route

**File**: `config/routes/organizations.rb`

Add inside `namespace :modular_tasks` block (around line 63):
```ruby
resource :fincen, only: :show, controller: 'fincen'
```

Route: `GET /organizations/:organization_id/v2/escrows/:escrow_id/fincen`
Helper: `organization_modular_tasks_escrow_fincen_path(@organization, @escrow)`

---

### Phase 2: Create Controller

**New file**: `app/controllers/modular_tasks/fincen_controller.rb`

```ruby
class ModularTasks::FincenController < ModularTasks::BaseController
  before_action :set_escrow
  before_action :check_fincen_feature_flag

  def show
    @presenter = ModularTasks::FincenLandingPresenter.new(
      escrow: @escrow,
      organization: @organization
    )
  end

  private

  def set_escrow
    @escrow = Current.visible_escrows.find_by!(uuid: params[:escrow_id])
  end

  def check_fincen_feature_flag
    return if Flipper.enabled?(:fincen, @organization)
    redirect_to organization_modular_tasks_escrow_path(@organization, @escrow),
                alert: 'FinCEN features are not enabled for this organization.'
  end
end
```

---

### Phase 3: Create Presenter

**New file**: `app/presenters/modular_tasks/fincen_landing_presenter.rb`

Provides completion status for each section:
- `property_complete?` / `property_path`
- `buyers_complete?` / `buyers_path` / `buyers_count`
- `sellers_complete?` / `sellers_path` / `sellers_count`
- `payments_complete?` / `payments_path` (placeholder - returns false)
- `review_enabled?` / `review_path`
- `back_to_escrow_path`

Reuses existing FincenLayout paths for Property/Buyers/Sellers sub-pages.

---

### Phase 4: Update Escrow Show View

**File**: `app/views/modular_tasks/escrows/show.html.slim`

Add after the Escrow Parties section (line ~46):

```slim
- if Flipper.enabled?(:fincen, @organization)
  hr.my-4
  .d-flex.justify-content-between.align-items-center.mb-3
    .d-flex.align-items-center.gap-2
      i.bi.bi-file-earmark-text.fs-5
      h5.mb-0 FinCEN
    = link_to organization_modular_tasks_escrow_fincen_path(@organization, @escrow), class: 'btn btn-primary btn-sm'
      | Begin Report
  .text-muted.small
    = link_to 'Do you need to File? Decision Tree', new_fincen_decision_tree_path, class: 'text-muted'
```

---

### Phase 5: Create Landing Page View

**New file**: `app/views/modular_tasks/fincen/show.html.slim`

Layout matches Figma (node 7569:4491):
- Title: "FinCEN Report"
- Description with Decision Tree link
- Note about auto-save
- Checklist items: Property, Buyers, Sellers, Payments (disabled), Review and Submit
- Each item has: checkbox icon, title, chevron, optional badge/count
- "Begin Report" button at bottom (enabled when review_enabled?)

**New file**: `app/views/modular_tasks/fincen/_checklist_item.html.slim`

Partial for each row with params: title, complete, path, disabled, disabled_reason, badge_count

---

### Phase 6: Update FinCEN Navigation

**File**: `app/views/shared/_fincen_navigation.html.slim`

Update back link to be context-aware:

```slim
/ TODO(mod-tasks): Remove conditional logic once modular_tasks is fully rolled out
- if params[:from_modular_tasks] == 'true'
  = link_to organization_modular_tasks_escrow_fincen_path(organization, escrow), class: ['sidebar-content-back-button']
    = inline_svg 'icons/icon-arrow-left.svg', class: 'sidebar-content-back-button-icon'
    | FinCEN Report
- else
  = link_to organization_escrow_path(organization, escrow), class: ['sidebar-content-back-button']
    = inline_svg 'icons/icon-arrow-left.svg', class: 'sidebar-content-back-button-icon'
    | Dashboard
```

Pass `from_modular_tasks: true` query param through all FincenLayout links.

---

## Files Summary

| File | Action |
|------|--------|
| `config/routes/organizations.rb` | Add `resource :fincen` route |
| `app/controllers/modular_tasks/fincen_controller.rb` | **Create** - new controller |
| `app/presenters/modular_tasks/fincen_landing_presenter.rb` | **Create** - new presenter |
| `app/views/modular_tasks/escrows/show.html.slim` | Add FinCEN section |
| `app/views/modular_tasks/fincen/show.html.slim` | **Create** - landing page |
| `app/views/modular_tasks/fincen/_checklist_item.html.slim` | **Create** - checklist partial |
| `app/views/shared/_fincen_navigation.html.slim` | Add context-aware back link |

---

## Verification Plan

1. **Setup**: Enable both `:modular_tasks` and `:fincen` for test organization
2. **Escrow Show**: Navigate to `/organizations/:org/v2/escrows/:escrow`
   - Verify FinCEN section appears below Parties
   - Verify "Begin Report" button links to new landing page
3. **Landing Page**: Click "Begin Report"
   - Verify checklist shows Property, Buyers, Sellers, Payments, Review
   - Verify Payments is disabled with "Coming Soon"
   - Verify Review is disabled until sections complete
4. **Sub-page Navigation**: Click Property
   - Verify navigates to existing property edit page
   - Verify back link returns to FinCEN landing (not legacy dashboard)
5. **Flag Tests**:
   - With only `:modular_tasks` enabled - FinCEN section should NOT appear
   - With only `:fincen` enabled - v2 routes should redirect to legacy dashboard

---

## Implementation Complete

### Files Created
- `config/routes/organizations.rb` - Added `resource :fincen` route (line 64)
- `app/controllers/modular_tasks/fincen_controller.rb` - New controller with dual feature flag checks
- `app/presenters/modular_tasks/fincen_landing_presenter.rb` - New presenter for checklist completion tracking
- `app/views/modular_tasks/fincen/show.html.slim` - New landing page view
- `app/views/modular_tasks/fincen/_checklist_item.html.slim` - Checklist item partial
- `spec/requests/modular_tasks/fincen_request_spec.rb` - Request specs (3 tests)

### Files Modified
- `app/views/modular_tasks/escrows/show.html.slim` - Added FinCEN section
- `app/views/shared/_fincen_navigation.html.slim` - Back link always points to ModularTasks FinCEN landing page
- `app/views/escrows/_base.html.slim` - **Removed** legacy FinCEN section (FinCEN now only accessible via ModularTasks)

### Simplification Applied
- Removed FinCEN from legacy escrow show page - FinCEN is now only accessible through ModularTasks UI
- Removed `from_modular_tasks` query parameter logic - navigation always returns to ModularTasks context
- Simplified presenter by removing conditional path parameters

### Test Results
- All 35 ModularTasks request specs pass
- All 16 FincenLayout request specs pass
- No rubocop offenses

---

## Future Work (Out of Scope)

- [ ] Payments section implementation
- [ ] Customer-facing FinCEN in ModularTasks
- [ ] Remove legacy FincenLayout once modular_tasks fully rolled out
