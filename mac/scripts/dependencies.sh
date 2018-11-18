#!/bin/sh

# NOTE: Everything in here is order dependent

set -e
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# accept xcode agreement
sudo xcodebuild -license accept
xcode-select --install || true

# homebrew
which brew
if [ $? != 0 ]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  mkdir -p /usr/local/include
  sudo chmod 777 /usr/local
fi

$DIR/dependencies/python.sh

## Brew
# run `brew bundle dump` to update the Brewfile
#
### Taps
# divoxx/brewery - muggler
#
### Brews
# macvim - NOTE: **You must open the XCode app and click install when prompted**
# gpg for github verified commits
# tree for `tree` command for dir structure
# muggler - run rails migrations when switching branches.
#   Run `muggler install` in each repo. See https://github.com/divoxx/muggler
# ffmpeg - dependency for youtube-dl
# sqlite3 and w3m - dependencies of vmail
# awscli - for doximity
# graphviz - for rails-erd and other .svg generation tools
# git-lfs parallel jq gawk - dox-compose dependencies
# tmux is required for oh-my-zsh to source it's plugin correctly
#
### Casks
# font related casks - Needed for nerd fonts and devicons
# https://github.com/ryanoasis/nerd-fonts#option-3-install-script
# corelocationcli - alfred google maps workflow
# insomnia - OOS rest client
# keybase - for doximity AWS keys https://wiki.doximity.com/articles/keybase
# mysql - for doximity. Do not install 8.x.x
brew bundle

# oh-my-zsh
ls ~/.oh-my-zsh
if [ $? != 0 ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  sudo chmod -R 777 $ZSH # ohmyzsh plugins
fi

until
  rbenv ctags
  [ "$?" -ne 127  ]
do
  mkdir -p ~/.rbenv/plugins
  git clone git://github.com/tpope/rbenv-ctags.git \
    ~/.rbenv/plugins/rbenv-ctags
  rbenv ctags # see https://github.com/tpope/rbenv-ctags
done

# ruby
gem install bundler # if this command fails, run `rbenv init`
bundle
gem ctags # index every rubygem installed on the system. Will run automatically after the first time

# zsh-autosuggestions on develop branch
ls ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
if [ $? != 0 ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi
cd $ZSH_CUSTOM/plugins/zsh-autosuggestions
git checkout develop
cd $DOTFILES_DIR

# tpm = tmux plugin manager
ls ~/.tmux/plugins/tpm/tpm
if [ $? != 0 ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# nvm and npm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

# TODO: sourcing fails and then nvm fails
# get the latest version with "node"
source ~/.zshrc
nvm install node
nvm use
npm install -g sass-lint coffeelint coffeelint-prefer-double-quotes
