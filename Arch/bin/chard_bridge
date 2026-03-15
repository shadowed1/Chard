#!/bin/bash
# Runs inside Crostini
DESKTOP_FILE_ID="$1"
SHARED="/mnt/chromeos/MyFiles/Downloads/chard_icons"
if [ -z "$DESKTOP_FILE_ID" ]; then
    exit 1
fi
touch "$SHARED/launch/$DESKTOP_FILE_ID"
