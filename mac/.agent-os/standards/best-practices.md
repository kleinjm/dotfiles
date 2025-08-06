# Development Best Practices

> Last updated: 2025-08-06

## Context

Global development guidelines for Agent OS projects.

<conditional-block context-check="core-principles">
IF this Core Principles section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Core Principles already in context"
ELSE:
  READ: The following principles

## Core Principles

### Keep It Simple
- Implement code in the fewest lines possible
- Avoid over-engineering solutions
- Choose straightforward approaches over clever ones

### Optimize for Readability
- Prioritize code clarity over micro-optimizations
- Write self-documenting code with clear variable names
- Add comments for "why" not "what"

### DRY (Don't Repeat Yourself)
- Extract repeated business logic to private methods
- Extract repeated UI markup to reusable components
- Create utility functions for common operations

### File Structure
- Keep files focused on a single responsibility
- Group related functionality together
- Use consistent naming conventions
</conditional-block>

<conditional-block context-check="dependencies" task-condition="choosing-external-library">
IF current task involves choosing an external library:
  IF Dependencies section already read in current context:
    SKIP: Re-reading this section
    NOTE: "Using Dependencies guidelines already in context"
  ELSE:
    READ: The following guidelines
ELSE:
  SKIP: Dependencies section not relevant to current task

## Dependencies

### Choose Libraries Wisely
When adding third-party dependencies:
- Select the most popular and actively maintained option
- Check the library's GitHub repository for:
  - Recent commits (within last 6 months)
  - Active issue resolution
  - Number of stars/downloads
  - Clear documentation
</conditional-block>

<conditional-block context-check="git-practices" task-condition="version-control">
IF current task involves git commits or version control:
  IF Git Practices section already read in current context:
    SKIP: Re-reading this section
    NOTE: "Using Git Practices already in context"
  ELSE:
    READ: The following guidelines
ELSE:
  SKIP: Git Practices section not relevant to current task

## Git Practices

### Commit Guidelines
- **NO AI attribution**: Never include "Generated with Claude Code" or "Co-Authored-By: Claude"
- Create branches with the naming `kleinjm/feature_name`
- Use conventional commit format:
  - `feat:` for new features
  - `fix:` for bug fixes
  - `docs:` for documentation changes
  - `style:` for formatting changes
  - `refactor:` for code restructuring
  - `test:` for adding or updating tests
  - `chore:` for maintenance tasks
- Focus on technical achievements and business impact
- Never commit/push without explicit user permission
- Write clear, concise commit messages explaining the "why"
</conditional-block>

<conditional-block context-check="service-architecture" task-condition="building-services">
IF current task involves creating or modifying services:
  IF Service Architecture section already read in current context:
    SKIP: Re-reading this section
    NOTE: "Using Service Architecture patterns already in context"
  ELSE:
    READ: The following patterns
ELSE:
  SKIP: Service Architecture section not relevant to current task

## Service Architecture

### Service Pattern
- Use service pattern with monadic results for business logic
- All services inherit from `ApplicationService` base class
- Return `Success()` and `Failure()` for all outcomes
- Handle results with `do |on|` blocks for clear control flow

### Service Structure
```ruby
class ServiceName < ApplicationService
  description "Clear description of what this service does"

  argument :required_arg, Type::String, description: "What this argument is for"
  argument :optional_arg, Type::String, optional: true, default: "value".freeze

  def perform
    # Business logic here
    Success(result: data)
  rescue SpecificError => e
    Failure(error: e.message)
  end
end
```

### Service Guidelines
- Use `argument()` declarations with type checking
- Include descriptive `description` fields
- Don't rescue `StandardError` - only specific exceptions
- Use `Failure()` for expected failures only
- Split long argument lists across multiple lines
- Prefer composition over inheritance
</conditional-block>

<conditional-block context-check="debugging-approach" task-condition="debugging-or-troubleshooting">
IF current task involves debugging or troubleshooting:
  IF Debugging Approach section already read in current context:
    SKIP: Re-reading this section
    NOTE: "Using Debugging Approach already in context"
  ELSE:
    READ: The following approach
ELSE:
  SKIP: Debugging section not relevant to current task

## Debugging Approach

### Core Philosophy
- Get 100% certainty on root cause before changing code
- Use puts statements, logs, and output liberally
- Prove assumptions with evidence, don't guess

### Debugging Tools Priority
1. **Rails logs**: Check `log/development.log` and `log/test.log`
2. **Rails runner**: Use for isolated testing instead of console
3. **Output statements**: Add puts/logger statements to trace execution
4. **Browser tools**: For frontend issues, write to HTML elements
5. **Test artifacts**: Use `save_page` and `save_screenshot` in system tests

### Debugging Guidelines
- Never use `binding.pry` or `debugger` statements
- Don't use `rails console` - prefer `rails runner` scripts
- Use try/catch blocks to prove silent failures
- Output intermediate values to understand data flow
- Check database state with direct queries
</conditional-block>

<conditional-block context-check="database-practices" task-condition="database-or-migrations">
IF current task involves database work or migrations:
  IF Database Practices section already read in current context:
    SKIP: Re-reading this section
    NOTE: "Using Database Practices already in context"
  ELSE:
    READ: The following practices
ELSE:
  SKIP: Database section not relevant to current task

## Database Practices

### Migration Guidelines
- Use `rails generate migration` for correct timestamps
- Combine alter queries following Rails best practices
- Always include rollback methods for reversibility
- Add indexes for frequently queried columns
- Use UUID for primary keys on new tables

### Database Design
- Use PostgreSQL as primary database
- Implement soft deletion with `deleted_at` timestamps
- Add audit trail with versioning (e.g., PaperTrail)
- Encrypt sensitive fields (bank accounts, SSNs, PII)
- Use foreign key constraints for referential integrity

### Query Optimization
- Avoid N+1 queries with proper includes/joins
- Use database views for complex read-only queries
- Implement proper database indexes
- Index all foreign keys
</conditional-block>

<conditional-block context-check="seed-development" task-condition="seed-files">
IF current task involves seed files or data seeding:
  IF Seed Development section already read in current context:
    SKIP: Re-reading this section
    NOTE: "Using Seed Development patterns already in context"
  ELSE:
    READ: The following patterns
ELSE:
  SKIP: Seed section not relevant to current task

## Seed Development

### Seed File Requirements
- All seed files must be idempotent (runnable multiple times)
- Use seeder classes inheriting from `BaseSeeder`
- Implement `run_seed` method as entry point
- Use `after` blocks for execution ordering
- Break down into focused private methods

### Seed Implementation
```ruby
class UserSeeder < BaseSeeder
  def run_seed
    create_admin_users
    create_test_users if Rails.env.development?
  end

  private

  def create_admin_users
    User.find_or_create_by!(email: "admin@example.com") do |user|
      user.name = "Admin User"
      # Set other attributes
    end
  end
end
```

### Seed Guidelines
- Prefer using existing services over verbose code
- Use `find_or_create_by!` for idempotency
- Set audit trail whodunnit for tracking
- Enable/disable features as needed
- Document any external dependencies
</conditional-block>
