#!/bin/sh

set -e
set -o pipefail

# stow
# v = verbose, t = target directory
stow -v -t ~/ vim
stow -v -t ~/ git

# TODO: move the rest of dotfiles to stow

# -r option = don't fail if file doesn't exist
rm -f ~/.bundle/config
rm -f ~/.nvmrc
rm -f ~/.pryrc
rm -f ~/.psqlrc
rm -f ~/.pyenv/version
rm -f ~/.rbenv/version
rm -f ~/.tmux.conf
rm -f ~/.tmux.conf.local
rm -f ~/.zshenv
rm -f ~/.zshrc
rm -rf ~/.docker
rm -rf ~/.oh-my-zsh/custom/plugins
rm -rf ~/.oh-my-zsh/themes # this may get in the way of pulling updates
rm -rf ~/.rbenv/plugins
rm -rf ~/.tmuxinator
rm -rf ~/.vmail
rm -rf ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Default\ \(OSX\).sublime-keymap
sudo rm -f ~/.ssh/config

ln -s $DROPBOX_DIR/EnvironmentConfigurations/bundle/config ~/.bundle/config
ln -s $DROPBOX_DIR/EnvironmentConfigurations/vmail ~/.vmail
ln -s `pwd`/Default\ \(OSX\).sublime-keymap ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Default\ \(OSX\).sublime-keymap
ln -s `pwd`/docker ~/.docker
ln -s `pwd`/mac/psqlrc ~/.psqlrc
ln -s `pwd`/mac/pyenv/version ~/.pyenv/version
ln -s `pwd`/mac/rbenv/plugins ~/.rbenv/plugins
ln -s `pwd`/mac/rbenv/version ~/.rbenv/version
ln -s `pwd`/mac/zsh/plugins ~/.oh-my-zsh/custom/plugins
ln -s `pwd`/mac/zsh/themes ~/.oh-my-zsh/themes # this should be the custom folder
ln -s `pwd`/mac/zsh/zshenv ~/.zshenv
ln -s `pwd`/mac/zsh/zshrc ~/.zshrc
ln -s `pwd`/nvmrc ~/.nvmrc
ln -s `pwd`/pryrc.rb ~/.pryrc
ln -s `pwd`/tmux.conf ~/.tmux.conf
ln -s `pwd`/tmux.local.conf ~/.tmux.conf.local
ln -s `pwd`/tmuxinator ~/.tmuxinator

sudo ln -s $DROPBOX_DIR/EnvironmentConfigurations/ssh_config_mac ~/.ssh/config

# May need to update permissions
# chmod -R 0755 ~/.git/git_template/hooks

# Hidden files on Mac. Requires: hold 'alt' key, right click Finder, Relaunch
defaults write com.apple.finder AppleShowAllFiles YES
