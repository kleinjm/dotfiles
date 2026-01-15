# Fix Flaky Test: Terms Agreement Modal - Subsequent Logins

## Problem Analysis

The test `does not show modal on subsequent logins for any buyer` at `spec/system/terms_agreement_modal_spec.rb:477` fails intermittently because of a race condition in the logout/login loop.

**Root Cause:**
- Line 504: `click_link 'Logout'` returns immediately without waiting for logout to complete
- Line 491 (next iteration): `authenticate_customer(buyer)` is called
- Line 48 in `authenticate_customer`: `visit auth_login_path`
- If the session is still active, visiting the login path redirects to `/customers` (customer selection page)
- Line 51: `expect(page).to have_field('login[email]', wait: 10)` fails because the user is on `/customers`, not the login page

**Evidence:**
- CI screenshot shows user at `/customers` screen
- Error: `expected to find field "login[email]"` - login form not visible

## Solution

Add a wait after clicking logout to ensure the logout completes and the user lands on the login page before proceeding.

**File to modify:** `spec/system/terms_agreement_modal_spec.rb`

**Change location:** Line 504

**Before:**
```ruby
click_link 'Logout' unless index == buyers.length - 1
```

**After:**
```ruby
if index != buyers.length - 1
  click_link 'Logout'
  expect(page).to have_current_path(auth_login_path, wait: 10)
end
```

This ensures:
1. Logout link is clicked
2. Test waits for redirect to login page to complete (up to 10 seconds)
3. Only then does the next iteration start

## Verification

Run the specific test multiple times to verify it no longer flakes:
```bash
bundle exec rspec spec/system/terms_agreement_modal_spec.rb:477 --seed 12345
bundle exec rspec spec/system/terms_agreement_modal_spec.rb:477 --seed 67890
bundle exec rspec spec/system/terms_agreement_modal_spec.rb:477 --seed 11111
```

Run the full test file to ensure no regressions:
```bash
bundle exec rspec spec/system/terms_agreement_modal_spec.rb
```
