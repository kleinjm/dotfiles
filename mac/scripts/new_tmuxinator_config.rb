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
        # main-horizontal causes tmux to crash
        # this layout is for 2 panes
        # use 49e3,272x67,0,0[272x48,0,0,2,272x18,0,49{136x18,0,49,8,135x18,137,49,10}]
        # for 3 panes
        layout: e571,272x59,0,0[272x49,0,0,24,272x9,0,50,25]
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
