# Plan: Super Admin Permissions for Officers and Membership Role Editing

## Summary
Update permissions so super admins (not just sudoers) can access the Officers page and manage organization memberships, including editing membership roles.

## TDD Implementation Order

### Phase 1: Write Tests First (TDD)

#### 1.1 Service Unit Test (NEW)
**File:** `spec/services/organization_membership/update_service_spec.rb` (new file)

Write specs for the new `OrganizationMembership::UpdateService`:
- Success case: updates membership role
- Failure case: invalid role returns failure
- Failure case: no changes provided returns failure
- Returns Success with membership on success
- Returns Failure with error message on failure

```ruby
RSpec.describe OrganizationMembership::UpdateService do
  describe '.call' do
    it 'updates membership role from officer to admin' do
      membership = create(:organization_membership, role: 'officer')
      result = described_class.call(membership:, role: 'admin')
      expect(result).to be_success
      expect(membership.reload.role).to eq('admin')
    end

    it 'returns failure for invalid role' do
      membership = create(:organization_membership, role: 'officer')
      result = described_class.call(membership:, role: 'invalid')
      expect(result).to be_failure
    end
  end
end
```

#### 1.2 Request Specs
**File:** `spec/requests/admin/memberships_spec.rb` (modify existing)

Add new describe blocks for edit/update:

```ruby
describe 'GET /admin/users/:user_id/memberships/:id/edit' do
  it 'requires authentication'
  it 'denies access to regular es_employees'
  it 'allows super_admin to access edit form'
  it 'displays membership role in form'
end

describe 'PATCH /admin/users/:user_id/memberships/:id' do
  it 'requires authentication'
  it 'denies access to regular es_employees'
  it 'allows super_admin to update membership role'
  it 'redirects with success message on update'
  it 'renders edit form on validation error'
end
```

Also update existing tests to verify super_admin (non-sudoer) access for `new` and `create`.

#### 1.3 Policy Specs (NEW)
**File:** `spec/policies/admin/organization_membership_policy_spec.rb` (new file)

```ruby
RSpec.describe Admin::OrganizationMembershipPolicy do
  permissions :new?, :create?, :edit?, :update? do
    it 'grants access to super_admins'
    it 'denies access to regular es_employees'
  end
end
```

---

### Phase 2: Implement Service

#### 2.1 Create Update Service
**File:** `app/services/organization_membership/update_service.rb` (new file)

```ruby
class OrganizationMembership::UpdateService < ApplicationService
  description 'Updates an organization membership role'

  argument :membership, Type::ApplicationRecord, description: 'The membership to update'
  argument :role, Type::String, description: 'The new role (admin or officer)'

  def call
    membership.role = role
    return Failure(membership.errors.full_messages.join(', ')) unless membership.save

    Success(membership)
  end
end
```

---

### Phase 3: Implement Authorization & Routes

#### 3.1 Policy Changes
**File:** `app/policies/admin/organization_membership_policy.rb`

Change `new?` and `create?` from `sudoer?` to `super_admin?`, add `edit?` and `update?`:

```ruby
class Admin::OrganizationMembershipPolicy < Admin::BasePolicy
  def new?
    super_admin?
  end

  def create?
    super_admin?
  end

  def edit?
    super_admin?
  end

  def update?
    super_admin?
  end
end
```

#### 3.2 Route Changes
**File:** `config/routes/admin.rb`

Line 28: Change `only: %i[new create]` to `only: %i[new create edit update]`

---

### Phase 4: Implement Controller

**File:** `app/controllers/admin/memberships_controller.rb`

Add:
- `before_action :load_membership, only: %i[edit update]`
- `edit` action
- `update` action using `OrganizationMembership::UpdateService`
- `load_membership` private method

```ruby
def edit
  authorize @membership
end

def update
  authorize @membership

  result = OrganizationMembership::UpdateService.call(
    membership: @membership,
    role: params[:organization_membership][:role]
  )

  result.either(
    ->(membership) { redirect_to admin_user_path(@person), status: :see_other, notice: 'Membership role was updated.' },
    ->(error) { @error = error; render :edit, status: :unprocessable_content }
  )
end

def load_membership
  @membership = @person.organization_memberships.find(params[:id])
end
```

---

### Phase 5: Implement Navigation & Views

#### 5.1 Navigation
**File:** `app/views/admin/_navigation.html.slim`

Line 17: Change `Current.sudoer?` to `Current.sudoer? || Current.super_admin?`

#### 5.2 User Show Page
**File:** `app/views/admin/users/show.html.slim`

Update lines 38-43 to display roles with edit links:
- Show organization name + role badge for each membership
- Add "Edit" link for each membership (if policy allows)
- Use `@person.organization_memberships.includes(:organization)`

#### 5.3 Edit View (NEW)
**File:** `app/views/admin/memberships/edit.html.slim` (new file)

Create edit form:
- Breadcrumbs: Officers > {uuid} > Edit Membership
- Organization name (read-only)
- Role dropdown (admin/officer)
- Cancel and Update buttons

---

## Files to Create/Modify

| File | Action | Phase |
|------|--------|-------|
| `spec/services/organization_membership/update_service_spec.rb` | Create | 1 |
| `spec/requests/admin/memberships_spec.rb` | Modify | 1 |
| `spec/policies/admin/organization_membership_policy_spec.rb` | Create | 1 |
| `app/services/organization_membership/update_service.rb` | Create | 2 |
| `app/policies/admin/organization_membership_policy.rb` | Modify | 3 |
| `config/routes/admin.rb` | Modify | 3 |
| `app/controllers/admin/memberships_controller.rb` | Modify | 4 |
| `app/views/admin/_navigation.html.slim` | Modify | 5 |
| `app/views/admin/users/show.html.slim` | Modify | 5 |
| `app/views/admin/memberships/edit.html.slim` | Create | 5 |

## Key Notes
- `OrganizationMembership::ROLES = { admin: 'admin', officer: 'officer' }`
- Membership uses integer `id`, not uuid
- Sudoers are automatically super_admins, so existing sudoer access unchanged
- Service pattern follows existing `Escrow::UpdateService` pattern
- TDD: Write failing tests first, then implement to make them pass
