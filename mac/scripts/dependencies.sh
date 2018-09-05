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
# NOTE: keep this before `source ~/.zshrc`
brew list | grep tmux
if [ $? != 0 ]; then
  brew install tmux
fi

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

# divoxx/brewery - muggler
brew tap divoxx/brewery caskroom/fonts

# gpg for github verified commits
# tree for `tree` command for dir structure
# muggler - run rails migrations when switching branches.
#   Run `muggler install` in each repo. See https://github.com/divoxx/muggler
# ffmpeg - dependency for youtube-dl
# sqlite3 and w3m - dependencies of vmail
brew install bash fzf ripgrep the_silver_searcher tree gpg heroku youtube-dl \
  yarn reattach-to-user-namespace muggler rbenv ctags sqlite3 w3m

until
  rbenv ctags
  [ "$?" -ne 127  ]
do
  mkdir -p ~/.rbenv/plugins
  git clone git://github.com/tpope/rbenv-ctags.git \
    ~/.rbenv/plugins/rbenv-ctags
  rbenv ctags # see https://github.com/tpope/rbenv-ctags
done

# Aliased to `speed` in zshrc
pip3 install speedtest-cli

# font related casks - Needed for nerd fonts and devicons
# https://github.com/ryanoasis/nerd-fonts#option-3-install-script
# corelocationcli - alfred google maps workflow
# insomnia - OOS rest client
# keybase - for doximity AWS keys https://wiki.doximity.com/articles/keybase
brew cask install font-hack-nerd-font font-devicons corelocationcli insomnia \
  keybase

# ruby
gem install bundler # if this command fails, run `rbenv init`
bundle
gem ctags # index every rubygem installed on the system. Will run automatically after the first time

# nvm and npm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
# TODO: handle error code 3 here

# get the latest version with "node"
nvm install node
npm install -g sass-lint coffeelint coffeelint-prefer-double-quotes

# zsh-autosuggestions on develop branch
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
cd $ZSH_CUSTOM/plugins/zsh-autosuggestions
git checkout develop
