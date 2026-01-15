# Plan: Add Email Unsuppress Form to Admin Emails Page

## Summary

Add a form at the top of `/admin/emails` that allows super admins and sudoers to unsuppress a Customer.io profile by email address. The form will call `Integrations::Customerio.unsuppress(email)` when submitted.

## Implementation (TDD Approach)

### Step 1: Write Request Spec

**File:** `spec/requests/admin/emails_spec.rb` (new file)

Write specs covering:
1. `POST /admin/emails/unsuppress` requires authentication
2. Denies access to regular ES employees (non-super-admin)
3. Allows super admins to submit form and calls `Integrations::Customerio.unsuppress`
4. Displays success flash message on successful unsuppress
5. Displays error flash message when `Customerio::InvalidResponse` is raised
6. Displays error flash message when `Customerio::Client::ParamError` is raised
7. Validates email (rejects blank)
8. `GET /admin/emails` shows unsuppress form for super admins
9. `GET /admin/emails` hides unsuppress form for regular ES employees

### Step 2: Add Route

**File:** `config/routes/admin.rb` (line 34)

Change:
```ruby
resources :emails, only: %i[index show]
```
To:
```ruby
resources :emails, only: %i[index show] do
  post :unsuppress, on: :collection
end
```

Using `collection` because unsuppress operates on an email address, not an existing email record.

### Step 3: Add Policy Method

**File:** `app/policies/admin/integrations/customerio/email_policy.rb`

Add method:
```ruby
def unsuppress?
  super_admin?
end
```

Note: `super_admin?` is inherited from `Admin::BasePolicy` and includes sudoers (see `es_employee?` logic in `Admin::BasePolicy` line 65: `sudoer? || super_admin? || user&.es_employee?`).

### Step 4: Add Controller Action

**File:** `app/controllers/admin/emails_controller.rb`

Add `unsuppress` action:
```ruby
def unsuppress
  authorize Integrations::Customerio::Email

  email = params[:email].to_s.strip
  if email.blank?
    redirect_to admin_emails_path, alert: 'Email address is required'
    return
  end

  Integrations::Customerio.unsuppress(email)
  redirect_to admin_emails_path, notice: "Unsuppressed #{email} in Customer.io", status: :see_other
rescue Customerio::InvalidResponse, Customerio::Client::ParamError => e
  redirect_to admin_emails_path, alert: "Failed to unsuppress: #{e.message}", status: :see_other
end
```

### Step 5: Add Form to View (Conditional)

**File:** `app/views/admin/emails/index.html.slim`

Add at the top (after breadcrumb, before table), wrapped in a policy check:
```slim
- if policy(Integrations::Customerio::Email).unsuppress?
  .card.mb-4
    .card-header
      | Unsuppress Email
    .card-body
      p.text-muted.small
        | Unsuppress a Customer.io profile to allow emails to be sent to a previously suppressed address.
      = form_tag unsuppress_admin_emails_path, method: :post, class: 'd-flex gap-2' do
        = text_field_tag :email, nil, class: 'form-control', placeholder: 'customer@example.com', required: true, type: 'email', style: 'max-width: 350px'
        = submit_tag 'Unsuppress', class: 'btn btn-primary', data: { turbo_submits_with: 'Unsuppressing...' }
```

The form is only visible to users who pass the `unsuppress?` policy check (super admins and sudoers).

## Files to Modify

| File | Change |
|------|--------|
| `spec/requests/admin/emails_spec.rb` | Create new spec file |
| `config/routes/admin.rb` | Add `post :unsuppress` collection route |
| `app/policies/admin/integrations/customerio/email_policy.rb` | Add `unsuppress?` method |
| `app/controllers/admin/emails_controller.rb` | Add `unsuppress` action |
| `app/views/admin/emails/index.html.slim` | Add unsuppress form at top |

## Verification

1. Run the request spec: `bundle exec rspec spec/requests/admin/emails_spec.rb`
2. Start dev server: `bin/dev`
3. Navigate to `/admin/emails` as a super admin - verify form is visible
4. Navigate to `/admin/emails` as a regular ES employee - verify form is hidden
5. Submit a test email address as super admin and verify success flash message
