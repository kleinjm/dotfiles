#!/bin/bash

# brew
brew install fzf
brew install the_silver_searcher
brew install macvim --with-override-system-vim
brew install thefuck
brew install rbenv
brew install reattach-to-user-namespace
brew install bash
brew install heroku

# used for CLI activity monitor
pip install glances

# Needed for nerd fonts and devicons
# https://github.com/ryanoasis/nerd-fonts#option-3-install-script
brew tap caskroom/fonts
brew cask install font-hack-nerd-font
brew cask install font-devicons

# ruby
gem install bundler
cd ${PWD}/bin
bundle
