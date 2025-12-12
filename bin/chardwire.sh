#!/bin/bash

VOLUME_FILE="$HOME/.chard_volume"
MUTED_FILE="$HOME/.chard_muted"
LAST_VOLUME=""
LAST_MUTED=""
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
    else
        volume=""
    fi

    muted=0
    if [ -f "$MUTED_FILE" ]; then
        read -r muted < "$MUTED_FILE"
        if [ "$muted" != "1" ]; then
            muted=0
        fi
    fi

    if [ "$muted" = "1" ]; then
        effective_volume=0
    else
        effective_volume="$volume"
    fi

    if [[ "$effective_volume" =~ ^[0-9]+$ ]] &&
       [ "$effective_volume" -ge 0 ] &&
       [ "$effective_volume" -le 100 ] &&
       [ "$effective_volume" != "$LAST_VOLUME" ]; then
        LAST_VOLUME="$effective_volume"

        if command -v wpctl >/dev/null 2>&1; then
            volume_decimal=$(echo "scale=2; $effective_volume / 100" | bc)
            wpctl set-volume @DEFAULT_AUDIO_SINK@ "$volume_decimal" 2>/dev/null
            echo "${CYAN}wpctl: ${RESET}${GREEN}$effective_volume% ($volume_decimal) ${RESET}"
        fi

        if command -v pactl >/dev/null 2>&1; then
            SINK=$(pactl get-default-sink 2>/dev/null)
            if [ -z "$SINK" ]; then
                SINK=$(pactl list short sinks 2>/dev/null | awk 'NR==1 {print $1}')
            fi

            if [ -n "$SINK" ]; then
                pactl set-sink-volume "$SINK" "${effective_volume}%" 2>/dev/null
                echo "${BLUE}pactl: ${RESET}${MAGENTA}$effective_volume% on sink $SINK ${RESET}"
            else
                echo "${RED}ERROR: No PulseAudio sink found.${RESET}"
            fi
        fi
    fi

    if [ "$muted" != "$LAST_MUTED" ]; then
        LAST_MUTED="$muted"
        if command -v wpctl >/dev/null 2>&1; then
            wpctl set-mute @DEFAULT_AUDIO_SINK@ "$muted" 2>/dev/null || true
            if [ "$muted" = "1" ]; then
                echo "${CYAN}wpctl:${RESET} ${YELLOW}Muted${RESET}"
            else
                echo "${CYAN}wpctl:${RESET} ${GREEN}Unmuted${RESET}"
            fi
        fi

        if command -v pactl >/dev/null 2>&1; then
            SINK=$(pactl get-default-sink 2>/dev/null)
            if [ -z "$SINK" ]; then
                SINK=$(pactl list short sinks 2>/dev/null | awk 'NR==1 {print $1}')
            fi

            if [ -n "$SINK" ]; then
                pactl set-sink-mute "$SINK" "$muted" 2>/dev/null || true
                if [ "$muted" = "1" ]; then
                    echo "${BLUE}pactl:${RESET} ${YELLOW}Muted on sink $SINK${RESET}"
                else
                    echo "${BLUE}pactl:${RESET} ${GREEN}Unmuted on sink $SINK${RESET}"
                fi
            else
                echo "${RED}ERROR: No PulseAudio sink found for mute operation.${RESET}"
            fi
        fi
    fi
}

tail -n0 -F "$VOLUME_FILE" | while read -r line; do
    apply_volume
    sleep 0.1
done &

tail -n0 -F "$MUTED_FILE" | while read -r line; do
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
