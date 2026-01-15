# Admin DecisionTrees Index and Show Pages

## Overview
Create admin pages for viewing DecisionTrees, restricted to super_admins and sudoers only.

## Files to Create

### 1. Route - `/workspaces/web/config/routes/admin.rb`
Add after line 24 (after `plaid_link_requests`):
```ruby
resources :decision_trees, only: %i[index show]
```

### 2. Policy - `/workspaces/web/app/policies/admin/decision_tree_policy.rb`
```ruby
class Admin::DecisionTreePolicy < Admin::BasePolicy
  def index?
    super_admin?
  end

  def show?
    super_admin?
  end

  class Scope < Admin::BasePolicy::Scope
    def resolve
      return scope.none unless super_admin?
      scope.all
    end
  end
end
```

### 3. Controller - `/workspaces/web/app/controllers/admin/decision_trees_controller.rb`
```ruby
class Admin::DecisionTreesController < Admin::BaseController
  before_action :set_decision_tree!, only: :show

  def index
    @decision_trees = policy_scope(DecisionTree)
                      .includes(:step_residential, :step_entities, :step_exemptions, :step_financing)
                      .order(created_at: :desc)
                      .page(params[:page])
    authorize DecisionTree
  end

  def show
    authorize @decision_tree
    @presenter = DecisionTreePresenter.new(@decision_tree)
  end

  private

  def set_decision_tree!
    @decision_tree = DecisionTree.find_by!(uuid: params[:id])
  end
end
```

### 4. Index View - `/workspaces/web/app/views/admin/decision_trees/index.html.slim`
- Breadcrumb navigation
- Table with columns: ID, Email, Status, Current Progress, Created, Updated
- Current Progress displays `presenter.current_progress_label`
- Pagination

### 5. Show View - `/workspaces/web/app/views/admin/decision_trees/show.html.slim`
- Breadcrumb with link back to index
- Definition list with: UUID, Email, Reference, Status, Outcome, Current Progress, Property Address, Closes On, Created, Updated
- Steps section showing completion status badges for each step
- Linked Escrow section (if escrow exists)

## Files to Modify

### 6. Presenter - `/workspaces/web/app/presenters/decision_tree_presenter.rb`
Add `current_progress_label` method:
- For completed trees: Return outcome text (e.g., "Filing Required", "Filing Not Required")
- For in-progress trees: Return last completed step name without "Step " prefix (e.g., "Residential", "Entities")
- For trees with no completed steps: Return "Intro"

```ruby
def current_progress_label
  return outcome_label if complete?
  last_step_label
end

private

def outcome_label
  return nil if decision_tree.outcome.blank?
  decision_tree.outcome.titleize.gsub('_', ' ')
end

def last_step_label
  if step_financing&.step_complete?
    'Financing'
  elsif step_exemptions&.step_complete?
    'Exemptions'
  elsif step_entities&.step_complete?
    'Entities'
  elsif step_residential&.step_complete?
    'Residential'
  else
    'Intro'
  end
end
```

## Test Files to Create

### 7. Request Spec - `/workspaces/web/spec/requests/admin/decision_trees_spec.rb`
Two happy path tests only:

```ruby
RSpec.describe 'Admin::DecisionTrees' do
  describe 'GET /admin/decision_trees' do
    it 'returns successful response and displays decision trees' do
      decision_tree = create(:decision_tree)
      super_admin = create(:super_admin)
      sign_in_as super_admin

      get admin_decision_trees_path

      expect(response).to be_successful
      expect(response.body).to include(decision_tree.uuid[0..7])
    end
  end

  describe 'GET /admin/decision_trees/:id' do
    it 'returns successful response and displays decision tree details' do
      decision_tree = create(:decision_tree)
      super_admin = create(:super_admin)
      sign_in_as super_admin

      get admin_decision_tree_path(decision_tree.uuid)

      expect(response).to be_successful
      expect(response.body).to include(decision_tree.uuid)
    end
  end
end
```

## Implementation Order
1. Add route to `config/routes/admin.rb`
2. Create policy `app/policies/admin/decision_tree_policy.rb`
3. Add presenter method to `app/presenters/decision_tree_presenter.rb`
4. Create controller `app/controllers/admin/decision_trees_controller.rb`
5. Create index view `app/views/admin/decision_trees/index.html.slim`
6. Create show view `app/views/admin/decision_trees/show.html.slim`
7. Create request spec (2 happy path tests)
