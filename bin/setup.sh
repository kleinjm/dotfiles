#!/bin/bash
rm ~/.vimrc
rm ~/.tmux.conf
rm ~/.gitconfig
rm ~/.gitignore_global
rm ~/.zshrc
rm ~/.pryrc
rm ~/.ssh/config

ln -s ~/GitHubRepos/dotfiles/vimrc ~/.vimrc
ln -s ~/GitHubRepos/dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/GitHubRepos/dotfiles/gitconfig ~/.gitconfig
ln -s ~/GitHubRepos/dotfiles/gitignore_global ~/.gitignore_global
ln -s ~/GitHubRepos/dotfiles/zshrc ~/.zshrc
ln -s ~/GitHubRepos/dotfiles/pryrc ~/.pryrc
ln -s ~/GitHubRepos/dotfiles/ssh_config ~/.ssh/config
