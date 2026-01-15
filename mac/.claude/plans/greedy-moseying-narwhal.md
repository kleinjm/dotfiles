# Plan: Add Context to Customer.io Email Error Messages

## Problem

The current error at line 99 of `app/models/integrations/customerio/email.rb`:

```ruby
raise "Failed to send: #{err}" if err
```

Produces an unhelpful error message like:
```
RuntimeError Failed to send: "transactional_message_id" not found.
```

This doesn't tell us which email failed or what template was being used.

## Technical Note: `raise` and Hashes

Ruby's `raise` does not accept a hash directly. Options:
1. **String formatting** - `raise "msg: #{hash.to_s}"` or interpolation
2. **Custom error class** - cleaner, allows `rescue DeliveryError` and access to attributes

We'll use a custom error class for better error handling.

## Files to Modify

1. `spec/models/integrations/customerio/email_spec.rb` - Add tests first (TDD)
2. `app/models/integrations/customerio/email.rb` - Add custom error class and update error handling

## Implementation Steps

### Step 1: Write failing tests (TDD - Red phase)

Following testing.md: no `let`, no `before` blocks, inline setup in `it` blocks.

**Note**: No PII (email addresses, etc.) in error messages - only safe identifiers.

```ruby
describe '#deliver!' do
  describe 'error handling' do
    def stub_customerio_failure
      allow(Integrations::Customerio).to receive(:enabled_email?).and_return(true)
      allow(Integrations::Customerio).to receive(:build_api_client).and_raise(
        StandardError.new('"transactional_message_id" not found.')
      )
    end

    it 'raises DeliveryError with tmsg_id, owner info, uuid, and original error (no PII)' do
      stub_customerio_failure
      email = build(:customerio_email, tmsg_id: 'invalid_template_id')

      expect { email.deliver! }.to raise_error(described_class::DeliveryError) do |error|
        expect(error.message).to include('tmsg_id: invalid_template_id')
        expect(error.message).to include('owner_type:')
        expect(error.message).to include('owner_id:')
        expect(error.message).to include('uuid:')
        expect(error.message).to include('"transactional_message_id" not found.')
        # Ensure no PII in error message
        expect(error.message).not_to include('@')  # No email addresses
      end
    end
  end
end
```

### Step 2: Run tests to see them fail (TDD - Red phase)

```bash
bundle exec rspec spec/models/integrations/customerio/email_spec.rb -e "error handling"
```

### Step 3: Create custom error class and update error handling (Green phase)

Add custom error class at the top of the model (after class declaration):

```ruby
class DeliveryError < StandardError
  attr_reader :email, :original_error

  def initialize(email:, original_error:)
    @email = email
    @original_error = original_error
    super(build_message)
  end

  private

  def build_message
    # Note: No PII (email addresses, etc.) - only safe identifiers
    parts = ["Failed to send email"]
    parts << "tmsg_id: #{email.tmsg_id}"
    parts << "owner_type: #{email.owner_type}"
    parts << "owner_id: #{email.owner_id}"
    parts << "uuid: #{email.uuid}"
    parts << "error: #{original_error}"
    parts.join(', ')
  end
end
```

Update line 99:

```ruby
raise DeliveryError.new(email: self, original_error: err) if err
```

### Step 4: Run tests and verify (TDD - Green phase)

```bash
bundle exec rspec spec/models/integrations/customerio/email_spec.rb
```

## Attributes to Include in Error

| Attribute | Purpose |
|-----------|---------|
| `tmsg_id` | Template ID - helps identify which template is missing |
| `owner_type` | Owner class - provides context about where email originated |
| `owner_id` | Owner ID - allows looking up the specific record |
| `uuid` | Email UUID - unique identifier for this email attempt |

**Excluded (PII)**: `to`, `identifiers`, `message_data`

## Expected Error Message Format

```
Failed to send email, tmsg_id: welcome_buyer, owner_type: Customer, owner_id: 123, uuid: abc-123, error: "transactional_message_id" not found.
```
