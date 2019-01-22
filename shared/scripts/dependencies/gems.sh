#!/bin/sh

set -e
set -o pipefail

echo "***Installing Bundler and Gems***"

# TODO: may need to check if rbenv ruby version is installed here
gem install bundler # if this command fails, run `rbenv init`

# If bundler is broken see this link
# https://bundler.io/blog/2019/01/04/an-update-on-the-bundler-2-release.html
bundle

gem ctags # index every rubygem installed on the system. Will run automatically after the first time
