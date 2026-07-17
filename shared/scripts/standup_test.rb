#!/usr/bin/env ruby
# frozen_string_literal: true

# Unit tests for the pure logic in standup.rb (window, classification, dedup,
# rendering). The gh/network I/O layer is not exercised here. Run with:
#   ruby shared/scripts/standup_test.rb

require 'minitest/autorun'
require 'date'
require_relative 'standup'

class StandupTest < Minitest::Test
  # --- since_date ---------------------------------------------------------
  def test_since_date_monday_reaches_back_to_friday
    assert_equal '2026-07-03', Standup.since_date(Date.new(2026, 7, 6)) # Mon -> Fri
  end

  def test_since_date_weekday_is_yesterday
    assert_equal '2026-07-06', Standup.since_date(Date.new(2026, 7, 7)) # Tue -> Mon
  end

  def test_since_date_sunday_is_yesterday
    assert_equal '2026-07-04', Standup.since_date(Date.new(2026, 7, 5)) # Sun -> Sat
  end

  # --- classify -----------------------------------------------------------
  def test_classify_merged_is_deployed
    assert_equal :deployed, Standup.classify({ 'state' => 'merged', 'isDraft' => false }, 'APPROVED')
  end

  def test_classify_draft_is_wip
    assert_equal :wip, Standup.classify({ 'state' => 'open', 'isDraft' => true }, nil)
  end

  def test_classify_open_approved_is_ready
    assert_equal :ready, Standup.classify({ 'state' => 'open', 'isDraft' => false }, 'APPROVED')
  end

  def test_classify_open_unapproved_is_needs_cr
    assert_equal :needs_cr, Standup.classify({ 'state' => 'open', 'isDraft' => false }, 'REVIEW_REQUIRED')
    assert_equal :needs_cr, Standup.classify({ 'state' => 'open', 'isDraft' => false }, nil)
    assert_equal :needs_cr, Standup.classify({ 'state' => 'open', 'isDraft' => false }, 'CHANGES_REQUESTED')
  end

  # --- repo_from_url ------------------------------------------------------
  def test_repo_from_url
    assert_equal 'EscrowSafe/web', Standup.repo_from_url('https://github.com/EscrowSafe/web/pull/4099')
    assert_equal 'EscrowSafe/web', Standup.repo_from_url('https://github.com/EscrowSafe/web/issues/4083')
    assert_nil Standup.repo_from_url('https://example.com/nope')
  end

  # --- build_output -------------------------------------------------------
  def pr(num, title, state, draft = false)
    { 'number' => num, 'title' => title,
      'url' => "https://github.com/EscrowSafe/web/pull/#{num}", 'state' => state, 'isDraft' => draft }
  end

  def test_build_output_orders_buckets_and_formats_bullets
    prs = [
      pr(1, 'Deployed thing', 'merged'),
      pr(2, 'Draft thing', 'open', true),
      pr(3, 'Needs review', 'open'),
      pr(4, 'Approved thing', 'open')
    ]
    reviews = {
      'https://github.com/EscrowSafe/web/pull/3' => 'REVIEW_REQUIRED',
      'https://github.com/EscrowSafe/web/pull/4' => 'APPROVED'
    }
    out = Standup.build_output(prs, reviews, [])

    expected = <<~OUT.chomp
      *Yesterday*:
      - :construction: WIP: [Draft thing](https://github.com/EscrowSafe/web/pull/2)
      - :eyes: Needs CR: [Needs review](https://github.com/EscrowSafe/web/pull/3)
      - :merge: Ready to Deploy: [Approved thing](https://github.com/EscrowSafe/web/pull/4)
      - :ship: Deployed: [Deployed thing](https://github.com/EscrowSafe/web/pull/1)

      *Today*:
    OUT
    assert_equal expected, out
  end

  def test_build_output_dedups_by_url
    dup = pr(1, 'Same PR', 'merged')
    out = Standup.build_output([dup, dup.dup], {}, [])
    assert_equal 1, out.scan('pull/1').length
  end

  def test_build_output_renders_today_items
    item = { 'title' => 'Fix S3 buckets', 'url' => 'https://github.com/EscrowSafe/web/issues/4083' }
    out = Standup.build_output([], {}, [item])
    assert_includes out, "*Today*:\n- :construction: [Fix S3 buckets](https://github.com/EscrowSafe/web/issues/4083)"
  end

  def test_build_output_empty_has_headers_only
    assert_equal "*Yesterday*:\n\n*Today*:", Standup.build_output([], {}, [])
  end

  def test_build_output_appends_linked_issue_marker
    pr = pr(1, 'Add sent status', 'merged')
    linked = { pr['url'] => [{ 'number' => 123, 'url' => 'https://github.com/EscrowSafe/web/issues/123' }] }
    out = Standup.build_output([pr], {}, [], linked_issues: linked)
    assert_includes out, "[Add sent status](#{pr['url']}) ([Task #123](https://github.com/EscrowSafe/web/issues/123))"
  end

  def test_build_output_appends_multiple_linked_issue_markers
    pr = pr(1, 'X', 'merged')
    linked = { pr['url'] => [{ 'number' => 1, 'url' => 'u1' }, { 'number' => 2, 'url' => 'u2' }] }
    out = Standup.build_output([pr], {}, [], linked_issues: linked)
    assert_includes out, '([Task #1](u1)) ([Task #2](u2))'
  end

  def test_build_output_no_marker_without_linked_issue
    pr = pr(1, 'X', 'merged')
    out = Standup.build_output([pr], {}, [])
    refute_includes out, 'Task #'
  end

  def test_build_output_monday_uses_friday_header
    assert_equal "*Friday*:\n\n*Today*:", Standup.build_output([], {}, [], monday: true)
  end

  # Header must sit directly on top of its first bullet (Slack composer quirk).
  def test_no_blank_line_between_header_and_first_bullet
    out = Standup.build_output([pr(1, 'X', 'merged')], {}, [])
    assert_match(/\A\*Yesterday\*:\n- /, out)
  end
end
