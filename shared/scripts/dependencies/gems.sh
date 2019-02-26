#!/bin/sh

set -e
set -o pipefail

echo "***Installing Ruby, Bundler and Gems***"

# install the project's ruby version
< .ruby-version rbenv install

# See https://stackoverflow.com/questions/5380671/getting-the-warning-insecure-world-writable-dir-home-chance-in-path-mode-04
sudo chmod go-w /usr/local

# TODO: change the order of running this script vs symlinking
# At this point, the rbenv ruby version is not the one being used because zshrc
# is not symlinked and has not added it to the path
gem install bundler # if this command fails, run `rbenv init`

# If bundler is broken and you're seeing this trace, see this link
# https://bundler.io/blog/2019/01/04/an-update-on-the-bundler-2-release.html
#
# Traceback (most recent call last):
#         2: from /home/james/.rbenv/versions/2.5.3/bin/bundle:23:in `<main>'
#         1: from /home/james/.rbenv/versions/2.5.3/lib/ruby/2.5.0/rubygems.rb:308:in `activate_bin_path'
# /home/james/.rbenv/versions/2.5.3/lib/ruby/2.5.0/rubygems.rb:289:in `find_spec_for_exe': can't find gem bundler (>= 0.a) with executable bundle (Gem::GemNotFoundException)
< Gemfile.lock grep -A 1 "BUNDLED WITH"
echo "Run gem install bundler -v '...' if bundle fails"

bundle

gem ctags # index every rubygem installed on the system. Will run automatically after the first time

istats scan # set up all istats sensors
