#!/bin/bash

VOLUME_FILE="$HOME/.chard_volume"
LAST_VOLUME=""
INTERVAL=5
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

apply_volume() {
    if [ -f "$VOLUME_FILE" ]; then
        read -r volume < "$VOLUME_FILE"

        if [[ "$volume" =~ ^[0-9]+$ ]] && [ "$volume" -ge 0 ] && [ "$volume" -le 100 ] && [ "$volume" != "$LAST_VOLUME" ]; then
            LAST_VOLUME="$volume"

            if command -v wpctl >/dev/null 2>&1; then
                volume_decimal=$(echo "scale=2; $volume / 100" | bc)
                wpctl set-volume @DEFAULT_AUDIO_SINK@ "$volume_decimal" 2>/dev/null
                echo "${CYAN}wpctl: $volume% ($volume_decimal) ${RESET}"
            fi

            if command -v pactl >/dev/null 2>&1; then
                SINK=$(pactl get-default-sink 2>/dev/null)
                if [ -z "$SINK" ]; then
                    SINK=$(pactl list short sinks 2>/dev/null | awk 'NR==1 {print $1}')
                fi

                if [ -n "$SINK" ]; then
                    pactl set-sink-volume "$SINK" "${volume}%" 2>/dev/null
                    echo "${BLUE}pactl: $volume% on sink $SINK ${RESET}"
                else
                    echo "${RED}ERROR: No PulseAudio sink found.${RESET}"
                fi
            fi

            if ! command -v wpctl >/dev/null 2>&1 && ! command -v pactl >/dev/null 2>&1; then
                echo "${RED}ERROR: wpctl nor pactl is available. ${RESET}"
            fi
        fi
    fi
}

tail -n0 -F "$VOLUME_FILE" | while read -r line; do
    apply_volume
    sleep 0.1
done &

while true; do
    if ! pactl info >/dev/null 2>&1; then
        echo "${MAGENTA}$EPOCHSECONDS: PulseAudio killed by ChromeOS -- Chard is restarting Pulseaudio! ${RESET}" >&2
        pulseaudio 2>/dev/null &
    fi
    sleep $INTERVAL
done
