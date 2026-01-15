# Plan: Add form_id tracking to EmailSubscription

## Overview
Add a `form_id` field to track which specific form on a page was used when creating an EmailSubscription. This enables better analytics by distinguishing between multiple email subscription forms on the same page.

## Form ID Naming Convention
Format: `{page}_{section}` using snake_case

| Form ID | File | Line | Description |
|---------|------|------|-------------|
| `home_hero` | `marketing/home.html.slim` | 23 | Hero section form |
| `home_footer` | `marketing/_subscription_form_footer.html.slim` | (passed as local) | Footer on home page |
| `fincen_decision_tree` | `marketing/fincen.html.slim` | 31 | Decision tree access form |
| `fincen_early_access` | `marketing/fincen.html.slim` | 77 | Early access form |
| `fincen_footer` | `marketing/_subscription_form_footer.html.slim` | (passed as local) | Footer on fincen page |
| `identity_hero` | `marketing/identity.html.slim` | 25 | Hero section form |
| `identity_footer` | `marketing/_subscription_form_footer.html.slim` | (passed as local) | Footer on identity page |
| `for_escrow_title_hero` | `marketing/for_escrow_title.html.slim` | 27 | Mission section form |
| `for_escrow_title_footer` | `marketing/_subscription_form_footer.html.slim` | (passed as local) | Footer on escrow/title page |
| `security_footer` | `marketing/_subscription_form_footer.html.slim` | (passed as local) | Footer on security page |
| `fraud_footer` | `marketing/_subscription_form_footer.html.slim` | (passed as local) | Footer on fraud page |
| `for_home_buyers_footer` | `marketing/_subscription_form_footer.html.slim` | (passed as local) | Footer on home buyers page |
| `for_home_sellers_footer` | `marketing/_subscription_form_footer.html.slim` | (passed as local) | Footer on home sellers page |

## Files to Modify

### 1. Database Migration (DONE)
- `db/migrate/20251216183409_add_form_id_to_email_subscriptions.rb` - Already created and run

### 2. Controller
- `app/controllers/email_subscriptions_controller.rb`
  - Accept `form_id` param in `create` action
  - Add `warn_missing_tracking_fields` private method for Rollbar warning

### 3. Model
- `app/models/email_subscription.rb`
  - Update `deliver_slack_message` to include form_id in Slack notification

### 4. Forms (add hidden `form_id` field)

**Inline forms (add directly):**
- `app/views/marketing/home.html.slim:23` - Add `form_id: 'home_hero'`
- `app/views/marketing/fincen.html.slim:31` - Add `form_id: 'fincen_decision_tree'`
- `app/views/marketing/fincen.html.slim:77` - Add `form_id: 'fincen_early_access'`
- `app/views/marketing/identity.html.slim:25` - Add `form_id: 'identity_hero'`
- `app/views/marketing/for_escrow_title.html.slim:27` - Add `form_id: 'for_escrow_title_hero'`

**Footer partial (pass as local):**
- `app/views/marketing/_subscription_form_footer.html.slim` - Add `form_id` local and hidden field
- Update all render calls to pass `form_id:` local:
  - `marketing/home.html.slim:108` - `form_id: 'home_footer'`
  - `marketing/fincen.html.slim:123` - `form_id: 'fincen_footer'`
  - `marketing/identity.html.slim:89` - `form_id: 'identity_footer'`
  - `marketing/for_escrow_title.html.slim:135` - `form_id: 'for_escrow_title_footer'`
  - `marketing/security.html.slim:60` - `form_id: 'security_footer'`
  - `marketing/fraud.html.slim:68` - `form_id: 'fraud_footer'`
  - `marketing/for_home_buyers.html.slim:107` - `form_id: 'for_home_buyers_footer'`
  - `marketing/for_home_sellers.html.slim:81` - `form_id: 'for_home_sellers_footer'`

## Implementation Steps

### Step 1: Update Controller
Add form_id param handling and Rollbar warning in `email_subscriptions_controller.rb`:

```ruby
def create
  # ... existing code ...
  origin_url = params[:origin_url].presence || request.referer
  form_id = params[:form_id].presence

  email_subscription = EmailSubscription.new(email: params[:email], ip_geo: ip_geo || {}, origin_url:, form_id:)
  if email_subscription.save
    warn_missing_tracking_fields(email_subscription)
    # ... rest of existing code ...
  end
end

private

def warn_missing_tracking_fields(email_subscription)
  missing_fields = []
  missing_fields << 'origin_url' if email_subscription.origin_url.blank?
  missing_fields << 'form_id' if email_subscription.form_id.blank?

  return if missing_fields.empty?

  Rollbar.warning(
    'EmailSubscription created with missing tracking fields',
    missing_fields:,
    email_subscription_id: email_subscription.id,
    referer: request.referer,
    request_path: request.path
  )
end
```

### Step 2: Update Slack Message
In `app/models/email_subscription.rb`, add form_id to `deliver_slack_message`:

```ruby
msg.section(icon: :page_facing_up, text: "Form: #{form_id}") if form_id.present?
```

### Step 3: Update Footer Partial
In `app/views/marketing/_subscription_form_footer.html.slim`:
- Add `form_id: nil` to the locals declaration
- Add `= hidden_field_tag :form_id, form_id` inside the form

### Step 4: Add hidden form_id to inline forms
Add to each inline form:
```slim
= hidden_field_tag :form_id, 'form_id_value'
```

### Step 5: Update all footer render calls
Pass `form_id:` local to each `render 'subscription_form_footer'` call

### Step 6: Add Tests
- Controller spec for form_id being saved
- Controller spec for Rollbar warning when fields are missing
- Model spec for Slack message including form_id

## Testing Plan
1. Run existing controller specs
2. Run existing model specs
3. Manually test each form to verify form_id is captured
