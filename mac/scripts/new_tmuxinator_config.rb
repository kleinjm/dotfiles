#!/usr/bin/env ruby

# frozen_string_literal: true

name = ARGV.first
unless name
  raise "\n\nPlease provide a project name. Ie.\n" \
        "mac/scripts/new_tmuxinator_config.rb my_project"
end

template = <<~TEMPLATE
  name: #{name}
  root: <%= ENV["PROJECT_DIR"] %>/#{name}
  startup_pane: 1

  windows:
    - editor:
        layout: main-horizontal
        panes:
          - vim .
          -
TEMPLATE

TMUX_DIR = "shared/tmux/.tmuxinator/"
File.open("#{TMUX_DIR}/#{name}.yml", "w") do |file|
  file.puts template
end

# clone repo
if `ls #{ENV["PROJECT_DIR"]}`.match?(name)
  puts "Repo already exists, not cloning"
else
  `cd #{ENV["PROJECT_DIR"]} && git clone https://github.com/doximity/#{name}.git`
end
