# Plan: Automate Signup Follow-up Email (#2294)

## Summary
Send a follow-up email (`signup_followup`) 5 minutes after someone signs up via specific marketing forms on escrowsafe.com.

## Requirements
- Email template ID: `signup_followup`
- Delay: 5 minutes after signup
- Payload: `{ firstName: <optional> }` - use first_name if available
- Only trigger for explicit opt-in form_ids (NOT decision tree forms)

## Opt-In Form IDs
Based on issue notes, send follow-up for these form_ids:
- `home_hero` - Homepage "Request Demo"
- `home_footer` - Homepage footer "Learn More"
- `identity_hero` - Identity hero "Learn More"
- `identity_footer` - Identity footer "Learn More"
- `for_escrow_title_hero` - For Escrow/Title "Request Demo"
- `for_escrow_title_footer` - For Escrow/Title "Learn More"
- `fincen_footer` - FinCEN footer "Learn More"
- `security_footer` - Security footer "Learn More"
- `fraud_footer` - Fraud footer "Learn More"
- `for_home_buyers_footer` - For Home Buyers "Learn More"
- `for_home_sellers_footer` - For Home Sellers "Learn More"

**Excluded:**
- `decision_tree_invite_first`, `decision_tree_invite_second` - Decision tree invite forms
- `decision_tree_filing_required` - Decision tree filing required "Request Demo" button
- `nil` form_id - Unknown source

## Implementation Steps (TDD)

### Step 1: Add `decision_tree_filing_required` form_id

**1a. Write test** `spec/models/email_subscription_spec.rb`
- Test that `decision_tree_filing_required` is a valid form_id

**1b. Implement** `app/models/email_subscription.rb`
- Add `decision_tree_filing_required: 'decision_tree_filing_required'` to FORM_IDS constant

### Step 2: Create `EmailSubscription::CreateService`

This service replaces the existing `after_create` callback and handles all post-create logic:
- Create the EmailSubscription record
- Schedule Slack notification (existing behavior, moved from callback)
- Schedule followup email (new behavior)

**2a. Write test** `spec/services/email_subscription/create_service_spec.rb`
```ruby
# Test cases:
# - Creates EmailSubscription with provided attributes
# - Returns Success with email_subscription on success
# - Returns Failure with errors on validation failure
# - Schedules EmailSubscriptionNotifySlackJob with 5 minute delay
# - Schedules EmailSubscriptionFollowupEmailJob with 5 minute delay for eligible form_ids
# - Does NOT schedule followup email for decision_tree_invite_first
# - Does NOT schedule followup email for decision_tree_invite_second
# - Does NOT schedule followup email for decision_tree_filing_required
# - Does NOT schedule followup email for nil form_id
```

**2b. Implement** `app/services/email_subscription/create_service.rb`
```ruby
class EmailSubscription::CreateService < ApplicationService
  description 'Creates an email subscription and schedules notifications'

  # Followup email is sent after signup via marketing forms (Request Demo, Learn More buttons).
  # The email (signup_followup in Customer.io) is sent 5 minutes after signup.
  # To add a new form to the followup flow, add its form_id to this list.
  FOLLOWUP_ELIGIBLE_FORM_IDS = %w[
    home_hero
    home_footer
    identity_hero
    identity_footer
    for_escrow_title_hero
    for_escrow_title_footer
    fincen_footer
    security_footer
    fraud_footer
    for_home_buyers_footer
    for_home_sellers_footer
  ].freeze

  NOTIFICATION_DELAY = 5.minutes

  argument :email, Type::String
  argument :ip_geo, Type::Hash, default: {}.freeze
  argument :origin_url, Type::String, optional: true
  argument :form_id, Type::String, optional: true

  def call
    email_subscription = EmailSubscription.new(email:, ip_geo:, origin_url:, form_id:)

    return Failure(email_subscription.errors) unless email_subscription.save

    schedule_slack_notification(email_subscription)
    schedule_followup_email(email_subscription)

    Success(email_subscription)
  end

  private

  def schedule_slack_notification(email_subscription)
    EmailSubscriptionNotifySlackJob.set(wait: NOTIFICATION_DELAY).perform_later(email_subscription)
  end

  def schedule_followup_email(email_subscription)
    return unless FOLLOWUP_ELIGIBLE_FORM_IDS.include?(email_subscription.form_id)

    EmailSubscriptionFollowupEmailJob.set(wait: NOTIFICATION_DELAY).perform_later(email_subscription)
  end
end
```

### Step 3: Create `EmailSubscription::DeliverFollowupEmailService`

**3a. Write test** `spec/services/email_subscription/deliver_followup_email_service_spec.rb`
```ruby
# Test cases:
# - Sends email via Customer.io with tmsg_id 'signup_followup'
# - Includes firstName in message_data when present
# - Excludes firstName from message_data when nil (uses compact)
# - Returns Success with email object
```

