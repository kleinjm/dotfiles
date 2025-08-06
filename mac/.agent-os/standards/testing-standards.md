# Testing Standards

> Last updated: 2025-08-06

## Context

Comprehensive testing standards and requirements for Agent OS projects.

## Testing Philosophy

### Core Principles
- Test behavior, not implementation
- Write tests first (TDD) when practical
- Maintain high code coverage (minimum 70%)
- Keep tests fast and focused
- Tests should be readable as documentation

## Test Types and When to Use

### Unit Tests
**Purpose**: Test individual methods and classes in isolation
**When to use**: Always - for all business logic, models, services
**Location**: `spec/models/`, `spec/services/`, `test/javascript/`
**Speed**: Must be fast (<100ms per test)

### Integration Tests
**Purpose**: Test interaction between components
**When to use**: For API endpoints, controller actions, service compositions
**Location**: `spec/requests/`, `spec/controllers/`
**Speed**: Should be reasonably fast (<500ms per test)

### System Tests
**Purpose**: Test complete user workflows
**When to use**: Critical user paths only (login, checkout, core features)
**Location**: `spec/system/`
**Speed**: Can be slower (1-5s per test acceptable)

### Performance Tests
**Purpose**: Ensure performance requirements are met
**When to use**: For critical paths and data-heavy operations
**Location**: `spec/performance/`
**Speed**: Variable based on test nature

## Coverage Requirements

### Minimum Coverage Thresholds
- **Overall**: 80%
- **Models**: 95%
- **Services**: 90%
- **Controllers**: 70%
- **JavaScript**: 70%
- **Critical paths**: 100%

### Coverage Tools
```bash
# Ruby coverage with SimpleCov
COVERAGE=true bundle exec rspec

# JavaScript coverage with Vitest
yarn test --coverage

# View coverage reports
open coverage/index.html
```

## Test Naming Conventions

### RSpec Examples
```ruby
# Good test names
it "returns success when user is valid"
it "raises ArgumentError when email is missing"
it "sends notification email after successful payment"

# Bad test names
it "works"
it "test user creation"
it "should be valid"
```

### JavaScript/Vitest Examples
```javascript
// Good test names
it('validates email format before submission')
it('displays error message when API call fails')
it('updates total when quantity changes')

// Bad test names
it('test 1')
it('works correctly')
it('should validate')
```

## Test Data Management

### Factories vs Fixtures
- **Use Factories**: For dynamic test data
- **Use Fixtures**: For static reference data
- **Use Seeds**: Never in tests - only for development

### Database Cleaner Strategy
```ruby
# spec/support/database_cleaner.rb
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
```

## Continuous Integration

### CI Requirements
- All tests must pass before merge
- Coverage must meet minimum thresholds
- No skipped or pending tests in CI
- Linting must pass

### Test Execution Order
```yaml
# .github/workflows/test.yml
test:
  steps:
    - Linting and formatting
    - Unit tests
    - Integration tests
    - System tests
    - Coverage report
```

## Testing Anti-patterns to Avoid

### Don't Test Framework Code
```ruby
# Bad - testing Rails validations
it "validates presence of email" do
  user = User.new(email: nil)
  expect(user).not_to be_valid
end

# Good - test business logic
it "requires corporate email for admin users" do
  user = User.new(email: "personal@gmail.com", role: "admin")
  expect(user.corporate_email_required?).to be true
end
```

### Don't Use Random Data
```ruby
# Bad - non-deterministic
it "processes payment" do
  amount = rand(100..1000)
  expect(payment.process(amount)).to be_success
end

# Good - deterministic
it "processes payment" do
  amount = 500
  expect(payment.process(amount)).to be_success
end
```

### Don't Test Private Methods
```ruby
# Bad - testing implementation
it "calculates tax correctly" do
  expect(service.send(:calculate_tax, 100)).to eq(10)
end

# Good - test public interface
it "includes tax in total amount" do
  result = service.process(amount: 100)
  expect(result.total).to eq(110)
end
```

## Test Optimization

### Speed Improvements
1. Use `build_stubbed` over `create` when possible
2. Avoid unnecessary database hits
3. Use shared examples for common behaviors
4. Parallelize test execution
5. Profile slow tests regularly

### Parallel Testing
```bash
# Run tests in parallel
bundle exec parallel_rspec spec/

# JavaScript tests in parallel
yarn test --parallel
```

## Debugging Test Failures

### Debug Workflow
1. **Read the error message carefully**
2. **Check test logs**: `tail -f log/test.log`
3. **Add debug output**: `puts`, `p`, `console.log`
4. **Use screenshots**: `save_screenshot` (system tests)
5. **Isolate the test**: Run single test in isolation
6. **Check test data**: Verify factories and setup
7. **Review recent changes**: `git diff`

### Common Issues
- **Flaky tests**: Add proper waits, avoid time-dependent logic
- **Order dependencies**: Ensure test isolation
- **Database state**: Check for leftover data
- **External services**: Properly stub external calls

## Test Documentation

### Writing Self-Documenting Tests
```ruby
RSpec.describe PaymentProcessor do
  describe "#process" do
    context "with valid credit card" do
      it "charges the card and returns success" do
        # Arrange
        card = build_stubbed(:credit_card, valid: true)
        processor = described_class.new(card)
        
        # Act
        result = processor.process(amount: 100)
        
        # Assert
        expect(result).to be_success
        expect(result.transaction_id).to be_present
      end
    end
  end
end
```

### Test Comments
- Add comments for complex setup
- Explain non-obvious assertions
- Document workarounds with ticket references
- Link to requirements or user stories