#!/bin/sh

set -e
set -o pipefail

echo "***Installing Bundler and Gems***"

# TODO: may need to check if rbenv ruby version is installed here
gem install bundler # if this command fails, run `rbenv init`

# If bundler is broken and you're seeing this trace, see this link
# https://bundler.io/blog/2019/01/04/an-update-on-the-bundler-2-release.html
#
# Traceback (most recent call last):
#         2: from /home/james/.rbenv/versions/2.5.3/bin/bundle:23:in `<main>'
#         1: from /home/james/.rbenv/versions/2.5.3/lib/ruby/2.5.0/rubygems.rb:308:in `activate_bin_path'
# /home/james/.rbenv/versions/2.5.3/lib/ruby/2.5.0/rubygems.rb:289:in `find_spec_for_exe': can't find gem bundler (>= 0.a) with executable bundle (Gem::GemNotFoundException)
bundle

gem ctags # index every rubygem installed on the system. Will run automatically after the first time
