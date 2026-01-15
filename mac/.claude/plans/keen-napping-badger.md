# Plan: Expand Officer Permissions to Match Admin

## Summary
Expand officer role permissions so officers can:
1. See and use the "Officer" field when creating escrows
2. Edit all escrows in their organization (not just assigned ones)
3. Change the officer assignment on any escrow
4. See the Officer filter dropdown on the Escrows index with all officer options

## Files to Modify

### 1. `app/models/current.rb`

**Change `can_change_escrow_officer?` (line 112-114)**

Current:
```ruby
def can_change_escrow_officer?
  super_admin? || org_admin?
end
```

New:
```ruby
def can_change_escrow_officer?
  super_admin? || org_admin? || org_officer?
end
```

This enables:
- Officers see the "Officer" field in Add/Edit Escrow forms
- Officers can select/change the officer assignment
- Controllers will permit the `officer_uuid` parameter for officers

**Change `can_edit_escrow?` (lines 102-110)**

Current:
```ruby
def can_edit_escrow?(escrow)
  if org_officer?
    escrow.officer_id == person.id
  elsif org_admin?
    escrow.organization_id == organization.id
  else
    super_admin?
  end
end
```

New:
```ruby
def can_edit_escrow?(escrow)
  if org_officer? || org_admin?
    escrow.organization_id == organization.id
  else
    super_admin?
  end
end
```

### 2. `app/presenters/escrows_presenter.rb`

**Change `officer_options` method (lines 4-19)**

Current:
```ruby
def self.officer_options(person: nil)
  return [] if person.nil?

  admin_org_ids = person.organization_memberships.admins.flat_map(&:organization_id)
  if person.super_admin?
    officers = Person.joins(:organization_memberships).uniq
  elsif admin_org_ids.any?
    officers = Person.includes(:organization_memberships).where(organization_memberships: { organization_id: admin_org_ids }).uniq
  else
    return []
  end

  [['All', '']] + officers.sort_by(&:first_name).map { |o| [o.full_name, o.uuid] }
end
```

New:
```ruby
def self.officer_options(person: nil)
  return [] if person.nil?

  admin_org_ids = person.organization_memberships.admins.flat_map(&:organization_id)
  officer_org_ids = person.organization_memberships.officers.flat_map(&:organization_id)
  relevant_org_ids = (admin_org_ids + officer_org_ids).uniq

  if person.super_admin?
    officers = Person.joins(:organization_memberships).uniq
  elsif relevant_org_ids.any?
    officers = Person.includes(:organization_memberships).where(organization_memberships: { organization_id: relevant_org_ids }).uniq
  else
    return []
  end

  [['All', '']] + officers.sort_by(&:first_name).map { |o| [o.full_name, o.uuid] }
end
```

### 3. `spec/presenters/escrows_presenter_spec.rb`

**Update test at lines 51-55**

The existing test asserts officers get empty array. This needs to change to expect officers see their org's people.

Current (lines 51-54):
```ruby
# Officer view
options = described_class.officer_options(person: officer)

expect(options).to eq([])
```

New:
```ruby
# Officer view - officers now see all people in their organization
options = described_class.officer_options(person: officer)

expect(options).to eq([
  ['All', ''],
  ['Alice Jones', officer.uuid],
  ['Bob Smith', admin.uuid]
])
```

## Files That Will Work Automatically (No Changes Needed)

These files already use the methods we're modifying:

| File | Why No Changes Needed |
|------|----------------------|
| `app/views/escrows/_form.html.slim` | Uses `Current.can_change_escrow_officer?` |
| `app/views/modular_tasks/escrows/_form.html.slim` | Uses `Current.can_change_escrow_officer?` |
| `app/controllers/escrows_controller.rb` | Uses `Current.can_change_escrow_officer?` for params |
| `app/controllers/modular_tasks/escrows_controller.rb` | Uses `Current.can_change_escrow_officer?` for params |
| `app/views/escrows/index.html.slim` | Already shows filter when `@officer_options.any?` |
| `app/views/escrows/_base.html.slim` | Uses `Current.can_edit_escrow?(escrow)` |

## Verification

1. **Test officer field in Add Escrow flow:**
   - Log in as an officer
   - Navigate to create new escrow
   - Verify "Officer" dropdown is visible
   - Verify can select a different officer

2. **Test officer can edit all escrows:**
   - Log in as an officer
   - Navigate to escrows index
   - Verify can see edit button on escrows assigned to other officers
   - Verify can edit and change officer on those escrows

3. **Test officer filter on Escrows index:**
   - Log in as an officer
   - Navigate to escrows index
   - Verify "Officer" filter dropdown is visible
   - Verify dropdown contains all officers in the organization

4. **Run existing tests:**
   ```bash
   bundle exec rspec spec/models/current_spec.rb
   bundle exec rspec spec/presenters/escrows_presenter_spec.rb
   bundle exec rspec spec/controllers/escrows_controller_spec.rb
   bundle exec rspec spec/integration/officer_flows/
   ```
