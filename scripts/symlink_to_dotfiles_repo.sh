#!/bin/sh

set -e
set -o pipefail

platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='mac'
fi

# -r option = don't fail if file doesn't exist
rm -f ~/.gitconfig
rm -f ~/.gitignore_global
rm -f ~/.nvmrc
rm -f ~/.pryrc
rm -f ~/.ssh/config
rm -f ~/.tmux.conf
rm -f ~/.tmux.conf.local
rm -f ~/.vim/functions.vim
rm -f ~/.vim/lightline.vim
rm -f ~/.vim/plugins.vim
rm -f ~/.vimrc
rm -f ~/.zshrc
rm -f ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Default\ \(OSX\).sublime-keymap
rm -rf ~/.tmuxinator

ln -s `pwd`/Default\ \(OSX\).sublime-keymap ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Default\ \(OSX\).sublime-keymap
ln -s `pwd`/gitconfig ~/.gitconfig
ln -s `pwd`/gitignore_global ~/.gitignore_global
ln -s `pwd`/mac/git/git_template ~/.git_template
ln -s `pwd`/mac/rbenv/plugins ~/.rbenv/plugins
ln -s `pwd`/nvmrc ~/.nvmrc
ln -s `pwd`/pryrc.rb ~/.pryrc
ln -s `pwd`/tmux.conf ~/.tmux.conf
ln -s `pwd`/tmux.local.conf ~/.tmux.conf.local
ln -s `pwd`/tmuxinator ~/.tmuxinator
ln -s `pwd`/vim/functions.vim ~/.vim/functions.vim
ln -s `pwd`/vim/lightline.vim ~/.vim/lightline.vim
ln -s `pwd`/vim/plugins.vim ~/.vim/plugins.vim
ln -s `pwd`/vim/vimrc ~/.vimrc
ln -s `pwd`/zshrc ~/.zshrc

if [ $platform = 'mac' ]; then
  ln -s `pwd`/ssh_config_mac ~/.ssh/config
elif [ $platform = 'linux' ]; then
  ln -s `pwd`/ssh_config_linux ~/.ssh/config
fi

chmod -R 0755 `pwd`/mac/git/git_template/hooks
