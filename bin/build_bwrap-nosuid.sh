#!/usr/bin/env bash
set -euo pipefail

cd /tmp
sudo rm -rf /tmp/bubblewrap /tmp/bubblewrap-build /usr/local/bwrap-nosuid/bin/ 2>/dev/null
git clone https://github.com/containers/bubblewrap.git /tmp/bubblewrap
sudo mkdir -p /usr/local/bwrap-nosuid/bin/
cd /tmp/bubblewrap
git checkout --detach "$(git tag -l 'v*' --sort=-v:refname | head -n1)"

meson setup /tmp/bubblewrap-build /tmp/bubblewrap \
    --buildtype=release \
    -Dsupport_setuid=false \
    -Drequire_userns=false \
    -Dtests=false \
    -Dman=disabled \
    -Dbash_completion=disabled \
    -Dzsh_completion=disabled

ninja -C /tmp/bubblewrap-build

sudo rm -f "/$CHARD_HOME/bwrap-nosuid" 2>/dev/null
sudo install -o 1000 -g 1000 -m 0755 /tmp/bubblewrap-build/bwrap "/usr/local/bwrap-nosuid/bin/bwrap"
cd
sudo rm -rf /tmp/bubblewrap /tmp/bubblewrap-build
