#!/usr/bin/env sh

sudo rmmod hid_magicmouse
sudo modprobe hid_magicmouse emulate_3button=0 scroll_acceleration=1 scroll_speed=45
