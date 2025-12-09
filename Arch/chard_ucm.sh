#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

if [[ "$PS1" =~ @([^-]+)- ]]; then
    CHROME_CODENAME="${BASH_REMATCH[1]}"
else
    CHROME_CODENAME="unknown"
fi

ALSA_CARD=$(awk -F': ' '/sof-/ {n=split($2,a," "); print a[length(a)]; exit}' /proc/asound/cards)
echo
echo "${MAGENTA}$CHROME_CODENAME ${RESET}"
echo "${BLUE}${ALSA_CARD}${RESET}"

UCM1_ROOT="/usr/share/alsa/ucm"
UCM1_FOLDER=$(find "$UCM1_ROOT" -maxdepth 1 -type d -name "${ALSA_CARD}*" | grep "$CHROME_CODENAME" | head -n1)

if [[ -n "$UCM1_FOLDER" ]]; then
    echo
    echo "${CYAN}$UCM1_FOLDER ${RESET}"
fi
