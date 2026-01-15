# Plan: Notify Inviters of Failed Officer Invitations

## Summary
When an officer invitation email fails to deliver, notify the inviter via email and send a Slack notification to #user-alerts. Unlike customer invitations, no activity log update is needed.

## Context
- Customer invitation failures are handled by `Invitation::NotifyDeliveryFailureService` with Slack, email, and activity tracking
- Officer invitations have `kind: 'new-member'` and `invitee_type: Person`
- The `EmailEventsHandler` currently only processes failures for `Customer` invitees
- Inviters can be: officers, admins, or super_admins (EscrowSafe employees)
- The service already has `unlinkable_email` helper for ZWNJ injection

## Implementation

### 1. Update EmailEventsHandler to Process Officer Invitations
**File:** `app/models/integrations/customerio/email_events_handler.rb`

Current code only handles Customer invitees (line 13):
```ruby
if email.owner.is_a?(Invitation) && failure?(event:) && email.owner.invitee.is_a?(Customer)
```

Change to handle both Customer and Person invitees:
```ruby
if email.owner.is_a?(Invitation) && failure?(event:)
  Invitation::NotifyDeliveryFailureService.call(invitation: email.owner, tmsg_id: email.tmsg_id) do |on|
```

### 2. Extend NotifyDeliveryFailureService to Handle Officer Invitations
**File:** `app/services/invitation/notify_delivery_failure_service.rb`

Add new constant for officer email template:
```ruby
UNDELIVERABLE_OFFICER_INVITE_TMSG_ID = 'undeliverable_officer_invite'
```

Modify `call` method to branch based on invitee type:
```ruby
def call
  if invitation.invitee.is_a?(Customer)
    notify_customer_failure
  elsif invitation.invitee.is_a?(Person)
    notify_officer_failure
  else
    return Failure(:unknown_invitee_type)
  end

  Success()
end
```

Rename existing customer logic:
```ruby
def notify_customer_failure
  notify_slack
  send_notification_emails
  track_activity
end
```

Add officer-specific methods:
```ruby
def notify_officer_failure
  notify_slack_officer
  send_officer_notification_email
end

def notify_slack_officer
  Integrations::Slack::ComposeableMessage.new(channel: :user_alerts, async: true) do |msg|
    msg.section(icon: :warning, text: "#{tmsg_id} was not delivered")
    msg.organization_section(organization)
    msg.link_section(text: 'Member Directory', url: member_directory_url)
    msg.section(icon: :eyes, text: 'Please contact the inviter')
  end.post!
end

def send_officer_notification_email
  Integrations::Customerio::Email.deliver!(
    owner: invitation,
    tmsg_id: UNDELIVERABLE_OFFICER_INVITE_TMSG_ID,
    to: inviter.email,
    message_data: {
      inviterFirstName: inviter.first_name,
      officerName: invited_officer.full_name,
      failedEmailAddress: unlinkable_email(invited_officer.email),
      memberDirectoryUrl: member_directory_url
    },
    async: true
  )
end

def invited_officer
  invitation.invitee
end

def organization
  invitation.organization
end

def member_directory_url
  url_helpers.organization_people_url(organization)
end
```

### 3. Update Tests
**File:** `spec/services/invitation/notify_delivery_failure_service_spec.rb`

Add tests for:
- Officer invitation triggers Slack notification to #user-alerts with member directory link
- Officer invitation sends email to inviter with correct payload
- Returns failure for unknown invitee type

**File:** `spec/models/integrations/customerio/email_events_handler_spec.rb`

Update to verify:
- Officer invitation failures trigger the service (remove Customer-only check test)

## Email Template (Customer.io)
Template ID: `undeliverable_officer_invite`

Payload:
- `inviterFirstName` - First name of the person who sent the invitation
- `officerName` - Full name of the officer whose email bounced
- `failedEmailAddress` - The email address that failed (with ZWNJ chars)
- `memberDirectoryUrl` - Link to `/organizations/:slug/people`

## Files to Modify
1. `app/models/integrations/customerio/email_events_handler.rb` - Remove Customer-only check
2. `app/services/invitation/notify_delivery_failure_service.rb` - Add officer handling
3. `spec/services/invitation/notify_delivery_failure_service_spec.rb` - Add officer tests
4. `spec/models/integrations/customerio/email_events_handler_spec.rb` - Update tests

## Verification
1. Run service specs: `bundle exec rspec spec/services/invitation/notify_delivery_failure_service_spec.rb`
2. Run handler specs: `bundle exec rspec spec/models/integrations/customerio/email_events_handler_spec.rb`
3. Manual test: Use Rails console to call service with officer invitation
