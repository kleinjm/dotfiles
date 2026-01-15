# Plan: Send Decision Tree Invite Email from FinCEN Marketing Forms

## Goal
Modify the first two forms on `/workspaces/web/app/views/marketing/fincen.html.slim` to:
1. Continue creating email subscriptions (current behavior)
2. Also send a decision tree invite email via Customer.io

## Context
- **Forms to modify**: Lines 31-40 (`fincen-decision-tree-form`) and lines 77-86 (`fincen-early-access-form`)
- **Third form** (line 123): `subscription_form_footer` partial - unchanged
- **Email template**: `decision_tree_invite` (new Customer.io template)
- **Invite URL**: `/fincen/decision_trees/new?email=<user_email>`
- **Owner for email**: `EmailSubscription` model (already has `has_many :emails` association)

## Implementation

### Step 1: Add hidden field to forms
**File**: `app/views/marketing/fincen.html.slim`

Add `hidden_field_tag :send_decision_tree_invite, true` to both forms (lines ~37 and ~83).

### Step 2: Create SendInviteEmailService
**New file**: `app/services/decision_tree/send_invite_email_service.rb`

```ruby
class DecisionTree::SendInviteEmailService < ApplicationService
  description 'Sends decision tree invite email to an email subscription'

  argument :email_subscription, Type::Instance(EmailSubscription)

  def call
    email = Integrations::Customerio::Email.deliver!(
      owner: email_subscription,
      tmsg_id: 'decision_tree_invite',
      to: email_subscription.email,
      message_data: { decisionTreeUrl: decision_tree_url },
      async: true
    )
    Success(email)
  end

  private

  def decision_tree_url
    url_helpers.new_decision_tree_url(email: email_subscription.email)
  end
end
```

### Step 3: Update EmailSubscriptionsController
**File**: `app/controllers/email_subscriptions_controller.rb`

In the `create` action, after saving the subscription, check `params[:send_decision_tree_invite]` and call the service:

```ruby
if email_subscription.save
  send_decision_tree_invite(email_subscription) if params[:send_decision_tree_invite].present?
  # ... existing redirect logic
end

private

def send_decision_tree_invite(email_subscription)
  DecisionTree::SendInviteEmailService.call(email_subscription:)
end
```

### Step 4: Add template to seeds
**File**: `db/seeds/development/customerio_templates.seeds.rb`

Add entry for `decision_tree_invite` template.

## Files to Modify
1. `app/views/marketing/fincen.html.slim` - Add hidden field
2. `app/controllers/email_subscriptions_controller.rb` - Trigger invite email
3. `app/services/decision_tree/send_invite_email_service.rb` (new)
4. `db/seeds/development/customerio_templates.seeds.rb` - Add template

## Testing
- Add spec for `DecisionTree::SendInviteEmailService`
