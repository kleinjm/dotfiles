# Plan: Add IDV Photo/Selfie Activities from Plaid Link Events

## Overview
Add 4 new EscrowActivity types that are tracked when specific Plaid Link events are received during identity verification. Activities should only be tracked for legacy flow customers (not modular flow).

## Event-to-Activity Mapping

| Activity | Plaid Event Name | Metadata view_name |
|----------|------------------|-------------------|
| Started ID Photo | `IDENTITY_VERIFICATION_START_STEP` | `DOCUMENTARY_VERIFICATION` |
| Finished ID Photo | `IDENTITY_VERIFICATION_PASS_STEP` or `IDENTITY_VERIFICATION_FAIL_STEP` | `DOCUMENTARY_VERIFICATION` |
| Started Selfie Video | `IDENTITY_VERIFICATION_START_STEP` | `SELFIE_CHECK` |
| Finished Selfie Video | `IDENTITY_VERIFICATION_PASS_STEP` or `IDENTITY_VERIFICATION_FAIL_STEP` | `SELFIE_CHECK` |

**Pattern:** `START_STEP` = Started, `PASS/FAIL_STEP` = Finished. `view_name` determines the step type.

## Implementation Steps

### Phase 1: Add Activity Translations
**File:** `config/locales/escrow_events/en.yml`

Add under `seller:` section (near existing IDV activities):
```yaml
started_id_photo: "Started ID Photo"
finished_id_photo: "Finished ID Photo"
started_selfie_video: "Started Selfie Video"
finished_selfie_video: "Finished Selfie Video"
```

### Phase 2: TDD - Write Service Tests First
**File:** `spec/services/customers/identity_verification/process_plaid_link_event_service_spec.rb`

Add new test context for activity tracking:

```ruby
context 'activity tracking for legacy flow customers' do
  it 'tracks started_id_photo for IDENTITY_VERIFICATION_START_STEP with DOCUMENTARY_VERIFICATION'
  it 'tracks finished_id_photo for IDENTITY_VERIFICATION_PASS_STEP with DOCUMENTARY_VERIFICATION'
  it 'tracks finished_id_photo for IDENTITY_VERIFICATION_FAIL_STEP with DOCUMENTARY_VERIFICATION'
  it 'tracks started_selfie_video for IDENTITY_VERIFICATION_START_STEP with SELFIE_CHECK'
  it 'tracks finished_selfie_video for IDENTITY_VERIFICATION_PASS_STEP with SELFIE_CHECK'
  it 'tracks finished_selfie_video for IDENTITY_VERIFICATION_FAIL_STEP with SELFIE_CHECK'
  it 'does not track activities for modular flow customers'
  it 'does not track activities for unrelated events'
end
```

### Phase 3: Implement Activity Tracking in Service
**File:** `app/services/customers/identity_verification/process_plaid_link_event_service.rb`

Add private methods to track activities after event creation:

```ruby
def call
  return log_missing_link_request_warning if link_request.nil?

  event = create_event
  update_link_request(event)
  track_activities(event)  # NEW

  Success(event)
end

private

def track_activities(event)
  return if customer.modular_flow?

  activity = event.idv_activity
  customer.track_activity(activity, timestamp: event.timestamp) if activity
end

def customer
  identity_verification.customer
end
```

### Phase 4: TDD - Add Model Spec for idv_activity Method
**File:** `spec/models/integrations/plaid/link_request_event_spec.rb`

Add tests for the new `idv_activity` method:
```ruby
describe '#idv_activity' do
  it 'returns :started_id_photo for START_STEP with DOCUMENTARY_VERIFICATION'
  it 'returns :finished_id_photo for PASS_STEP with DOCUMENTARY_VERIFICATION'
  it 'returns :finished_id_photo for FAIL_STEP with DOCUMENTARY_VERIFICATION'
  it 'returns :started_selfie_video for START_STEP with SELFIE_CHECK'
  it 'returns :finished_selfie_video for PASS_STEP with SELFIE_CHECK'
  it 'returns :finished_selfie_video for FAIL_STEP with SELFIE_CHECK'
  it 'returns nil for unrelated events'
end
```

### Phase 5: Add Event Constants to LinkRequestEvent Model
**File:** `app/models/integrations/plaid/link_request_event.rb`

Add hash constant for IDV activity mapping (similar to CSTATUSES pattern):
```ruby
# Existing constant
START_EVENTS = %w[onLoad OPEN].freeze

# New constants for IDV activity tracking
EVENTS = {
  idv_start_step: 'IDENTITY_VERIFICATION_START_STEP',
  idv_pass_step: 'IDENTITY_VERIFICATION_PASS_STEP',
  idv_fail_step: 'IDENTITY_VERIFICATION_FAIL_STEP'
}.freeze

VIEW_NAMES = {
  documentary: 'DOCUMENTARY_VERIFICATION',
  selfie: 'SELFIE_CHECK'
}.freeze

# Activity mapping: [event_key, view_key] => activity_name
IDV_ACTIVITIES = {
  [EVENTS[:idv_start_step], VIEW_NAMES[:documentary]] => :started_id_photo,
  [EVENTS[:idv_pass_step], VIEW_NAMES[:documentary]] => :finished_id_photo,
  [EVENTS[:idv_fail_step], VIEW_NAMES[:documentary]] => :finished_id_photo,
  [EVENTS[:idv_start_step], VIEW_NAMES[:selfie]] => :started_selfie_video,
  [EVENTS[:idv_pass_step], VIEW_NAMES[:selfie]] => :finished_selfie_video,
  [EVENTS[:idv_fail_step], VIEW_NAMES[:selfie]] => :finished_selfie_video
}.freeze

def idv_activity
  IDV_ACTIVITIES[[name, metadata&.dig('view_name')]]
end
```

## Files to Modify

| Action | File |
|--------|------|
| Modify | `config/locales/escrow_events/en.yml` |
| Modify | `app/models/integrations/plaid/link_request_event.rb` |
| Modify | `spec/models/integrations/plaid/link_request_event_spec.rb` |
| Modify | `spec/services/customers/identity_verification/process_plaid_link_event_service_spec.rb` |
| Modify | `app/services/customers/identity_verification/process_plaid_link_event_service.rb` |

## Test Verification

Run tests after each phase:
```bash
bundle exec rspec spec/models/integrations/plaid/link_request_event_spec.rb spec/services/customers/identity_verification/process_plaid_link_event_service_spec.rb
```

## Notes
- Use `track_activity` (not `track_activity_once`) since each event should create an activity
- Activities use the event timestamp, not current time
- Existing `started_idv` and `completed_idv` activities are tracked elsewhere (in `process_plaid_idv_data`) and remain unchanged
