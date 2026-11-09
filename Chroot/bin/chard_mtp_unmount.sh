#!/bin/bash
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

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
