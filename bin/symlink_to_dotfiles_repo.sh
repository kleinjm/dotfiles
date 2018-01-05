#!/bin/bash
rm -r ~/.tmuxinator
rm ~/.gitconfig
rm ~/.gitignore_global
rm -f ~/.nvmrc # don't fail if file doesn't exist
rm ~/.pryrc
rm ~/.ssh/config
rm ~/.tmux.conf
rm ~/.vimrc
rm ~/.zshrc

ln -s ~/GitHubRepos/dotfiles/gitconfig ~/.gitconfig
ln -s ~/GitHubRepos/dotfiles/gitignore_global ~/.gitignore_global
ln -s ~/GitHubRepos/dotfiles/nvmrc ~/.nvmrc
ln -s ~/GitHubRepos/dotfiles/pryrc ~/.pryrc
ln -s ~/GitHubRepos/dotfiles/ssh_config ~/.ssh/config
ln -s ~/GitHubRepos/dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/GitHubRepos/dotfiles/tmuxinator ~/.tmuxinator
ln -s ~/GitHubRepos/dotfiles/vimrc ~/.vimrc
ln -s ~/GitHubRepos/dotfiles/zshrc ~/.zshrc
