#!/bin/bash
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'
sudo -E emerge sys-fs/fuse:0 2>/dev/null
cd
curl -L -o bindfs-1.18.4.tar.gz "https://bindfs.org/downloads/bindfs-1.18.4.tar.gz"
tar xzf bindfs-1.18.4.tar.gz
cd bindfs-1.18.4
./configure --with-fuse2 --prefix=/usr/
make -j$(nproc)
sudo make install
cd
rm -rf bindfs-1.18.4 2>/dev/null
