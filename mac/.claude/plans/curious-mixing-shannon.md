# Plan: ActionCable + Live-Reload for Identity Report

## Goal
Enable ActionCable and implement live-reloading for the identity report view when IDV data updates via Plaid webhooks. When an officer is viewing a partial identity report (documentary verification complete, selfie pending), the page should automatically update when the selfie check completes.

## Current State
- ActionCable is **disabled** in `config/application.rb` (line 16: `# require "action_cable/engine"`)
- No `config/cable.yml`, no `app/channels/` directory
- No Redis - app uses Solid Queue (PostgreSQL-backed) for background jobs
- `turbo-rails` is installed and Turbo Streams are used sparingly

## Architectural Decisions

### 1. Adapter: Solid Cable (PostgreSQL)
- Matches existing Solid Queue pattern (no new infrastructure)
- Identity report updates are infrequent (webhook-driven)
- Can migrate to Redis later if needed

### 2. Turbo Streams over ActionCable
- Already have `turbo-rails` installed
- Provides declarative DOM updates without custom JavaScript
- Uses signed stream names for security

### 3. Broadcast Trigger
- Broadcast after `IdentityReport#refresh!` completes
- Stream scoped to the specific identity report

## Files to Modify/Create

### Phase 1: Enable ActionCable Infrastructure

| File | Action | Description |
|------|--------|-------------|
| `config/application.rb` | Edit | Uncomment `require "action_cable/engine"` (line 16) |
| `Gemfile` | Edit | Add `gem 'solid_cable'` |
| `config/cable.yml` | Create | Configure Solid Cable adapter |
| `app/channels/application_cable/connection.rb` | Create | WebSocket authentication |
| `app/channels/application_cable/channel.rb` | Create | Base channel class |

### Phase 2: Implement Broadcasting

| File | Action | Description |
|------|--------|-------------|
| `app/models/customers/identity_report.rb` | Edit | Add `broadcasts_refreshes` or manual broadcast after refresh |
| `app/views/escrows/identities/show.html.slim` | Edit | Add `turbo_stream_from @id_report` subscription |

## Implementation Details

### 1. Enable ActionCable Engine
**File:** `config/application.rb`
```ruby
# Change line 16 from:
# require "action_cable/engine"
# To:
require "action_cable/engine"
```

### 2. Add Solid Cable Gem
**File:** `Gemfile`
```ruby
gem 'solid_cable'
```

Then run:
```bash
bundle install
bin/rails solid_cable:install
```

### 3. Configure Cable
**File:** `config/cable.yml`
```yaml
development:
  adapter: solid_cable
  polling_interval: 0.1.seconds

test:
  adapter: test

production:
  adapter: solid_cable
  polling_interval: 0.1.seconds
```

### 4. Create Connection Class
**File:** `app/channels/application_cable/connection.rb`
```ruby
# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_person

    def connect
      self.current_person = find_verified_person
    end

    private

    def find_verified_person
      session_token = cookies.encrypted[Auth::CookieManagement::SESSION_TOKEN]
      return reject_unauthorized_connection unless session_token

      session = UserSession.active.find_by(token: session_token)
      session&.person || reject_unauthorized_connection
    end
  end
end
```

### 5. Create Base Channel
**File:** `app/channels/application_cable/channel.rb`
```ruby
# frozen_string_literal: true

module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

### 6. Add Broadcast to Identity Report
**File:** `app/models/customers/identity_report.rb`

Add after line 27 (after `has_many :emails`):
```ruby
broadcasts_refreshes
```

Or for more control, add manual broadcast in `refresh!` method:
```ruby
def refresh!(notify: true, force: false)
  # ... existing code ...

  broadcast_refresh_later
  self
end
```

### 7. Subscribe in View
**File:** `app/views/escrows/identities/show.html.slim`

Add at the very top (before line 1):
```slim
= turbo_stream_from @id_report
```

And wrap the main content in a turbo frame with the report's DOM ID:
```slim
= turbo_frame_tag dom_id(@id_report) do
  - checks = @id_report.checks
  - content_for(:escrow_customer_tab) do
    / ... existing content ...
```

## Verification

### 1. Run migrations and restart server
```bash
bundle install
bin/rails solid_cable:install
bin/rails db:migrate
bin/dev
```

### 2. Manual Testing
1. Start IDV for a customer with selfie check enabled
2. Complete documentary verification, exit before selfie
3. Open the identity report as an officer in one browser tab
4. In another tab/device, complete the selfie check
5. Verify the officer's view updates automatically without refresh

### 3. Check WebSocket Connection
In browser dev tools → Network → WS tab:
- Should see connection to `/cable`
- Should see subscription to identity report stream

### 4. Run Tests
```bash
bundle exec rspec spec/models/customers/identity_report_spec.rb
bundle exec rspec spec/system/escrows/identities_spec.rb
```

## Notes

- `broadcasts_refreshes` uses Turbo's morphing to update the page smoothly
- Authorization is handled via signed stream names (Turbo) + connection authentication
- Solid Cable uses PostgreSQL LISTEN/NOTIFY - polling interval of 0.1s provides near-real-time updates
- No separate process needed - ActionCable runs in the web process
