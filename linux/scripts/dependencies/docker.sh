#!/bin/bash

set -e
set -o pipefail

echo "***Installing docker and dependencies***"

# Docker - https://docs.docker.com/install/linux/docker-ce/ubuntu/
sudo apt-get update

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get install docker-ce

# Solve a permissions isssue
# https://techoverflow.net/2017/03/01/solving-docker-permission-denied-while-trying-to-connect-to-the-docker-daemon-socket/
# NOTE: requires a restart
sudo usermod -a -G docker $USER

echo "***Docker installed - Please Restart***"
