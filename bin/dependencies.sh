#!/bin/bash

# accept xcode agreement
sudo xcodebuild -license accept
xcode-select --install

# brew
brew install bash
brew install fzf
brew install gpg                                # for github verified commits
brew install heroku
brew install macvim --with-override-system-vim
brew install rbenv
brew install reattach-to-user-namespace
brew install the_silver_searcher
brew install thefuck

# make sure python is installed so we have pip
brew install python3
# Aliased to `speed` in zshrc
pip3 install speedtest-cli

# Needed for nerd fonts and devicons
# https://github.com/ryanoasis/nerd-fonts#option-3-install-script
brew tap caskroom/fonts
brew cask install font-hack-nerd-font
brew cask install font-devicons

# ruby
gem install bundler
cd ${PWD}/bin
bundle

# nvm and npm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
nvm install node
npm install -g sass-lint
npm install -g coffeelint
