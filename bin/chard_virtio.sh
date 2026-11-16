#!/bin/bash
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

echo

ARCH="$(uname -m)"
if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    . /etc/os-release 2>/dev/null
    DISTRO="${ID:-unknown}"
    DISTRO_LIKE="${ID_LIKE:-}"
    DISTRO="${DISTRO,,}"
    DISTRO_LIKE="${DISTRO_LIKE,,}"

    if [[ "$DISTRO" == "arch" || "$DISTRO_LIKE" == *arch* ]]; then
        echo
        echo "${GREEN}Chard Arch $ARCH Found! ${RESET}"
        sudo pacman -Syy
        sudo pacman -Fyy
        sudo pacman -S --noconfirm --needed patchelf 2>/dev/null
        sudo pacman -S --noconfirm --needed vulkan-icd-loader 2>/dev/null
        sudo pacman -S --noconfirm --needed vulkan-tools 2>/dev/null
        sudo pacman -S --noconfirm --needed mesa-utils 2>/dev/null
        sudo pacman -S --noconfirm --needed strace 2>/dev/null
        sudo pacman -S --noconfirm --needed binutils 2>/dev/null
        sudo pacman -S --noconfirm --needed wayland 2>/dev/null
        sudo pacman -S --noconfirm --needed libdrm 2>/dev/null
        sudo pacman -S --noconfirm --needed mesa 2>/dev/null
        sudo pacman -S --noconfirm --needed vulkan-virtio 2>/dev/null
        sudo pacman -S --noconfirm --needed vulkan-icd-loader 2>/dev/null
        sudo pacman -S --noconfirm --needed vulkan-tools 2>/dev/null
        sudo pacman -S --noconfirm --needed mesa-utils 2>/dev/null
        LIB=$(find /opt/libmali -maxdepth 1 -type f -name 'libmali.so.0*' ! -name '*.orig' | head -n 1)
        sudo patchelf --remove-needed libc.so.6 "$LIB"
        sudo readelf -d "$LIB" | grep -E 'NEEDED|RELR'
        ldd "$LIB"
    elif [[ "$DISTRO" == "gentoo" || "$DISTRO_LIKE" == *gentoo* ]]; then
        echo
        echo "${GREEN}Chard Gentoo $ARCH Found ${RESET}"
        echo
        LAST_SYNC=$(sudo emerge --info | sed -n 's/^Timestamp of repository gentoo: //p')
        
        if [[ -z "$LAST_SYNC" ]]; then
            echo "Could not retrieve Gentoo sync timestamp"
        fi
        
        LAST_SYNC_EPOCH=$(date -d "$LAST_SYNC" +%s) || exit 1
        NOW_EPOCH=$(date +%s)
        
        if (( NOW_EPOCH - LAST_SYNC_EPOCH > 30 * 86400 )); then
            echo "${YELLOW}Last sync was more than 30 days ago. Syncing... ${RESET}"
            sudo emerge --sync
        else
            echo "${GREEN}Repository sync is recent: ${BOLD}$LAST_SYNC ${RESET}"
        fi
        sudo emerge --noreplace dev-util/patchelf 2>/dev/null
        sudo emerge --noreplace media-libs/vulkan-loader 2>/dev/null
        sudo emerge --noreplace dev-util/vulkan-tools 2>/dev/null
        sudo emerge --noreplace x11-apps/mesa-progs 2>/dev/null
        sudo emerge --noreplace dev-debug/strace 2>/dev/null
        sudo emerge --noreplace sys-devel/binutils 2>/dev/null
        sudo emerge --noreplace dev-libs/wayland 2>/dev/null
        sudo emerge --noreplace x11-libs/libdrm 2>/dev/null
        sudo emerge --noreplace media-libs/mesa 2>/dev/null
        LIB=$(find /opt/libmali -maxdepth 1 -type f -name 'libmali.so.0*' ! -name '*.orig' | head -n 1)
        sudo patchelf --remove-needed libc.so.6 "$LIB"
        sudo readelf -d "$LIB" | grep -E 'NEEDED|RELR'
        ldd "$LIB"
    else
        echo
        echo "${RED}Unsupported distro: $DISTRO ${RESET}"
    fi

else
    echo
    echo "${BLUE}Not ARM64 system ($ARCH), skipping. ${RESET}"
fi

echo
