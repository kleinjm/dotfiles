#!/bin/sh

set -e
set -o pipefail

# -r option = don't fail if file doesn't exist
rm -f ~/.bundle/config
rm -f ~/.gitconfig
rm -f ~/.gitignore_global
rm -f ~/.nvmrc
rm -f ~/.pryrc
rm -f ~/.psqlrc
rm -f ~/.pyenv/version
rm -f ~/.rbenv/version
rm -f ~/.tmux.conf
rm -f ~/.tmux.conf.local
rm -f ~/.vim/functions.vim
rm -f ~/.vim/lightline.vim
rm -f ~/.vim/plugins.vim
rm -f ~/.vimrc
rm -f ~/.zshenv
rm -f ~/.zshrc
rm -rf ~/.docker
rm -rf ~/.git_template
rm -rf ~/.oh-my-zsh/custom/plugins
rm -rf ~/.oh-my-zsh/themes # this may get in the way of pulling updates
rm -rf ~/.rbenv/plugins
rm -rf ~/.tmuxinator
rm -rf ~/.vim/UltiSnips
rm -rf ~/.vim/after/plugin # may need to add `mkdir -p ~/.vim/after/plugin`
rm -rf ~/.vim/autoload/templates.vim
rm -rf ~/.vim/ftplugin
rm -rf ~/.vim/pythonx
rm -rf ~/.vmail
rm -rf ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Default\ \(OSX\).sublime-keymap
sudo rm -f ~/.ssh/config

ln -s $DROPBOX_DIR/EnvironmentConfigurations/bundle/config ~/.bundle/config
ln -s $DROPBOX_DIR/EnvironmentConfigurations/vmail ~/.vmail
ln -s `pwd`/Default\ \(OSX\).sublime-keymap ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Default\ \(OSX\).sublime-keymap
ln -s `pwd`/docker ~/.docker
ln -s `pwd`/gitconfig ~/.gitconfig
ln -s `pwd`/gitignore_global ~/.gitignore_global
ln -s `pwd`/mac/git/git_template ~/.git_template
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
ln -s `pwd`/vim/UltiSnips ~/.vim/UltiSnips
ln -s `pwd`/vim/after/plugin ~/.vim/after/plugin
ln -s `pwd`/vim/autoload/templates.vim ~/.vim/autoload/templates.vim
ln -s `pwd`/vim/ftplugin ~/.vim/ftplugin
ln -s `pwd`/vim/functions.vim ~/.vim/functions.vim
ln -s `pwd`/vim/lightline.vim ~/.vim/lightline.vim
ln -s `pwd`/vim/plugins.vim ~/.vim/plugins.vim
ln -s `pwd`/vim/pythonx ~/.vim/pythonx
ln -s `pwd`/vim/vimrc ~/.vimrc

sudo ln -s `pwd`/ssh_config_mac ~/.ssh/config

# update permissions
chmod -R 0755 `pwd`/mac/git/git_template/hooks

# Hidden files on Mac. Requires: hold 'alt' key, right click Finder, Relaunch
defaults write com.apple.finder AppleShowAllFiles YES
