#!/bin/bash
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

VULKANINFO64=$(command -v vulkaninfo || command -v /usr/bin/vulkaninfo)
VULKANINFO32=$(command -v vulkaninfo32 || command -v /usr/bin/vulkaninfo32)

sudo pacman -S vulkan-headers --noconfirm --overwrite '*' 2>/dev/null
yay -S --noconfirm lib32-vulkan-tools 2>/dev/null
sudo pacman -S --noconfirm vulkan-tools 2>/dev/null
sudo pacman -S --noconfirm libva-utils 2>/dev/null
sudo apt update 2>/dev/null
sudo apt install mesa-utils -y 2>/dev/null
sudo apt install vulkan-tools -y 2>/dev/null
sudo apt install vainfo -y 2>/dev/null

echo
echo
echo "${BOLD}${RED}< < < Vulkan > > >${RESET}"
echo

if [[ -z "$VULKANINFO64" ]]; then
    echo "${RED}64-bit vulkaninfo not found. ${RESET}"
    sleep 5
    exit 1
fi

for icd in /usr/share/vulkan/icd.d/*.json; do
    if [[ "$icd" == *i686* ]]; then
        cmd="$VULKANINFO32"
        arch="32-bit"
    else
        cmd="$VULKANINFO64"
        arch="64-bit"
    fi
    VK_ICD_FILENAMES="$icd" "$cmd" >/dev/null 2>&1
    ret=$?
    if [[ $ret -eq 0 ]]; then
        echo "${RED}$icd ${BOLD}[ON]${RESET}"
    else
        echo "${BLUE}$icd ${BOLD}[OFF]${RESET}"
    fi
done

sleep 1
echo
echo "${RESET}"
echo "${BOLD}${CYAN}< < < EGL > > >${BOLD}"
echo

if command -v eglinfo >/dev/null 2>&1; then
    eglinfo 2>/dev/null | grep -E \
        "EGL vendor string|EGL driver name|OpenGL renderer string|OpenGL core profile renderer"
else
    echo
    echo "${YELLOW}eglinfo not found.${RESET}"
    echo
fi

sleep 1
echo
echo
echo "${RESET}"
echo "${BOLD}${MAGENTA}< < < GLX > > > ${BOLD}"
echo

if command -v glxinfo >/dev/null 2>&1; then
    glxinfo -B 2>/dev/null | grep -E \
        "OpenGL vendor string|OpenGL renderer string|OpenGL core profile renderer string|OpenGL version string"
else
    echo
    echo "${YELLOW}glxinfo not found.${RESET}"
    echo
fi

sleep 1
echo
echo
echo "${RESET}"
echo "${BOLD}${GREEN}< < < VA-API > > > ${BOLD}"
echo

if command -v vainfo >/dev/null 2>&1; then
    vainfo 2>/dev/null | grep -E \
        "VA-API version:|Driver version:|Supported profile and entrypoints"
else
    echo
    echo "${YELLOW}vainfo not found.${RESET}"
    echo
fi

echo "${RESET}"
