# Slim Template Style Guide

> Last updated: 2025-08-06

## Context

Slim template-specific coding standards for Agent OS projects.

## Core Principles

### Template Language
- Use Slim for all view templates
- Never use ERB in new views
- Use Ruby interpolation `#{}` instead of ERB-style `<%= %>`

## Syntax Conventions

### Multi-line Arguments
Split each argument onto its own line when multiple arguments are present:
```slim
= link_to(
  'Edit Profile',
  edit_user_path(user),
  class: 'btn btn-primary',
  data: { turbo_frame: 'modal' }
)
```

### Argument Positioning
- First argument on the opening `(` line
- Last argument on the closing `)` line
- Each intermediate argument on its own line

### HTML Attributes
Use HTML-style attribute syntax for multiple data attributes:
```slim
div data-controller="user-form" data-action="submit->user-form#save"
  / content
```

## Partial Guidelines

### Variable Passing
- **Never** use instance variables in partials
- Pass all data explicitly via locals
```slim
/ Good
= render 'shared/user_card', user: @user, editable: true

/ Bad - relies on instance variable
= render 'shared/user_card'  / assuming partial uses @user
```

### Partial Isolation
- Partials should be self-contained
- Document required locals with comments
- Provide sensible defaults where appropriate

### Partial Naming
- Use descriptive names with underscores
- Prefix with underscore: `_user_card.html.slim`
- Group related partials in subdirectories

## Form Helpers

### Labels
- Don't use strings for labels - use locales
```slim
/ Good
= f.label :email

/ Bad
= f.label :email, "Email Address"
```

### Form Structure
```slim
= form_with model: @user, local: true do |f|
  .form-group
    = f.label :name
    = f.text_field :name, class: 'form-control'
  
  .form-group
    = f.label :email
    = f.email_field :email, class: 'form-control'
  
  = f.submit class: 'btn btn-primary'
```

## Component Organization

### ViewComponents
- Prefer ViewComponents for reusable UI elements
- Keep component-specific styles with the component
- Use slots for flexible content areas

### Layout Structure
```slim
.container
  .row
    .col-md-8
      = yield :main_content
    .col-md-4
      = render 'shared/sidebar'
```

## Data Attributes

### Stimulus Integration
Always use data attributes for JavaScript behavior:
```slim
div data-controller="dropdown"
  button data-action="click->dropdown#toggle" Toggle
  .dropdown-menu data-dropdown-target="menu"
    / menu items
```

### Turbo Frames
```slim
= turbo_frame_tag "user_#{user.id}" do
  .user-card
    / content
```

## Best Practices

### Keep Logic Minimal
- Move complex conditions to helpers or presenters
- Avoid multi-line Ruby code in templates
- Use view models for complex data preparation

### Indentation
- Use 2 spaces for indentation
- Maintain consistent nesting levels
- Group related elements

### Comments
- Use Slim comments `/` for template notes
- Document complex markup structures
- Explain non-obvious data attributes

### Performance
- Avoid N+1 queries - ensure data is preloaded
- Use fragment caching for expensive partials
- Lazy load images with loading="lazy"