**3b. Implement** `app/services/email_subscription/deliver_followup_email_service.rb`
```ruby
class EmailSubscription::DeliverFollowupEmailService < ApplicationService
  description 'Delivers signup followup email via Customer.io'

  argument :email_subscription, Type::EmailSubscription

  def call
    email = Integrations::Customerio::Email.deliver!(
      owner: email_subscription,
      tmsg_id: 'signup_followup',
      to: email_subscription.email,
      message_data: build_message_data,
      async: true
    )

    Success(email)
  end

  private

  def build_message_data
    { firstName: email_subscription.first_name }.compact
  end
end
```

### Step 4: Create `EmailSubscriptionFollowupEmailJob`

**4a. Write test** `spec/jobs/email_subscription_followup_email_job_spec.rb`
```ruby
# Test cases:
# - Calls DeliverFollowupEmailService with email_subscription
```

**4b. Implement** `app/jobs/email_subscription_followup_email_job.rb`
```ruby
class EmailSubscriptionFollowupEmailJob < ApplicationJob
  queue_as :default

  def perform(email_subscription)
    EmailSubscription::DeliverFollowupEmailService.call(email_subscription:)
  end
end
```

### Step 5: Update Callsites to Use CreateService

**5a. Write test** `spec/controllers/email_subscriptions_controller_spec.rb`
```ruby
# Test cases:
# - create action uses EmailSubscription::CreateService
# - Handles Success result (redirects, etc.)
# - Handles Failure result (renders errors)
```

**5b. Implement** `app/controllers/email_subscriptions_controller.rb`
Replace direct `EmailSubscription.new` + `.save` with service call:
```ruby
def create
  # ... turnstile validation ...

  EmailSubscription::CreateService.call(
    email: params[:email],
    ip_geo: ip_geo || {},
    origin_url: params[:origin_url].presence || request.referer,
    form_id: params[:form_id].presence
  ) do |on|
    on.success do |email_subscription|
      send_decision_tree_invite(email_subscription) if params[:send_decision_tree_invite].present?
      # ... rest of success handling ...
    end
    on.failure do |errors|
      # ... error handling ...
    end
  end
end
```

**5c. Write test** `spec/controllers/decision_tree/filing_requireds_controller_spec.rb`
```ruby
# Test cases:
# - request_demo action uses EmailSubscription::CreateService
# - Sets form_id to 'decision_tree_filing_required'
```

**5d. Implement** `app/controllers/decision_tree/filing_requireds_controller.rb`
Replace `EmailSubscription.create!` with service call:
```ruby
def request_demo
  # ...
  EmailSubscription::CreateService.call(
    email: decision_tree.reload.email_address,
    origin_url: decision_tree_filing_required_url(@decision_tree_presenter),
    form_id: EmailSubscription::FORM_IDS[:decision_tree_filing_required]
  ) do |on|
    on.success do |email_subscription|
      write_email_sub_cookie(email_subscription.id)
      redirect_to edit_email_subscription_path, status: :see_other
    end
    on.failure { render :show, status: :unprocessable_content }
  end
end
```

### Step 6: Remove `after_create` Callback

**6a. Write test** `spec/models/email_subscription_spec.rb`
- Verify no `after_create` callbacks exist for Slack notification

**6b. Implement** `app/models/email_subscription.rb`
- Remove line: `after_create { EmailSubscriptionNotifySlackJob.set(wait: 5.minutes).perform_later(self) }`

## Files to Modify/Create

| Order | Action | File |
|-------|--------|------|
| 1a | Modify | `spec/models/email_subscription_spec.rb` (form_id validation) |
| 1b | Modify | `app/models/email_subscription.rb` (add form_id) |
| 2a | Create | `spec/services/email_subscription/create_service_spec.rb` |
| 2b | Create | `app/services/email_subscription/create_service.rb` |
| 3a | Create | `spec/services/email_subscription/deliver_followup_email_service_spec.rb` |
| 3b | Create | `app/services/email_subscription/deliver_followup_email_service.rb` |
| 4a | Create | `spec/jobs/email_subscription_followup_email_job_spec.rb` |
| 4b | Create | `app/jobs/email_subscription_followup_email_job.rb` |
| 5a | Modify | `spec/controllers/email_subscriptions_controller_spec.rb` |
| 5b | Modify | `app/controllers/email_subscriptions_controller.rb` |
| 5c | Modify | `spec/controllers/decision_tree/filing_requireds_controller_spec.rb` |
| 5d | Modify | `app/controllers/decision_tree/filing_requireds_controller.rb` |
| 6a | Modify | `spec/models/email_subscription_spec.rb` (remove callback test) |
| 6b | Modify | `app/models/email_subscription.rb` (remove callback) |
