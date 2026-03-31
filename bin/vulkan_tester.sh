#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

for icd in /usr/share/vulkan/icd.d/*.json; do
    echo ${BLUE}
    echo "Testing ICD: ${RESET}${MAGENTA}${BOLD}$icd"
    echo "${RESET}"
    sleep 1

    if [[ "$icd" == *i686* ]]; then
        if command -v vkcube >/dev/null; then
            cmd="vkcube"
        else
            echo "${YELLOW}Skipping (no vkcube32)${RESET}"
            echo ""
            continue
        fi
    else
        cmd="vkcube"
    fi

    VK_ICD_FILENAMES="$icd" $cmd >/dev/null 2>&1 &
    pid=$!

    sleep 2

    if kill -0 $pid 2>/dev/null; then
        kill $pid 2>/dev/null
        wait $pid 2>/dev/null
        echo "${BOLD}"
        echo "${GREEN}Success! ${RESET}"
        echo
    else
        echo
        echo "${RED}Could not start. ${RESET}"
        echo
    fi

    echo ""
done
