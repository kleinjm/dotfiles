#!/bin/bash

# get the os version, either mac or linux. Ie. -o mac
while getopts o: option
do
 case "${option}"
 in
 o) OS=${OPTARG};;
 esac
done

if [ $OS = 'mac' ]; then
  echo 'Installing dependencies for mac...'

  # accept xcode agreement
  sudo xcodebuild -license accept
  xcode-select --install

  brew install macvim --with-override-system-vim
  brew install reattach-to-user-namespace
elif [ $OS = 'linux' ]; then
  echo 'Installing dependencies for linux...'

  # linuxbrew
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
  test -d ~/.linuxbrew && PATH="$HOME/.linuxbrew/bin:$HOME/.linuxbrew/sbin:$PATH"
  test -d /home/linuxbrew/.linuxbrew && PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
  test -r ~/.bash_profile && echo "export PATH='$(brew --prefix)/bin:$(brew --prefix)/sbin'":'"$PATH"' >>~/.bash_profile
  echo "export PATH='$(brew --prefix)/bin:$(brew --prefix)/sbin'":'"$PATH"' >>~/.profile
else
  echo 'Please enter a valid os name with option -o'
fi

brew install bash
brew install fzf
brew install gpg                                # for github verified commits
brew install heroku
brew install rbenv
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
# get the latest version with "node"
nvm install node
npm install -g sass-lint
npm install -g coffeelint
