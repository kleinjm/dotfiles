#!/bin/bash

set -e
set -o pipefail

echo "***Installing apt-get packages***"

# WARNING: Do not try to use `apt-clone`
# It seems to work fine on the same computer but because there are drivers
# involved in the backup, they do not work between computers.

sudo apt-add-repository ppa:rodsmith/refind
# For ukuu kernel tool
# https://www.omgubuntu.co.uk/2017/02/ukuu-easy-way-to-install-mainline-kernel-ubuntu
sudo add-apt-repository ppa:teejee2008/ppa

# for albert
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_18.04/ /' > /etc/apt/sources.list.d/home:manuelschneid3r.list"

sudo apt-get update

# Ensure packages added here are not part of the brew bundle
sudo apt install vim-gtk curl zsh ksshaskpass gnome-tweak-tool refind \
  libffi-dev xclip albert ukuu copyq

# dropbox - https://www.dropbox.com/install-linux
cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -

sudo curl -L -o /usr/local/bin/aws-vault https://github.com/99designs/aws-vault/releases/download/v4.2.0/aws-vault-linux-amd64
sudo chmod 755 /usr/local/bin/aws-vault

echo "Start dropbox with ~/.dropbox-dist/dropboxd"
