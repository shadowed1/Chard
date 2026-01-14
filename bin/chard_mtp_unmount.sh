#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

STATE_FILE="$CHARD_ROOT/tmp/mtp_mount_state"
MOUNT_POINT="$CHARD_ROOT/$CHARD_HOME/mtp_devices"

if mountpoint -q "$MOUNT_POINT"; then
    sudo umount "$MOUNT_POINT" 2>/dev/null
fi

if [[ -f "$STATE_FILE" ]]; then
    while read -r DEV_PATH; do
        BASENAME=$(basename "$DEV_PATH")
        TARGET="$MOUNT_POINT/$BASENAME"

        if mountpoint -q "$TARGET"; then
            echo ""
            echo "${CYAN}Unmounting: ${BOLD}$TARGET${RESET}"
            echo
            sudo umount "$TARGET" 2>/dev/null || {
                echo
                echo "${RED}Failed to unmount $TARGET${RESET}"
                echo
            }
        fi
    done < "$STATE_FILE"

    sudo rm -f "$STATE_FILE" 2>/dev/null
fi
