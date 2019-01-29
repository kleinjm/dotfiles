#!/bin/bash

set -e
set -o pipefail

read -p "Have you read the README to ensure you have the correct kernel installed? [Y/n] " -n 1 -r
echo
if [[ ! "$REPLY" =~ ^[Yy]$ ]]
then
  echo "Exiting"
  exit 0
fi

if uname -a | grep "4.20"; then
  echo "Correct kernel installed. Continuing"
else
  echo "Cannot find correct kernel version. See Readme - Exiting"
  exit 1
fi

REPO_DIR="$PROJECT_DIR"/Linux-Magic-Trackpad-2-Driver
if [ -e "$REPO_DIR" ]; then
  echo "Repo already exists. Ensure driver is properly installed"
else
  # See https://github.com/rohitpid/Linux-Magic-Trackpad-2-Driver#installation-with-dkms
  sudo apt install dkms
  git clone https://github.com/rohitpid/Linux-Magic-Trackpad-2-Driver.git "$REPO_DIR"
  cd "$PROJECT_DIR"/Linux-Magic-Trackpad-2-Driver/scripts
  chmod u+x install.sh
  sudo ./install.sh

  cd "$PROJECT_DIR"/Linux-Magic-Trackpad-2-Driver/linux/drivers/hid
  make clean
  make
  sudo rmmod hid-magicmouse
  sudo insmod ./hid-magicmouse.ko
fi

# See Automatic Set Up
# http://sneclacson.blogspot.com/2016/09/using-apple-magic-mouse-with-ubuntu-1604.html
KERNEL_FILE=/etc/modprobe.d/magicmouse.conf
if [ -e $KERNEL_FILE ]; then
  echo "Kernel module already exist"
else
  echo "options hid_magicmouse emulate_3button=0 scroll_acceleration=1 scroll_speed=45" | sudo tee $KERNEL_FILE
fi

DRIVER_SETTINGS=/usr/share/X11/xorg.conf.d/50-magicmouse.conf
if [ -e "$DRIVER_SETTINGS" ]; then
  echo "Driver settings already exist"
else
  sudo cp "$DOTFILES_DIR"/linux/config/50-magicmouse.conf "$DRIVER_SETTINGS"
fi
