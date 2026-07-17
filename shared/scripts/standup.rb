#!/usr/bin/env ruby
# frozen_string_literal: true

# Standup generator. Emits a Slack-ready "*Yesterday*:" / "*Today*:" block
# (the first header becomes "*Friday*:" when run on a Monday).
#
# Yesterday  = PRs (authored or assigned to me) touched in the window, classified
#              by where they sit in the dev process. Issues are intentionally
#              excluded — Yesterday is "what I actually did" (PRs only).
# Today      = items assigned to me sitting in the "In Progress" column of the
#              EscrowSafe org project board (https://github.com/orgs/EscrowSafe/projects/1).
#
# Window: yesterday's date, or — if today is Monday — last Friday (covers Fri/Sat/Sun).
#
# The pure logic (window, classification, dedup, rendering) lives in the Standup
# module and is unit-tested by standup_test.rb. The `gh` calls and program entry
# point live below the module, guarded so `require`-ing this file is side-effect free.

require 'json'
require 'date'
require 'open3'

module Standup
  ORG = 'EscrowSafe'

  LABELS = {
    wip:      ':construction: WIP:',
    needs_cr: ':eyes: Needs CR:',
    ready:    ':merge: Ready to Deploy:',
    deployed: ':ship: Deployed:'
  }.freeze
  ORDER = %i[wip needs_cr ready deployed].freeze

  module_function

  # Start of the standup window as an ISO date string. Monday reaches back to
  # Friday so the block covers weekend work; every other day is just yesterday.
  def since_date(today)
    (today.monday? ? today - 3 : today - 1).strftime('%F')
  end

  def repo_from_url(url)
    m = url.to_s.match(%r{github\.com/([^/]+/[^/]+)/(?:pull|issues)/\d+})
    m && m[1]
  end

  # Which dev-process bucket a PR sits in. `review_decision` is the PR's
  # reviewDecision (nil when not fetched — only open non-draft PRs need it).
  def classify(pr, review_decision = nil)
    return :deployed if pr['state'] == 'merged'
    return :wip if pr['isDraft']

    review_decision == 'APPROVED' ? :ready : :needs_cr
  end

  # Trailing " ([Task #123](url))" markers for a PR's linked issues.
  # `issues` is an array of { 'number' => Int, 'url' => String }; empty for none.
  def issue_suffix(issues)
    Array(issues).map { |i| " ([Task ##{i['number']}](#{i['url']}))" }.join
  end

  # Issue numbers from a PR body's "Related" lines (e.g. `**Related:** Related
  # to #4197`), as `#123`. Only lines mentioning "Related" are scanned so stray
  # `#N` elsewhere in the body is ignored. Closing links (Closes/Fixes/Resolves)
  # come separately from GitHub's closingIssuesReferences. Deduped, order kept.
  def related_issue_numbers(body)
    body.to_s.each_line
        .select { |line| line =~ /related/i }
        .flat_map { |line| line.scan(/(?<![\w])#(\d+)/).flatten }
        .map(&:to_i).uniq
  end

  # Build the full Slack block string from already-fetched data:
  #   prs               - array of PR hashes (may contain URL duplicates)
  #   review_decisions  - { pr_url => reviewDecision } for open non-draft PRs
  #   today_items       - array of issue hashes (each with 'title' and 'url')
  #   linked_issues     - { pr_url => [{ 'number', 'url' }, ...] } for each PR
  def build_output(prs, review_decisions, today_items, linked_issues: {}, monday: false)
    buckets = Hash.new { |h, k| h[k] = [] }
    seen = {}
    prs.each do |pr|
      next if seen[pr['url']]

      seen[pr['url']] = true
      buckets[classify(pr, review_decisions[pr['url']])] << pr
    end

    lines = [monday ? '*Friday*:' : '*Yesterday*:']
    ORDER.each do |b|
      buckets[b].each do |pr|
        lines << "- #{LABELS[b]} [#{pr['title']}](#{pr['url']})#{issue_suffix(linked_issues[pr['url']])}"
      end
    end
    lines << ''
    lines << '*Today*:'
    today_items.each do |i|
      lines << "- :construction: [#{i['title']}](#{i['url']})"
    end
    lines.join("\n")
  end
end

# --- I/O layer (not unit-tested; needs the gh CLI + network) --------------
module Standup
  module_function

  def gh_json(args)
    out, _err, status = Open3.capture3('gh', *args)
    return nil unless status.success?
    return nil if out.strip.empty?

    JSON.parse(out)
  rescue JSON::ParserError
    nil
  end

  def fetch_prs(since)
    fields = 'number,title,url,state,isDraft'
    queries = [
      %W[search prs --author @me --owner #{ORG} --merged --merged-at >=#{since} --json #{fields} --limit 50],
      %W[search prs --author @me --owner #{ORG} --state open --updated >=#{since} --json #{fields} --limit 50],
      %W[search prs --assignee @me --owner #{ORG} --merged --merged-at >=#{since} --json #{fields} --limit 50],
      %W[search prs --assignee @me --owner #{ORG} --state open --updated >=#{since} --json #{fields} --limit 50]
    ]
    queries.flat_map { |q| gh_json(q) || [] }
  end

  # reviewDecision for each open, non-draft PR (the only ones whose bucket depends on it).
  def fetch_review_decisions(prs)
    prs.each_with_object({}) do |pr, acc|
      next if pr['state'] == 'merged' || pr['isDraft'] || acc.key?(pr['url'])

      repo = repo_from_url(pr['url'])
      view = repo && gh_json(%W[pr view #{pr['number']} --repo #{repo} --json reviewDecision])
      acc[pr['url']] = view.is_a?(Hash) ? view['reviewDecision'] : nil
    end
  end

  # Issues each PR references: GitHub's closing links (Fixes/Closes #N) plus any
  # `#N` on the body's "Related" lines. Search doesn't return either, so this
  # needs a per-PR `pr view`. Returns { pr_url => [{ 'number', 'url' }, ...] },
  # deduped by PR url; the PR's own number is excluded.
  def fetch_linked_issues(prs)
    prs.each_with_object({}) do |pr, acc|
      next if acc.key?(pr['url'])

      repo = repo_from_url(pr['url'])
      view = repo && gh_json(%W[pr view #{pr['number']} --repo #{repo}
                                --json body,closingIssuesReferences])
      view = {} unless view.is_a?(Hash)
      numbers = Array(view['closingIssuesReferences']).map { |r| r['number'] } +
                related_issue_numbers(view['body'])
      acc[pr['url']] = numbers.uniq
                              .reject { |n| n == pr['number'] }
                              .map { |n| { 'number' => n, 'url' => "https://github.com/#{repo}/issues/#{n}" } }
    end
  end

  # The board holds >1000 items and the Projects v2 API can't filter by status
  # server-side, so scanning the whole board is both slow and rate-limit-hungry.
  # Instead list just my open assigned issues (assignee filtered server-side —
  # a small set) and keep the ones whose project status is In Progress.
  REPO = "#{ORG}/web".freeze
  IN_PROGRESS = 'In Progress'

  def fetch_today_items
    issues = gh_json(%W[issue list --repo #{REPO} --assignee @me --state open --limit 100
                        --json number,title,url,projectItems])
    return [] unless issues.is_a?(Array)

    issues.select { |i| Array(i['projectItems']).any? { |p| p.dig('status', 'name') == IN_PROGRESS } }
          .sort_by { |i| i['number'] }
  end

  def main
    today = Date.today
    since = since_date(today)
    prs = fetch_prs(since)
    puts build_output(prs, fetch_review_decisions(prs), fetch_today_items,
                      linked_issues: fetch_linked_issues(prs), monday: today.monday?)
  end
end

Standup.main if __FILE__ == $PROGRAM_NAME
