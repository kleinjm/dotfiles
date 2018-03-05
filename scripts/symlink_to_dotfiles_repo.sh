#!/bin/bash

platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='mac'
fi

rm -f ~/.nvmrc # don't fail if file doesn't exist
rm -f ~/.vim/functions.vim
rm -f ~/.vim/lightline.vim
rm -f ~/.vim/plugins.vim
rm -r ~/.tmuxinator
rm ~/.gitconfig
rm ~/.gitignore_global
rm ~/.pryrc
rm ~/.ssh/config
rm ~/.tmux.conf
rm ~/.vimrc
rm ~/.zshrc

ln -s `pwd`/gitconfig ~/.gitconfig
ln -s `pwd`/gitignore_global ~/.gitignore_global
ln -s `pwd`/nvmrc ~/.nvmrc
ln -s `pwd`/pryrc ~/.pryrc

if [ $platform = 'mac' ]; then
  ln -s `pwd`/ssh_config_mac ~/.ssh/config
elif [ $platform = 'linux' ]; then
  ln -s `pwd`/ssh_config_linux ~/.ssh/config
fi

ln -s `pwd`/tmux.conf ~/.tmux.conf
ln -s `pwd`/tmuxinator ~/.tmuxinator
ln -s `pwd`/vim/functions.vim ~/.vim/functions.vim
ln -s `pwd`/vim/lightline.vim ~/.vim/lightline.vim
ln -s `pwd`/vim/plugins.vim ~/.vim/plugins.vim
ln -s `pwd`/vim/vimrc ~/.vimrc
ln -s `pwd`/zshrc ~/.zshrc
