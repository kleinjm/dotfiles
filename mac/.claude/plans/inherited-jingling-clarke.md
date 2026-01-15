# Fix N+1 Query on Escrows Index Page

## Problem

The `/organizations/:slug/escrows` page triggers 2N+1 queries (where N = number of escrows, up to 50 per page):
- For each escrow: 1 query for buyers, 1 query for sellers
- With 10 escrows: 20 extra queries

**Root cause**: The view calls `escrow.buyers.first(2)` and `escrow.sellers.first(2)` in a loop, but `buyers` and `sellers` are query-building methods, not associations that can be preloaded.

## TDD Approach

### Verify the N+1 Before Fix

1. Run existing spec that exercises the index page:
   ```bash
   bundle exec rspec spec/requests/escrows_requests_spec.rb:7
   ```

2. Check test.log for N+1 queries:
   ```bash
   grep "Customer Load.*type.*Buyer" log/test.log | tail -20
   ```
   Expected: Multiple `Customer Load` queries with different `escrow_id` values

### Verify Fix After Implementation

Run the same test and check logs again - should see only 2 customer queries (one for buyers, one for sellers) instead of 2N.

## Why Methods Instead of Associations?

The code comments say: `# :: required to avoid Escrow::Customer namespace conflict`

This was likely a **historical concern** from when the code was written:
- Ruby's constant lookup checks `Escrow::Customer` before `::Customer`
- The developer used `::Customer.where(...)` to explicitly reference the top-level Customer class

**However, for associations this isn't a problem** because:
- `has_many :buyers, class_name: 'Customer'` explicitly specifies the class
- Rails resolves `class_name` strings from the top-level namespace

## Functional Differences: Method vs Association

| Aspect | Current Method | Proposed Association |
|--------|---------------|---------------------|
| Return type | `ActiveRecord::Relation` | `ActiveRecord::AssociationRelation` |
| Eager loading | Cannot use `.includes(:buyers)` | Can use `.includes(:buyers)` |
| Caching | No caching | Cached within request |
| Building new records | Cannot do `escrow.buyers.build` | Can do `escrow.buyers.build` |
| Query behavior | Same query | Same query |

The association approach is strictly better for this use case - it enables eager loading while maintaining identical query behavior.

## Solution

Add scoped `has_many` associations and use eager loading.

## Implementation Steps

### 1. Add associations to Escrow model

**File**: `app/models/escrow.rb` (after line 55)

Add after the existing `has_many :customers` line:
```ruby
has_many :buyers, -> { where(type: 'Buyer').order(:id) }, class_name: 'Customer', inverse_of: false
has_many :sellers, -> { where(type: 'Seller').order(:id) }, class_name: 'Customer', inverse_of: false
```

The existing `buyers` and `sellers` methods (lines 193-196 and 208-211) will be shadowed by these associations. They can be removed or renamed later.

### 2. Update main escrows controller

**File**: `app/controllers/escrows_controller.rb` (line 120)

Change:
```ruby
visible_escrows = Current.visible_escrows.includes(:officer)
```
To:
```ruby
visible_escrows = Current.visible_escrows.includes(:officer, :buyers, :sellers)
```

### 3. Update main escrows view

**File**: `app/views/escrows/_table.html.slim` (lines 41 and 51)

Change `.first(2)` to `.take(2)`:
- Line 41: `escrow.buyers.take(2)`
- Line 51: `escrow.sellers.take(2)`

Note: `.take(2)` operates on the preloaded collection; `.first(2)` would execute a new LIMIT query.

### 4. Update admin escrows controller

**File**: `app/controllers/admin/escrows_controller.rb` (line 71)

Change:
```ruby
base_query = base_query.includes(:organization, :officer)
```
To:
```ruby
base_query = base_query.includes(:organization, :officer, :buyers, :sellers)
```

### 5. Update admin escrows view

**File**: `app/views/admin/escrows/index.html.slim`

Changes:
- Line 51: `escrow.buyers.take(2)` (was `.first(2)`)
- Line 55: `escrow.buyers.size` (was `.count`) - uses preloaded collection
- Line 59: `escrow.sellers.take(2)` (was `.first(2)`)
- Line 63: `escrow.sellers.size` (was `.count`) - uses preloaded collection

### 6. Remove or rename old methods (optional cleanup)

**File**: `app/models/escrow.rb`

The `buyers` and `sellers` methods (lines 193-211) are now shadowed by associations. Options:
- Remove them entirely (if no other code depends on them)
- Rename to `buyers_relation` / `sellers_relation` if needed elsewhere
- Leave as-is (associations take precedence)

## Files to Modify

| File | Changes |
|------|---------|
| `app/models/escrow.rb` | Add 2 has_many associations |
| `app/controllers/escrows_controller.rb:120` | Add `:buyers, :sellers` to includes |
| `app/views/escrows/_table.html.slim:41,51` | `.first(2)` → `.take(2)` |
| `app/controllers/admin/escrows_controller.rb:71` | Add `:buyers, :sellers` to includes |
| `app/views/admin/escrows/index.html.slim:51,55,59,63` | `.first(2)` → `.take(2)`, `.count` → `.size` |

## Expected Result

- Before: 2N+1 queries (e.g., 21 queries for 10 escrows)
- After: 3 queries (escrows, buyers, sellers)

## Testing

1. Manual: Check Rails logs for query count on `/organizations/:slug/escrows`
2. Add model specs for new associations:
   ```ruby
   it { is_expected.to have_many(:buyers).class_name('Customer') }
   it { is_expected.to have_many(:sellers).class_name('Customer') }
   ```
