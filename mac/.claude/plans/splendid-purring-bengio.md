# Plan: Add Slack Notification for Decision Tree Certificate Email

## Summary

Add a Slack notification to the `#email_sign_ups` channel when a user sends themselves a decision tree certificate link from the confirmation page. **No EmailSubscription record is created** - just the Slack notification.

## Requirements (from issue #2236)

The Slack message format should be:
```
🌳 Decision tree link sent
📧 steph@escrowsafe.com
🕓 Dec 9, 10:08:57 AM
🔗 https://escrowsafe.com/fincen/decision_trees/:id/confirmation
```

Key differences from email subscription notification:
- First line: Just "Decision tree link sent" (no timestamp or URL)
- Last line: Link to decision tree confirmation page
- No full name line (users don't provide name in this flow)

## Implementation

### 1. Add private method for Slack notification

**File:** `app/controllers/decision_tree/confirmations_controller.rb`

Add a private method to send the Slack notification using `Integrations::Slack::ComposeableMessage`.

### 2. Call notification on success

In the `send_email` action's `on.success` block, call the new notification method.

## Files to Modify

1. `app/controllers/decision_tree/confirmations_controller.rb` - Add notification method and call it
2. `spec/requests/decision_tree/confirmations_spec.rb` or similar - Test the notification is sent

## Implementation Details

```ruby
# In confirmations_controller.rb

def send_email
  # ... existing code ...

  ::DecisionTree::SendCertificateEmailService.call(decision_tree:) do |on|
    on.success do
      notify_slack_decision_tree_link_sent(decision_tree)
      redirect_to decision_tree_confirmation_path(@decision_tree_presenter),
                  notice: t('decision_tree.confirmation.email_sent')
    end
    # ... failure handling ...
  end
end

private

def notify_slack_decision_tree_link_sent(decision_tree)
  Integrations::Slack::ComposeableMessage.new(channel: :email_sign_ups) do |msg|
    msg.section(icon: :deciduous_tree, text: '*Decision tree link sent*')
    msg.section(icon: :email, text: decision_tree.email_address)
    msg.log_date_section(Time.current)
    msg.section(icon: :link, text: decision_tree_confirmation_url(decision_tree))
  end.post!
end
```
