# Fix IDV Activity Log Ordering

## Problem

IDV (Identity Verification) activities sometimes display out of order in the escrow activity log.

**Current (incorrect) display order** (most recent first):
- "Started ID Photo"
- "Started Selfie Video" ← wrong position
- "Finished ID Photo"
- "Finished Selfie Video"

**Expected display order** (most recent first):
1. Finished Selfie Video (newest)
2. Started Selfie Video
3. Finished ID Photo
4. Started ID Photo (oldest)

**Logical chronological order** (actual flow):
1. Started ID Photo
2. Finished ID Photo
3. Started Selfie Video
4. Finished Selfie Video

## Root Cause

Per Plaid documentation, webhooks may arrive out of order. While each event has an ISO 8601 timestamp with millisecond precision (e.g., `2017-09-14T14:42:19.350Z`), events in the IDV flow happen very close together (within milliseconds). When events have identical or very close timestamps, database insertion order becomes the tie-breaker, which reflects webhook arrival order rather than logical flow order.

## Solution

Add secondary ordering by event sequence in the `all_activities` query. This ensures that when timestamps are equal (or very close), IDV events display in their logical order.

### Approach: SQL CASE WHEN Secondary Sort

Modify `EscrowActivitiesLog#all_activities` to include a secondary sort by event sequence:

```ruby
def all_activities
  @escrow.activities.order(
    Arel.sql(<<~SQL.squish)
      timestamp DESC,
      CASE event
        WHEN 'completed_idv' THEN 1
        WHEN 'finished_selfie_video' THEN 2
        WHEN 'started_selfie_video' THEN 3
        WHEN 'finished_id_photo' THEN 4
        WHEN 'started_id_photo' THEN 5
        WHEN 'started_idv' THEN 6
        ELSE 0
      END ASC
    SQL
  )
end
```

The sequence numbers are assigned so that when viewing most-recent-first (DESC), events that logically occur later in the IDV flow appear first. Events with sequence 0 (non-IDV events) are unaffected as they sort by timestamp alone.

## Files to Modify

1. **`app/models/escrow_activities_log.rb`** - Update `all_activities` method with secondary sort

## TDD Approach

### Test Data (from production)

Key insight from seller `aa2b4697-b9f6-4199-8f56-f938cf75754f`:
- `finished_id_photo` and `started_selfie_video` have **identical timestamps** (`2026-01-12 16:21:20.024Z`)
- This occurs because Plaid sends `FAIL_STEP` (documentary) and `START_STEP` (selfie) at the same instant

Production activity data:
```
started_idv           | 2026-01-12 16:18:40.573Z
started_id_photo      | 2026-01-12 16:18:47.942Z
finished_id_photo     | 2026-01-12 16:21:20.024Z  <- SAME timestamp
started_selfie_video  | 2026-01-12 16:21:20.024Z  <- SAME timestamp
finished_selfie_video | 2026-01-12 16:22:05.131Z
completed_idv         | 2026-01-12 16:22:09.025Z
```

### Step 1: Write failing test

Add to `spec/models/escrow_activities_log_spec.rb`:

```ruby
describe '#all_activities' do
  it 'orders IDV activities by logical sequence when timestamps are identical' do
    escrow = create(:escrow)
    seller = create(:seller, escrow:)

    # Simulate production scenario: finished_id_photo and started_selfie_video
    # have identical timestamps (Plaid sends them at same instant during transition)
    identical_timestamp = Time.parse('2026-01-12 16:21:20.024Z')

    # Create activities in wrong order (simulating out-of-order webhook delivery)
    started_selfie = escrow.activities.create!(
      category: 'seller', event: 'started_selfie_video',
      customer: seller, timestamp: identical_timestamp, whodunnit: seller
    )
    finished_id_photo = escrow.activities.create!(
      category: 'seller', event: 'finished_id_photo',
      customer: seller, timestamp: identical_timestamp, whodunnit: seller
    )

    activities = escrow.activities_log.all_activities

    # In DESC order (most recent first), started_selfie_video should appear
    # BEFORE finished_id_photo because selfie logically happens after ID photo
    expect(activities.to_a).to eq([started_selfie, finished_id_photo])
  end
end
```

### Step 2: Run test (should fail)

```bash
bundle exec rspec spec/models/escrow_activities_log_spec.rb -e "orders IDV activities"
```

### Step 3: Implement fix

Update `app/models/escrow_activities_log.rb`

### Step 4: Run test (should pass)

## Verification Plan

1. **Unit tests**: Run the new test plus existing tests
   ```bash
   bundle exec rspec spec/models/escrow_activities_log_spec.rb
   ```

2. **Manual verification**: In Rails console, verify the fix with production-like data:
   ```ruby
   escrow = create(:escrow)
   seller = create(:seller, escrow:)
   ts = Time.current

   escrow.activities.create!(category: 'seller', event: 'started_selfie_video',
     customer: seller, timestamp: ts, whodunnit: seller)
   escrow.activities.create!(category: 'seller', event: 'finished_id_photo',
     customer: seller, timestamp: ts, whodunnit: seller)

   escrow.activities_log.all_activities.pluck(:event)
   # Should return: ["started_selfie_video", "finished_id_photo"]
   ```

## Alternatives Considered

1. **Store sequence column**: Add `idv_step_sequence` column to `escrow_activities` table. Rejected as it requires schema migration and is over-engineered for this use case.

2. **Adjust timestamps at creation**: Artificially offset timestamps based on logical order. Rejected as it modifies actual event timing data.

3. **Sort in Ruby after fetch**: Post-process the query results. Rejected as it breaks pagination.
