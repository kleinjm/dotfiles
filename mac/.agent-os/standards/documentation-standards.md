# Documentation Standards

> Last updated: 2025-08-06

## Context

Documentation requirements and standards for Agent OS projects.

## Documentation Types

### Code Documentation

#### Inline Comments
- Add brief comments above non-obvious business logic
- Document complex algorithms or calculations
- Explain the "why" behind non-obvious implementation choices
- Never remove existing comments unless removing associated code
- Update comments when modifying code to maintain accuracy
- Keep comments concise and relevant

#### Self-Documenting Code
- Use descriptive variable and method names instead of comments
- Write code that clearly expresses intent
- Prefer clear code structure over explanatory comments

#### Method Documentation
```ruby
# Ruby example
# Calculates the compound interest for a given principal amount
# @param principal [Float] the initial amount
# @param rate [Float] annual interest rate as decimal (0.05 for 5%)
# @param time [Integer] time period in years
# @return [Float] the final amount after compound interest
def calculate_compound_interest(principal, rate, time)
  principal * (1 + rate) ** time
end
```

```javascript
// JavaScript/TypeScript example
/**
 * Validates and formats a phone number
 * @param {string} phone - The phone number to validate
 * @returns {string|null} Formatted phone number or null if invalid
 */
function formatPhoneNumber(phone: string): string | null {
  // Implementation
}
```

### API Documentation

#### Endpoint Documentation
- Use Swagger/OpenAPI for REST APIs
- Document all parameters, responses, and error codes
- Include example requests and responses
- Specify authentication requirements

#### API Doc Example
```yaml
/api/v1/users/{id}:
  get:
    summary: Get user by ID
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: string
          format: uuid
    responses:
      200:
        description: User found
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/User'
      404:
        description: User not found
```

### README Documentation

#### Required Sections
1. **Project Title and Description**
2. **Prerequisites and System Requirements**
3. **Installation Instructions**
4. **Configuration**
5. **Usage Examples**
6. **Testing Instructions**
7. **Deployment Guide**
8. **Contributing Guidelines**
9. **License Information**

#### README Template
```markdown
# Project Name

Brief description of what this project does and who it's for.

## Prerequisites

- Ruby 3.2+
- PostgreSQL 17+
- Node.js 22 LTS
- Yarn package manager

## Installation

\```bash
git clone [repository-url]
cd [project-name]
bundle install
yarn install
rails db:setup
\```

## Development

\```bash
bin/dev
\```

## Testing

\```bash
bundle exec rspec
yarn test
\```

## Deployment

[Deployment instructions]

## Contributing

[How to contribute]

## License

[License information]
```

### Architecture Documentation

#### System Architecture
- Document core business models
- Explain authentication and authorization system
- Describe key integrations
- Include data flow diagrams where helpful

#### Directory Structure
```
project/
├── app/           # Application code
│   ├── controllers/   # Request handlers
│   ├── models/        # Business logic
│   ├── services/      # Service objects
│   └── views/         # Templates
├── config/        # Configuration files
├── db/            # Database files
├── spec/          # Test files
└── docs/          # Documentation
```

### Development Documentation

#### Command Reference
Document commonly used commands:
```bash
# Database
rails db:create       # Create database
rails db:migrate      # Run migrations
rails db:seed         # Seed database

# Testing
bundle exec rspec     # Run all tests
yarn test            # Run JS tests

# Linting
bundle exec rubocop   # Ruby linting
yarn lint            # JS linting

# Development
bin/dev              # Start dev server
rails console        # Open Rails console
```

#### Environment Variables
```bash
# .env.example
DATABASE_URL=postgresql://user:pass@localhost/db
REDIS_URL=redis://localhost:6379
SECRET_KEY_BASE=your-secret-key
```

## Documentation Best Practices

### Writing Style
- Use clear, concise language
- Write in present tense
- Use active voice
- Avoid jargon unless necessary
- Define acronyms on first use

### Code Examples
- Provide working examples
- Include both simple and complex cases
- Show expected output
- Highlight important parts

### Versioning
- Keep documentation in sync with code
- Version API documentation
- Document breaking changes
- Maintain changelog

### Accessibility
- Use proper heading hierarchy
- Include alt text for images
- Ensure good contrast in diagrams
- Provide text alternatives for videos

## Documentation Tools

### Recommended Tools
- **API Docs**: Swagger/OpenAPI
- **Code Docs**: YARD (Ruby), JSDoc (JavaScript)
- **Diagrams**: Mermaid, PlantUML
- **Screenshots**: Annotated with key points
- **Videos**: Loom for walkthroughs

### Documentation Hosting
- **GitHub Pages**: For public projects
- **Internal Wiki**: For private documentation
- **README files**: In each major directory
- **Code comments**: For implementation details

## Maintenance

### Review Schedule
- Review documentation quarterly
- Update after major changes
- Verify links and examples regularly
- Remove outdated information

### Documentation Checklist
- [ ] README is up to date
- [ ] API documentation matches implementation
- [ ] Installation instructions work on clean system
- [ ] All examples run without errors
- [ ] Environment variables are documented
- [ ] Architecture diagrams reflect current state
- [ ] Deployment guide is current
- [ ] Troubleshooting section covers common issues