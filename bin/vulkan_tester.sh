#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
BOLD=$(tput bold)
RESET=$(tput sgr0)
VULKANINFO64=$(command -v vulkaninfo)
VULKANINFO32=$(command -v vulkaninfo32 || command -v /usr/bin/vulkaninfo32)

#sudo mkdir -p /usr/share/vulkan/registry/backup 
#sudo mv /usr/share/vulkan/registry/* /usr/share/vulkan/registry/backup/ 2>/dev/null
sudo pacman -S vulkan-headers --noconfirm --overwrite '*'
yay -S --noconfirm lib32-vulkan-tools
sudo pacman -S --noconfirm vulkan-tools

if [[ -z "$VULKANINFO64" ]]; then
    echo "${RED}64-bit vulkaninfo not found. ${RESET}"
    exit 1
fi
if [[ -z "$VULKANINFO32" ]]; then
    echo "${YELLOW}32-bit vulkaninfo not found. ${RESET}"
fi
for icd in /usr/share/vulkan/icd.d/*.json; do
    echo "${BLUE}Testing ICD:${RESET} ${MAGENTA}${BOLD}$icd ${RESET}"
    if [[ "$icd" == *i686* ]]; then
        if [[ -z "$VULKANINFO32" ]]; then
            echo "${YELLOW}vulkaninfo32 not found. ${RESET}"
            echo
            continue
        fi
        cmd="$VULKANINFO32"
        arch="32-bit"
    else
        cmd="$VULKANINFO64"
        arch="64-bit"
    fi
    VK_ICD_FILENAMES="$icd" "$cmd" >/dev/null 2>&1
    ret=$?
    if [[ $ret -eq 0 ]]; then
        echo "${BOLD}${GREEN}Success! ${arch} ICD is working.${RESET}"
    else
        echo "${BOLD}${RED}${arch} ICD could not initialize.${RESET}"
    fi
    echo
done
