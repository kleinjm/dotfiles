#!/bin/sh

# NOTE: Everything in here is order dependent

set -e
set -o pipefail

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

# tmux is required for oh-my-zsh to source it's plugin correctly
brew install tmux

# make sure python is installed so we have pip
# NOTE: it's also a macvim dependency
pyenv versions | grep 3.6.5
if [ $? != 0 ]; then
  brew install pyenv
  source ~/.zshrc
  pyenv install 3.6.5
fi

# plugin to enable `pyenv install-latest`
git clone https://github.com/momo-lab/pyenv-install-latest.git "$(pyenv root)"/plugins/pyenv-install-latest
pyenv install-latest

# NOTE: **You must open the XCode app and click install when prompted**
brew install macvim --with-override-system-vim

# oh-my-zsh
ls ~/.oh-my-zsh
if [ $? != 0 ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  sudo chmod -R 777 $ZSH # ohmyzsh plugins
fi

brew cask install insomnia # OSS rest client

brew tap divoxx/brewery # for muggler

# gpg - github verified commits
# tree - `tree` command for dir structure
# muggler - run rails migrations when switching branches.
#   Run `muggler install` in each repo. See https://github.com/divoxx/muggler
# ffmpeg - dependency for youtube-dl
brew install bash fzf ripgrep the_silver_searcher tree gpg heroku youtube-dl yarn reattach-to-user-namespace muggler ffmpeg

brew install rbenv ctags
rbenv ctags
if [ $? != 0 ]; then
  mkdir -p ~/.rbenv/plugins
  git clone git://github.com/tpope/rbenv-ctags.git \
    ~/.rbenv/plugins/rbenv-ctags
  rbenv ctags # see https://github.com/tpope/rbenv-ctags
fi

brew cask install corelocationcli   # for alfred google maps workflow

# Aliased to `speed` in zshrc
pip3 install speedtest-cli

# Needed for nerd fonts and devicons
# https://github.com/ryanoasis/nerd-fonts#option-3-install-script
brew tap caskroom/fonts
brew cask install font-hack-nerd-font
brew cask install font-devicons

# ruby
gem install bundler # if this command fails, run `rbenv init`
bundle
gem ctags # index every rubygem installed on the system. Will run automatically after the first time

# nvm and npm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
source ~/.nvm/nvm.sh

# get the latest version with "node"
nvm install node
npm install -g sass-lint
npm install -g coffeelint
