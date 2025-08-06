# Code Style Guide

> Last updated: 2025-08-06

## Context

Global code style rules for Agent OS projects.

<conditional-block context-check="general-formatting">
IF this General Formatting section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using General Formatting rules already in context"
ELSE:
  READ: The following formatting rules

## General Formatting

### Indentation
- Use 2 spaces for indentation (never tabs)
- Maintain consistent indentation throughout files
- Align nested structures for readability

### Line Length
- Maximum 120 characters per line for Ruby (including comments)
- Maximum 100 characters per line for JavaScript/TypeScript
- Split long lines at logical break points

### Naming Conventions for Ruby
- **Methods and Variables**: Use snake_case (e.g., `user_profile`, `calculate_total`)
- **Classes and Modules**: Use PascalCase (e.g., `UserProfile`, `PaymentProcessor`)
- **Constants**: Use UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)
- **Boolean Methods**: End with `?` (e.g., `valid?`, `can_edit?`)
- **Dangerous Methods**: End with `!` if they can raise exceptions

### Naming Conventions for JavaScript/TypeScript
- **Methods and Variables**: Use camelCase (e.g., `userProfile`, `calculateTotal`)
- **Classes and Components**: Use PascalCase (e.g., `UserProfile`, `PaymentProcessor`)
- **Constants**: Use UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)
- **Private Methods**: Prefix with `#` in ES6+ classes

### String Formatting for Ruby
- Use double quotes for strings: `"Hello World"`
- Use string interpolation over concatenation: `"Hello #{name}"`

### String Formatting for TypeScript
- Use single quotes for strings: `'Hello World'`
- Use template literals for interpolation: `` `Hello ${name}` ``

### Variable Naming
- Use descriptive names - never single characters except in loops
- Avoid abbreviations unless widely understood
- Name boolean variables as questions: `isValid`, `hasAccess`, `can_edit?`

### Code Comments
- Add brief comments above non-obvious business logic
- Document complex algorithms or calculations
- Explain the "why" behind non-obvious implementation choices
- Never remove existing comments unless removing the associated code
- Update comments when modifying code to maintain accuracy
- Keep comments concise and relevant
</conditional-block>

<conditional-block task-condition="ruby" context-check="ruby-style">
IF current task involves writing or updating Ruby:
  IF ruby-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using Ruby style guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get Ruby style rules from code-style/ruby-style.md"
        PROCESS: Returned style rules
      ELSE:
        READ: @~/.agent-os/standards/code-style/ruby-style.md
    </context_fetcher_strategy>
ELSE:
  SKIP: Ruby style guide not relevant to current task
</conditional-block>

<conditional-block task-condition="javascript" context-check="javascript-style">
IF current task involves writing or updating JavaScript:
  IF javascript-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using JavaScript style guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get JavaScript style rules from code-style/javascript-style.md"
        PROCESS: Returned style rules
      ELSE:
        READ: @~/.agent-os/standards/code-style/javascript-style.md
    </context_fetcher_strategy>
ELSE:
  SKIP: JavaScript style guide not relevant to current task
</conditional-block>

<conditional-block task-condition="slim-templates" context-check="slim-style">
IF current task involves writing or updating Slim templates:
  IF slim-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using Slim style guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get Slim template style rules from code-style/slim-style.md"
        PROCESS: Returned style rules
      ELSE:
        READ: @~/.agent-os/standards/code-style/slim-style.md
    </context_fetcher_strategy>
ELSE:
  SKIP: Slim style guide not relevant to current task
</conditional-block>

<conditional-block task-condition="testing" context-check="testing-style">
IF current task involves writing or updating tests:
  IF testing-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using testing style guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get testing style rules from code-style/testing-style.md"
        PROCESS: Returned style rules
      ELSE:
        READ: @~/.agent-os/standards/code-style/testing-style.md
    </context_fetcher_strategy>
ELSE:
  SKIP: Testing style guide not relevant to current task
</conditional-block>
