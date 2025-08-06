# Development Workflow

> Last updated: 2025-08-06

## Context

Standard development workflow and environment setup for Agent OS projects.

## Package Management

### JavaScript/TypeScript
- **Always use `yarn`** instead of `npm` for package management
- Lock file: `yarn.lock` must be committed
- Install packages: `yarn add package-name`
- Install dev dependencies: `yarn add --dev package-name`
- Update packages: `yarn upgrade`

### Ruby
- Use Bundler for gem management
- Lock file: `Gemfile.lock` must be committed
- Install gems: `bundle install`
- Update gems: `bundle update`

## Development Server

### Starting Development
```bash
# Preferred method - includes TypeScript watcher and livereload
bin/dev

# Alternative for Rails only (no asset compilation)
rails server
```

### Asset Management
- **Never use** `rails assets:precompile` during development
- If assets are problematic: `rails assets:clobber`
- Assets compile automatically with `bin/dev`

## Environment Setup

### Required Tools
- Ruby (version specified in `.ruby-version`)
- Node.js 22 LTS
- PostgreSQL 17+
- Redis (for caching and background jobs)
- Yarn package manager

### Initial Setup
```bash
# Clone repository
git clone [repository-url]
cd [project-name]

# Install dependencies
bundle install
yarn install

# Setup database
rails db:create
rails db:migrate
rails db:seed

# Start development server
bin/dev
```

## Development Tools

### Code Quality
```bash
# Ruby linting
bundle exec rubocop

# JavaScript linting
yarn lint

# Run all quality checks
yarn quality
```

### Testing
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run JavaScript tests
yarn test

# Run with coverage
COVERAGE=true bundle exec rspec
```

### Database Operations
```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# Rollback migration
rails db:rollback

# Reset database
rails db:reset

# Seed database
rails db:seed
```

## Debugging Workflow

### Rails Debugging
1. **Check logs first**: `tail -f log/development.log`
2. **Use Rails runner**: `rails runner "puts User.count"`
3. **Add output statements**: Use `puts`, `p`, or `Rails.logger`
4. **Never use binding.pry or debugger**

### JavaScript Debugging
1. **Console logging**: Use `console.log` liberally
2. **Browser DevTools**: Inspect network, console, elements
3. **Write to HTML**: Output debug info to page elements
4. **Source maps**: Ensure enabled for TypeScript debugging

### System Test Debugging
1. **Screenshots**: Use `save_screenshot` in tests
2. **HTML dumps**: Use `save_page` to inspect HTML
3. **Test logs**: Check `log/test.log`
4. **Visible browser**: Run with `HEADLESS=false`

## Git Workflow

### Branch Management
```bash
# Create feature branch
git checkout -b kleinjm/feature-name

# Keep branch updated
git fetch origin
git rebase origin/main

# Push changes
git push origin kleinjm/feature-name
```

### Commit Process
```bash
# Stage changes
git add -p  # Interactive staging

# Commit with conventional format
git commit -m "feat: add user authentication"

# Amend last commit
git commit --amend
```

## Docker Development

### Using Devcontainer
```bash
# Build container
docker-compose build

# Start services
docker-compose up

# Run commands in container
docker-compose exec web rails console
docker-compose exec web bundle exec rspec
```

### Docker Commands
```bash
# View logs
docker-compose logs -f web

# Restart services
docker-compose restart

# Clean up
docker-compose down -v
```

## Continuous Integration

### Pre-commit Hooks
Using Husky and lint-staged:
```json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "*.rb": ["rubocop --auto-correct"],
    "*.{js,ts}": ["eslint --fix"],
    "*.{json,md}": ["prettier --write"]
  }
}
```

### CI Pipeline
- Tests run on every push
- Linting and formatting checks
- Coverage reports generated
- Deployment on main branch merge

## Common Issues and Solutions

### Asset Pipeline Issues
```bash
# Clear asset cache
rails assets:clobber
rm -rf tmp/cache/assets

# Restart dev server
bin/dev
```

### Database Issues
```bash
# Reset and reseed
rails db:drop db:create db:migrate db:seed

# Fix migration issues
rails db:migrate:status
rails db:rollback STEP=1
```

### Dependency Issues
```bash
# Clear and reinstall Ruby deps
rm -rf vendor/bundle
bundle install

# Clear and reinstall JS deps
rm -rf node_modules yarn.lock
yarn install
```