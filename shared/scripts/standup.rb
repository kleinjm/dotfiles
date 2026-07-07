#!/usr/bin/env ruby
# frozen_string_literal: true

# Standup generator. Emits a Slack-ready "*Yesterday*:" / "*Today*:" block.
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
  ME  = 'kleinjm'
  PROJECT_NUMBER = '1'

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

  # Build the full Slack block string from already-fetched data:
  #   prs               - array of PR hashes (may contain URL duplicates)
  #   review_decisions  - { pr_url => reviewDecision } for open non-draft PRs
  #   today_items       - array of board item hashes (each with a 'content' hash)
  def build_output(prs, review_decisions, today_items)
    buckets = Hash.new { |h, k| h[k] = [] }
    seen = {}
    prs.each do |pr|
      next if seen[pr['url']]

      seen[pr['url']] = true
      buckets[classify(pr, review_decisions[pr['url']])] << pr
    end

    lines = ['*Yesterday*:']
    ORDER.each do |b|
      buckets[b].each { |pr| lines << "- #{LABELS[b]} [#{pr['title']}](#{pr['url']})" }
    end
    lines << ''
    lines << '*Today*:'
    today_items.each do |i|
      c = i['content'] || {}
      lines << "- :construction: [#{c['title']}](#{c['url']})"
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

  # The board holds >1000 items; the limit must exceed the total or In-Progress
  # items past the cutoff are silently dropped (gh paginates internally to reach it).
  BOARD_LIMIT = 5000

  def fetch_today_items
    board = gh_json(%W[project item-list #{PROJECT_NUMBER} --owner #{ORG} --format json --limit #{BOARD_LIMIT}])
    items = board.is_a?(Hash) ? (board['items'] || []) : []
    items.select { |i| i['status'] == 'In Progress' && Array(i['assignees']).include?(ME) }
  end

  def main
    since = since_date(Date.today)
    prs = fetch_prs(since)
    puts build_output(prs, fetch_review_decisions(prs), fetch_today_items)
  end
end

Standup.main if __FILE__ == $PROGRAM_NAME
