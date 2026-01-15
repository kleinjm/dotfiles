# Fix Silent Video Attachment Failures in Identity Verification

## Problem Summary

Selfie videos from Plaid fail to attach silently. The `ingest!` method has no error handling around `uri.open` and `video.attach`. When downloads fail (network error, expired URL, S3 error), the record still shows `status: success` but `video.attached?` is false.

**Root cause:** No rescue blocks, no Rollbar reporting, no job retry configuration.

## Files to Modify

1. `app/models/customers/identity_verification_selfie_check.rb` - Add error handling to `ingest!`
2. `app/models/customers/identity_verification_document_image.rb` - Same fix for document images
3. `app/jobs/customers/process_identity_verification_job.rb` - Add retry logic with fresh URL sync
4. `spec/models/customers/identity_verification_selfie_check_spec.rb` - Add tests
5. `spec/jobs/customers/process_identity_verification_job_spec.rb` - Add retry tests

## Implementation

### 1. Update `IdentityVerificationSelfieCheck#ingest!`

Wrap download/attachment in error handling:

```ruby
DOWNLOAD_ERRORS = [
  OpenURI::HTTPError,
  Net::OpenTimeout,
  Net::ReadTimeout,
  SocketError,
  Errno::ECONNREFUSED,
  Errno::ETIMEDOUT
].freeze

def ingest!(data)
  update!(status: data['status'], analysis: data['analysis'])
  attach_media(:image, data.dig('capture', 'image_url'))
  attach_media(:video, data.dig('capture', 'video_url'))
  self
end

private

def attach_media(type, url)
  attachment = public_send(type)

  if url.blank?
    attachment.purge if attachment.attached?
    return
  end

  return if attachment.attached?

  uri = URI(url.to_s)
  extension = uri.path.split('.').last
  filename = "#{uuid}-#{type}.#{extension}"
  io = uri.open
  attachment.attach(io:, key: file_attachment_key(filename), filename:)
rescue *DOWNLOAD_ERRORS, ActiveStorage::IntegrityError => e
  Rollbar.error(e, "IDV selfie #{type} attachment failed",
    customer_id: idv.customer_id,
    selfie_check_uuid: uuid,
    url_host: uri&.host
  )
  raise
end
```

**Note:** Also fix the existing bug on line 51 where `io` is computed but then `uri.open` is called again.

### 2. Update `IdentityVerificationDocumentImage#ingest!`

Same pattern - add rescue block with Rollbar:

```ruby
DOWNLOAD_ERRORS = [
  OpenURI::HTTPError,
  Net::OpenTimeout,
  Net::ReadTimeout,
  SocketError,
  Errno::ECONNREFUSED,
  Errno::ETIMEDOUT
].freeze

def ingest!(url)
  uri = URI(url.to_s).tap { |u| u.query = nil }
  plaid_url_hash = Digest::MD5.hexdigest(uri.to_s)

  return if persisted? && self.plaid_url_hash == plaid_url_hash

  transaction do
    update!(plaid_url_hash:)
    extension = uri.path.split('.').last
    io = URI(url).open
    file.attach(io:, key: file_attachment_key(extension), filename: "#{identifier}.#{extension}")
    usable = file.blob.byte_size >= 5_120
    update!(usable:)
  end
rescue *DOWNLOAD_ERRORS, ActiveStorage::IntegrityError => e
  Rollbar.error(e, 'IDV document image attachment failed',
    customer_id: document.idv.customer_id,
    document_image_uuid: uuid,
    url_host: uri&.host
  )
  raise
end
```

### 3. Update `ProcessIdentityVerificationJob`

Add retry with fresh URL sync:

```ruby
class Customers::ProcessIdentityVerificationJob < ApplicationJob
  queue_as :default

  # Retry on download failures - always sync fresh URLs since Plaid URLs expire in ~60s
  retry_on OpenURI::HTTPError, Net::OpenTimeout, Net::ReadTimeout,
           SocketError, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
           ActiveStorage::IntegrityError,
           attempts: 3,
           wait: ->(executions) { (30 * executions) + rand(10).seconds }

  limits_concurrency to: 1, key: ->(idv, _plaid_idv) { idv.customer_id }, duration: 1.hour

  def perform(idv, plaid_idv)
    return if plaid_idv.id != idv.plaid_idvs.last.id

    # Always sync on retry (executions > 1) or if data is stale
    # Plaid URLs expire in ~60 seconds
    if executions > 1 || plaid_idv.data_updated_at <= 50.seconds.ago
      plaid_idv.sync!
    end

    idv.process_plaid_idv_data(plaid_idv, files: :sync)
  end
end
```

### 4. Add Tests

**Selfie check spec:**
- Test that download errors are logged to Rollbar
- Test that errors are re-raised (not swallowed)
- Test successful attachment still works

**Job spec:**
- Test that `sync!` is called on retry (`executions > 1`)
- Test retry_on configuration

## Verification

1. **Unit tests:** `bundle exec rspec spec/models/customers/identity_verification_selfie_check_spec.rb spec/models/customers/identity_verification_document_image_spec.rb spec/jobs/customers/process_identity_verification_job_spec.rb`

2. **Manual test in dev:** Simulate a download failure by temporarily modifying `ingest!` to raise an error, verify:
   - Error appears in Rollbar (or logs in dev)
   - Job retries with fresh sync
   - After fix, attachment succeeds

3. **Check existing tests pass:** `bundle exec rspec spec/models/customers/identity_verification_spec.rb spec/models/customers/identity_report_spec.rb`
