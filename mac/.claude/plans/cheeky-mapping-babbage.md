# Plan: Fix "Remember me" Checkbox Styling

## Summary

Update the "Remember me" checkbox on the two-factor authentication login page to use the standard Bootstrap `form-check` pattern used elsewhere in the application.

## File to Modify

- `app/views/auth/two_factor/new.html.slim` (lines 16-18)

## Change

**Current code:**
```slim
p.text-center.py-3
  = check_box_tag :remember, checked: params.fetch(:remember, '0') == '1'
  = label_tag :remember, 'Remember me', class: 'form-check-label ps-2'
```

**Updated code:**
```slim
.form-check.text-center.py-3.d-flex.justify-content-center
  = check_box_tag :remember, checked: params.fetch(:remember, '0') == '1', class: 'form-check-input'
  = label_tag :remember, 'Remember me', class: 'form-check-label ms-2'
```

## What This Changes

1. Replace `p` with `div.form-check` container
2. Add `form-check-input` class to the checkbox
3. Change `ps-2` to `ms-2` on the label (consistent with other checkboxes)
4. Add `d-flex justify-content-center` to maintain centered layout within the form-check structure
