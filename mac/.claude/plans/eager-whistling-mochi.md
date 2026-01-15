# Plan: Install wicked_pdf and Add PDF Download for Decision Tree Certificate

## Summary
Install and configure the wicked_pdf gem, then modify the Download button on the decision tree confirmation page to generate and download a PDF instead of opening the browser print dialog.

## Current State
- **Download button** (`app/views/decision_tree/confirmations/show.html.slim:187-188`): Links to `?print=yes` which opens a new tab with print layout
- **Print view**: `app/views/decision_tree/confirmations/print.html.slim` - certificate content for printing
- **Print layout**: `app/views/layouts/decision_tree_print.html.slim` - uses `PrintHeadComponent` which auto-triggers `window.print`
- **Print CSS**: `app/assets/stylesheets/decision_tree_print.sass` - A4 page styling
- **No existing PDF gems** in Gemfile

## Implementation Steps

### Step 1: Install wicked_pdf gem
**Files to modify:**
- `Gemfile`

Add:
```ruby
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
```

Run `bundle install`.

### Step 2: Create wicked_pdf initializer
**Files to create:**
- `config/initializers/wicked_pdf.rb`

```ruby
WickedPdf.config = {
  exe_path: Gem.bin_path('wkhtmltopdf-binary', 'wkhtmltopdf')
}
```

### Step 3: Create PDF head component
**Files to create:**
- `app/components/decision_tree_pdf_head_component.rb`

Similar to `PrintHeadComponent` but:
- No `setTimeout(window.print)` JavaScript
- Uses `wicked_pdf_stylesheet_link_tag` helper for CSS
- Includes both `print` and `decision_tree_print` stylesheets

### Step 4: Create PDF layout
**Files to create:**
- `app/views/layouts/decision_tree_pdf.html.slim`

Based on `decision_tree_print.html.slim` but:
- Uses `DecisionTreePdfHeadComponent`
- Uses `wicked_pdf_asset_base64` for inline SVG logos
- No customerio_identify or terms_agreement_modal partials (not needed for PDF)

### Step 5: Add download action to controller
**Files to modify:**
- `app/controllers/decision_tree/confirmations_controller.rb`

Add `download` action:
```ruby
def download
  @page_title = 'FinCEN Decision Tree Certificate - EscrowSafe'
  pdf = render_to_string(
    pdf: 'certificate',
    template: 'decision_tree/confirmations/print',
    layout: 'decision_tree_pdf',
    page_size: 'A4',
    margin: { top: '10mm', bottom: '30mm', left: '0mm', right: '0mm' }
  )
  send_data pdf,
            filename: "fincen-decision-tree-certificate-#{@decision_tree_presenter.id}.pdf",
            type: 'application/pdf',
            disposition: 'attachment'
end
```

### Step 6: Update routes
**Files to modify:**
- `config/routes/fincen_decision_tree.rb`

Add download route:
```ruby
resource :confirmation, only: [:show] do
  post :send_email
  get :download
end
```

### Step 7: Update Download button
**Files to modify:**
- `app/views/decision_tree/confirmations/show.html.slim`

Change line 187-188 from:
```slim
= link_to decision_tree_confirmation_path(@decision_tree_presenter, print: 'yes'), target: '_blank', class: 'btn btn-secondary w-100 mb-4' do
```

To:
```slim
= link_to download_decision_tree_confirmation_path(@decision_tree_presenter), class: 'btn btn-secondary w-100 mb-4' do
```

(Remove `target: '_blank'` since it downloads directly)

### Step 8: Handle SVG logos in PDF
wkhtmltopdf cannot fetch external assets the same way browsers do. Options:
- Use `wicked_pdf_image_tag` with absolute URLs
- Convert SVGs to base64 and embed inline
- Use the `wicked_pdf_asset_base64` helper

The PDF layout will need to handle the logo differently than the HTML version.

## Files Summary

**New files:**
1. `config/initializers/wicked_pdf.rb`
2. `app/components/decision_tree_pdf_head_component.rb`
3. `app/views/layouts/decision_tree_pdf.html.slim`

**Modified files:**
1. `Gemfile`
2. `app/controllers/decision_tree/confirmations_controller.rb`
3. `config/routes/fincen_decision_tree.rb`
4. `app/views/decision_tree/confirmations/show.html.slim`

## Testing
- Verify PDF downloads with correct filename
- Compare PDF output to browser print preview for visual consistency
- Test all exit step variations (entities, exemptions, financing, residential)
