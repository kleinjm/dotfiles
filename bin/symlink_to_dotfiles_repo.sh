#!/bin/bash
rm -f ~/.nvmrc # don't fail if file doesn't exist
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
ln -s `pwd`/ssh_config ~/.ssh/config
ln -s `pwd`/tmux.conf ~/.tmux.conf
ln -s `pwd`/tmuxinator ~/.tmuxinator
ln -s `pwd`/vimrc ~/.vimrc
ln -s `pwd`/zshrc ~/.zshrc
