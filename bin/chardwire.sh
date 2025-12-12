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
        [ "$muted" != "1" ] && muted=0
    fi

    effective_volume=$([ "$muted" = "1" ] && echo 0 || echo "$volume")

    if [[ "$effective_volume" =~ ^[0-9]+$ ]] && [ "$effective_volume" -ge 0 ] && [ "$effective_volume" -le 100 ] && [ "$effective_volume" != "$LAST_VOLUME" ]; then
        LAST_VOLUME="$effective_volume"

        if command -v wpctl >/dev/null 2>&1; then
            volume_decimal=$(echo "scale=2; $effective_volume / 100" | bc)
            wpctl set-volume @DEFAULT_AUDIO_SINK@ "$volume_decimal" 2>/dev/null
            echo "${RESET}${GREEN}$effective_volume% ${RESET}"
        fi

        if command -v pactl >/dev/null 2>&1; then
            SINK=$(pactl get-default-sink 2>/dev/null)
            [ -z "$SINK" ] && SINK=$(pactl list short sinks 2>/dev/null | awk 'NR==1 {print $1}')
            [ -n "$SINK" ] && pactl set-sink-volume "$SINK" "${effective_volume}%" 2>/dev/null
        fi
    fi

    if [ "$muted" != "$LAST_MUTED" ]; then
        LAST_MUTED="$muted"
        if command -v wpctl >/dev/null 2>&1; then
            wpctl set-mute @DEFAULT_AUDIO_SINK@ "$muted" 2>/dev/null
            echo "${RESET}$([ "$muted" = "1" ] && echo "${RED}Muted${RESET}" || echo "${YELLOW}Unmuted${RESET}")"
        fi
        if command -v pactl >/dev/null 2>&1; then
            SINK=$(pactl get-default-sink 2>/dev/null)
            [ -z "$SINK" ] && SINK=$(pactl list short sinks 2>/dev/null | awk 'NR==1 {print $1}')
            [ -n "$SINK" ] && pactl set-sink-mute "$SINK" "$muted" 2>/dev/null
        fi
    fi
}

FILES=(
    "$HOME/.chard_volume"
    "$HOME/.chard_hdmi"
    "$HOME/.chard_bluetooth"
    "$HOME/.chard_usb"
    "$HOME/.chard_muted"
)

if command -v inotifywait >/dev/null 2>&1; then
    while true; do
        inotifywait -q -e modify "${FILES[@]}" 2>/dev/null
        apply_volume
    done &
else
    tail_args=()
    for f in "${FILES[@]}"; do
        [ -f "$f" ] || touch "$f"
        tail_args+=("$f")
    done

    tail -n0 -F "${tail_args[@]}" | while read -r _; do
        apply_volume
        sleep 0.1
    done &
fi

while true; do
    if ! pactl info >/dev/null 2>&1; then
        echo "${MAGENTA}$EPOCHSECONDS: PulseAudio killed by ChromeOS -- Chard is restarting Pulseaudio!${RESET}" >&2
        pulseaudio 2>/dev/null &
    fi
    sleep "$INTERVAL"
done
