#!/usr/bin/env sh

# See http://sneclacson.blogspot.com/2016/09/using-apple-magic-mouse-with-ubuntu-1604.html
sudo rmmod hid_magicmouse
sudo modprobe hid_magicmouse emulate_3button=0 scroll_acceleration=1 scroll_speed=45
