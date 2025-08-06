# JavaScript Style Guide

> Last updated: 2025-08-06

## Context

JavaScript and TypeScript-specific coding standards for Agent OS projects.

## TypeScript First

### Core Principle
- All JavaScript is written in TypeScript
- `.ts` files are the source of truth
- TypeScript compilation happens automatically in development, testing, and production
- Never edit compiled `.js` files directly

## Language Conventions

### ES6+ Features
- Use modern JavaScript features (const/let, arrow functions, destructuring)
- Prefer `const` over `let`, never use `var`
- Use template literals for string interpolation
- Use async/await over promises when possible

### Private Methods
- Use `#` prefix for private methods in ES6+ classes
```javascript
class UserService {
  #validateEmail(email) {
    // Private method
  }
  
  public createUser(email) {
    if (!this.#validateEmail(email)) {
      throw new Error('Invalid email');
    }
  }
}
```

### Module System
- Use ES6 modules with importmaps
- Import specific functions/classes, avoid namespace imports
- Organize imports: external deps, internal deps, types

## Stimulus Controllers

### File Structure
- Include data-controller comment at top of file
```javascript
// data-controller="user-form"
import { Controller } from '@hotwired/stimulus'
```

### Event Handling
- Use `data-action` attributes instead of `addEventListener`
- Never use inline JavaScript in views
- All interactive behavior must be in Stimulus controllers

### Naming Conventions
- Controller files: `kebab-case` matching data-controller attribute
- Controller classes: `PascalCase` with "Controller" suffix
- Targets and values: `camelCase`

### Controller Example
```javascript
// data-controller="payment-form"
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['amount', 'submit']
  static values = { processingFee: Number }
  
  connect() {
    this.#updateTotal()
  }
  
  updateAmount() {
    this.#updateTotal()
  }
  
  #updateTotal() {
    const amount = parseFloat(this.amountTarget.value)
    const total = amount + this.processingFeeValue
    // Update display
  }
}
```

## Testing

### Framework
- Use Vitest for JavaScript/TypeScript testing
- Happy DOM for browser simulation
- Test files in `test/controllers/` with `.test.js` extension

### Import Alias
- `@` points to `/app/javascript`
```javascript
import UserController from '@/controllers/user_controller'
```

### Coverage Requirements
- Minimum 70% coverage for:
  - Branches
  - Functions
  - Lines
  - Statements

## Code Organization

### File Naming
- Controllers: `kebab-case` (e.g., `user-form-controller.ts`)
- Utilities: `camelCase` (e.g., `formatCurrency.ts`)
- Types: `PascalCase` (e.g., `UserProfile.ts`)

### Directory Structure
```
app/javascript/
├── controllers/       # Stimulus controllers
├── utilities/        # Shared utilities
├── types/           # TypeScript type definitions
└── config/          # Configuration files
```

## Best Practices

### DOM Manipulation
- Always use Stimulus targets instead of querySelector
- Avoid direct DOM manipulation outside of Stimulus controllers
- Use Turbo for page updates when possible

### Error Handling
- Use try/catch blocks for async operations
- Provide user-friendly error messages
- Log errors to console in development

### Performance
- Lazy load controllers when appropriate
- Debounce expensive operations
- Use `requestAnimationFrame` for animations

### Debugging
- Write to HTML elements instead of using debugger
- Use console.log liberally during development
- Remove or comment out debugging code before committing
