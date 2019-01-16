#!/bin/bash

set -e
set -o pipefail

cd $PROJECT_DIR
git clone https://github.com/patjak/bcwc_pcie.git
git checkout mainline
cd bcwc_pcie/firmware
make
sudo make install
cd ..
make
sudo make install
sudo depmod
sudo modprobe -r bdc_pci
sudo modprobe facetimehd
