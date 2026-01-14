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

: > "$STATE_FILE"

if [ ! -d "/media/fuse/fusebox/" ]; then
    echo
    echo "${YELLOW}/media/fuse/fusebox/ does not exist. No MTP devices detected.${RESET}"
    exit 0
fi

mtp_DEVICES=$(ls -d /media/fuse/fusebox/mtp.* 2>/dev/null)

if [ -z "$mtp_DEVICES" ]; then
    echo
    echo "${YELLOW}No MTP devices detected.${RESET}"
    exit 0
fi

echo
echo "${GREEN}Detected Android MTP devices: ${BOLD}"
for DEV in $mtp_DEVICES; do
    echo "$DEV"
done
echo "${RESET}"

for DEV in $mtp_DEVICES; do
    echo "$DEV" >> "$STATE_FILE"
done

echo "${RESET}${BLUE}Bind-Mounted to $CHARD_ROOT/$CHARD_HOME/mtp_devices: ${BOLD}"
cat "$STATE_FILE"
echo "${RESET}"

sudo mkdir -p "$MOUNT_POINT"

while read -r DEV_PATH; do
    BASENAME=$(basename "$DEV_PATH")
    TARGET="$MOUNT_POINT/$BASENAME"
    sudo mkdir -p "$TARGET"
    sudo mount --bind "$DEV_PATH" "$TARGET" 2>/dev/null || {
        echo "${RED}Failed to mount $DEV_PATH${RESET}"
    }
done < "$STATE_FILE"
