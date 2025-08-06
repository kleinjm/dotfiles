# Ruby Style Guide

> Last updated: 2025-08-06

## Context

Ruby and Rails-specific coding standards for Agent OS projects.

## Ruby Language Conventions

### Method Definitions
- Methods that can raise exceptions must end with `!`
- Boolean methods must end with `?`
- Don't create one-line methods that just call other methods
- Use guard clauses instead of nested conditionals

### Class and Module Organization
- Use `::` for namespacing instead of nested module declarations
  ```ruby
  # Good
  class Admin::UsersController < ApplicationController
  
  # Avoid
  module Admin
    class UsersController < ApplicationController
  ```
- Order class contents: constants, concerns, associations, validations, callbacks, scopes, class methods, instance methods
- Group related methods together

### Variable and Method Naming
- Never use single character variables except in blocks (e.g., `|e|` for exceptions)
- Use descriptive names that reveal intent
- Avoid abbreviations unless widely understood in the domain

## Rails Conventions

### ActiveRecord
- Always use `uuid` instead of `id` for queries and routes
- Don't validate boolean fields with presence or inclusion validators
- Use scopes for commonly used queries
- Prefer `find_by` over `where.first`
- Use `find_or_create_by!` for idempotent operations

### Controllers
- Keep controllers thin - business logic belongs in services
- Use strong parameters consistently
- Return early from actions when possible
- Use before_action filters judiciously

### Views and Partials
- Never use instance variables in partials - pass all data via locals
- Keep view logic minimal - use helpers or presenters for complex logic
- Prefer partials over duplicated markup

### Routes
- Use RESTful routes whenever possible
- Group related routes with namespaces
- Use `resources` and `resource` helpers
- Prefer shallow nesting (max 1 level deep)

## Code Organization

### Service Objects
- Inherit from `ApplicationService` base class
- Use monadic results (`Success()` and `Failure()`)
- Include descriptive `description` fields
- Use `argument()` declarations with type checking

### Long Method Arguments
When method calls exceed 80 characters, use parentheses and split arguments:
```ruby
# Good
ServiceName.call(
  user: current_user,
  amount: calculated_amount,
  description: "Payment for order ##{order.number}",
  metadata: { source: 'web' }
)

# Avoid
ServiceName.call(user: current_user, amount: calculated_amount, description: "Payment for order ##{order.number}", metadata: { source: 'web' })
```

### String Interpolation
- Use string interpolation over concatenation
- Use `#{}` syntax, never ERB-style `<%= %>`
- For complex interpolations, consider extracting to methods

## Error Handling

### Exception Raising
- Only rescue specific exceptions, never `StandardError`
- Use `Failure()` for expected failures in services
- Add context to error messages
- Log errors appropriately based on severity

### Validation Errors
- Use Rails validations for data integrity
- Provide clear, user-friendly error messages
- Group related validations together