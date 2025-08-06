# Tech Stack

> Last updated: 2025-08-06

## Context

Global tech stack defaults for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

## Core Stack
- App Framework: Ruby on Rails 8.0+
- Language: Ruby 3.2+
- Primary Database: PostgreSQL 17+
- ORM: Active Record
- JS Language: Typescript latest stable
- CSS language: SCSS
- HTML template language: Slim

## Frontend
- JavaScript Framework: StimulusJS
- Build Tool: Vite
- Import Strategy: ES6 modules with importmaps
- Package Manager: yarn
- Node Version: 22 LTS
- CSS Framework: Bootstrap 5+
- UI Components: ViewComponent gem
- UI Installation: Via development gems group
- Font Provider: Google Fonts
- Font Loading: Self-hosted for performance
- Icons: Bootstrap Icons

## Infrastructure
- Application Hosting: Heroku
- Hosting Region: Primary region based on user base
- Database Hosting: Heroku
- Database Backups: Daily automated
- Asset Storage: Amazon S3
- CDN: CloudFront
- Asset Access: Private with signed URLs

## CI/CD
- CI/CD Platform: GitHub Actions
- CI/CD Trigger: Push to main/staging branches
- Tests: Run before deployment
- Production Environment: main branch
- Staging Environment: staging branch

## Development & Testing
- Test Framework: RSpec
- System Tests: Capybara with Selenium
- Code Quality: RuboCop, Brakeman
- Code Coverage: SimpleCov

## Background Jobs & Caching
- Background Jobs: Sidekiq
- Queue Backend: Solid Queue
- Cache Store: Solid Cache
- Action Cable: Solid Cable

## Monitoring & Observability
- Error Tracking: Bugsnag
- APM: Scout APM
- Logging: Lograge with Papertrail
- Uptime Monitoring: UptimeRobot

## Authentication & Security
- Authentication: Devise
- Authorization: Pundit
- API Authentication: Bearer Token
- SSL Certificates: Let's Encrypt

## Email & Communication
- Transactional Email: Customer.io
- Email Preview: Letter Opener (development)
- SMS: Twilio

## Development Tools
- Local Development: devcontainer, Docker, and docker-compose
- API Documentation: Swagger/OpenAPI
- Git Hooks: husky and lintstaged packages

## Search & Analytics
- Search: PostgreSQL full-text
