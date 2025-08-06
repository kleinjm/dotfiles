# Testing Style Guide

> Last updated: 2025-08-06

## Context

Testing conventions and patterns for Agent OS projects across all testing frameworks.

## RSpec Testing (Ruby)

### Core Principles
- **No let/let!**: Don't use `let` or `let!` - favor explicit setup methods
- Use fastest strategies: prefer `build_stubbed`, then `build`, then `create`
- Only test happy paths in system specs unless explicitly requested

### Describe Blocks
```ruby
# Instance methods
describe '#method_name' do
  # tests
end

# Class methods
describe '.method_name' do
  # tests
end
```

### Test Structure
```ruby
RSpec.describe UserService do
  describe '#perform' do
    subject(:service) { described_class.new(user: user) }
    
    context 'when user is valid' do
      let(:user) { build_stubbed(:user) }
      
      it 'returns success' do
        result = service.perform
        expect(result).to be_success
      end
    end
    
    context 'when user is invalid' do
      let(:user) { build_stubbed(:user, email: nil) }
      
      it 'returns failure' do
        result = service.perform
        expect(result).to be_failure
      end
    end
  end
end
```

### Authentication in Tests
- Request specs: `sign_in_as(user)`
- System specs: `sign_in_customer(customer)`

### Feature Flags
Use existing features instead of creating new ones:
```ruby
# Good
feature = Feature.find_by(name: Feature::LIST[:feature_name])

# Avoid
feature = create(:feature, name: 'test_feature')
```

### Doubles and Mocks
- Always use `instance_double` instead of `double`
- Verify method signatures exist
```ruby
# Good
service = instance_double(UserService, perform: Success())

# Avoid
service = double('UserService', perform: Success())
```

### Capybara Conventions
- Use `visible: :visible` instead of `visible: true`
- Use `save_page` and `save_screenshot` for debugging
- Prefer data attributes for element selection

## Factory Conventions

### Factory Guidelines
- Only define database NOT NULL fields
- Don't define uuid fields - handled automatically
- Never use `customer` factory - use `buyer` or `seller`
- Share associated objects to minimize database records
- Don't create traits unless explicitly requested

### Factory Example
```ruby
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    # Don't include: uuid, created_at, updated_at, optional fields
  end
end
```

### After Creating Factories
Always run annotation after creating factories:
```bash
bundle exec annotate --models
```

## JavaScript Testing (Vitest)

### Test Structure
```javascript
import { describe, it, expect, beforeEach } from 'vitest'
import UserController from '@/controllers/user_controller'

describe('UserController', () => {
  let controller
  
  beforeEach(() => {
    document.body.innerHTML = `
      <div data-controller="user">
        <input data-user-target="email" />
      </div>
    `
    controller = new UserController()
  })
  
  describe('#validateEmail', () => {
    it('returns true for valid email', () => {
      controller.emailTarget.value = 'user@example.com'
      expect(controller.validateEmail()).toBe(true)
    })
  })
})
```

### Coverage Configuration
```javascript
// vitest.config.js
export default {
  test: {
    coverage: {
      thresholds: {
        branches: 70,
        functions: 70,
        lines: 70,
        statements: 70
      }
    }
  }
}
```

### DOM Testing
- Use Happy DOM for browser simulation
- Test user interactions, not implementation details
- Mock external dependencies

## General Testing Best Practices

### Test Naming
- Use descriptive test names that explain the scenario
- Start with action verbs: "returns", "raises", "updates", "creates"
- Include context: "when user is authenticated", "with invalid data"

### Test Organization
```
spec/
├── models/          # Model specs
├── services/        # Service object specs
├── requests/        # API/controller specs
├── system/          # End-to-end specs
├── support/         # Shared examples, helpers
└── factories/       # Factory definitions
```

### Test Data
- Use factories for complex objects
- Use simple Ruby objects for value objects
- Keep test data minimal and focused

### Assertions
- One logical assertion per test
- Test behavior, not implementation
- Verify outcomes, not internal state

### Performance
- Run fastest tests first (unit before integration)
- Use transactional fixtures where possible
- Avoid unnecessary database hits

### Debugging Failed Tests
1. Check test output and error messages
2. Review screenshots for system tests
3. Examine `log/test.log` for details
4. Add output statements to trace execution
5. Verify test data setup