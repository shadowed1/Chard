#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

: "${CHARD_ROOT:?ERROR: CHARD_ROOT is not set}"
if [[ -f /.chardrc ]]; then
    echo "${RED}chard_timezone_daemon must be run from host.${RESET}"
    sleep 4
    exit 1
fi

CHARD_TZ_FILE="$CHARD_ROOT/.chard_timezone"
ZONEINFO_DIR="$CHARD_ROOT/usr/share/zoneinfo"
LOCALTIME_LINK="$CHARD_ROOT/etc/localtime"

while true; do
    TZ_ABBR="$(date +%Z)"
    TZ_OFFSET="$(date +%z)"
    echo
    #echo "${BLUE}[Chard TimeZone daemon]: ${BOLD}$TZ_ABBR $TZ_OFFSET${RESET}"
    echo "$TZ_ABBR $TZ_OFFSET" | sudo tee "$CHARD_TZ_FILE" > /dev/null
    MATCH=""
    while IFS= read -r zone; do
        [[ "$zone" == *posix* || "$zone" == *right* ]] && continue

        ZONE_NAME="${zone#$ZONEINFO_DIR/}"
        ZONE_OFFSET="$(TZ="$ZONE_NAME" date +%z 2>/dev/null || true)"

        if [[ "$ZONE_OFFSET" == "$TZ_OFFSET" ]]; then
            MATCH="$ZONE_NAME"
            break
        fi
    done < <(find "$ZONEINFO_DIR" -type f)
    if [[ -z "$MATCH" ]]; then
        #echo "${YELLOW}[Chard TimeZone daemon] No exact match, using GMT fallback${RESET}"

        OFFSET_HOURS=$((10#${TZ_OFFSET:0:3}))

        if (( OFFSET_HOURS > 0 )); then
            MATCH="Etc/GMT-$OFFSET_HOURS"
        else
            MATCH="Etc/GMT+${OFFSET_HOURS#-}"
        fi
    fi

    echo "${GREEN}[Chard TimeZone Daemon] Synced: $MATCH${RESET}"
    sudo mkdir -p "$(dirname "$LOCALTIME_LINK")"
    sudo ln -sf "/usr/share/zoneinfo/$MATCH" "$LOCALTIME_LINK"
    sleep 3600
done
