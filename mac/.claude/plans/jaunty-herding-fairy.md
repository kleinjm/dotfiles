# Fix: Selfie Video AbortError on Identity Page

## Problem

Users see `AbortError The operation was aborted.` when clicking play on selfie videos on the identity page (`/organizations/:org/customers/:id/identity`).

**Root Cause:** The media controller generates presigned S3 URLs with only 15-second expiration:

```ruby
# app/controllers/customers/media_controller.rb:35
redirect_to @attachment.url(expires_in: 15.seconds), allow_other_host: true
```

**Why this fails:**
1. User clicks play on video
2. Controller redirects to presigned S3 URL
3. Browser starts streaming but if network is slow or user seeks within video
4. After 15 seconds, S3 rejects continued access → AbortError

## Solution

Increase the presigned URL expiration from 15 seconds to 5 minutes.

**Security analysis:**
- URL is only generated after authorization check passes
- Viewer access is logged in `media_views` table
- Response is marked `no_store` (no browser caching)
- 5 minutes balances security with usability for slow connections/video seeking

## Implementation

**File:** `app/controllers/customers/media_controller.rb:35`

```ruby
# Before
redirect_to @attachment.url(expires_in: 15.seconds), allow_other_host: true

# After
redirect_to @attachment.url(expires_in: 5.minutes), allow_other_host: true
```

## Testing

1. Load identity page with selfie video
2. Click play and verify video plays without error
3. Test seeking within video
4. Test on slow network simulation if possible
