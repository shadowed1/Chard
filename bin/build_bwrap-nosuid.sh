#!/usr/bin/env bash
# Created by Days
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

FLATPAK_VERSION="$(git ls-remote --tags https://github.com/flatpak/flatpak.git \
    | awk -F/ '/refs\/tags\/[0-9]+\.[0-9]+\.[0-9]+$/ {print $3}' \
    | sort -V \
    | tail -n1)"

if [ -z "$FLATPAK_VERSION" ]; then
    echo "Failed to determine latest Flatpak version"
    exit 1
fi

TMP_TARBALL="/tmp/flatpak-${FLATPAK_VERSION}.tar.gz"
curl -L "https://giR=$CHARD_ROOT
FLATPAK_VERSION="$(git ls-remote --tags https://github.com/flatpak/flatpak.git \
    | awk -F/ '/refs\/tags\/[0-9]+\.[0-9]+\.[0-9]+$/ {print $3}' \
    | sort -V \
    | tail -n1)"

if [ -z "$FLATPAK_VERSION" ]; then
    echo "Failed to determine latest Flatpak version"
    exit 1
fi

TMP_TARBALL="/tmp/flatpak-${FLATPAK_VERSION}.tar.gz"
curl -L "https://github.com/flatpak/flatpak/archive/refs/tags/${FLATPAK_VERSION}.tar.gz" \
    -o "$TMP_TARBALL"

sudo tar -xzf "$TMP_TARBALL" -C /usr/local/
FLATPAK_ROOT="/usr/local/flatpak-${FLATPAK_VERSION}"
echo
echo "${GREEN}Using Flatpak source at: ${BOLD}$FLATPAK_ROOT ${RESET}"sudo true
echothub.com/flatpak/flatpak/archive/refs/tags/${FLATPAK_VERSION}.tar.gz" \
    -o "$TMP_TARBALL"

sudo tar -xzf "$TMP_TARBALL" -C /usr/local/
FLATPAK_ROOT="/usr/local/flatpak-${FLATPAK_VERSION}"
echo
echo "${GREEN}Using Flatpak version at: ${BOLD}$FLATPAK_ROOT ${RESET}"
echo
echo "$FLATPAK_VERSION" | sudo tee /.chard_flatpak >/dev/null

