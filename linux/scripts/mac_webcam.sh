#!/bin/bash

set -e
set -o pipefail

cd "$PROJECT_DIR"
if [ ! -d "$PROJECT_DIR"/bcwc_pcie ]; then
  git clone https://github.com/patjak/bcwc_pcie.git
fi

cd bcwc_pcie
git checkout mainline
cd firmware
make
sudo make install
cd ..
make
sudo make install
sudo depmod
sudo modprobe -r bdc_pci
sudo modprobe facetimehd
