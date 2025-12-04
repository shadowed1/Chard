#!/bin/bash

VOLUME_FILE="$HOME/.chard_volume"
LAST_VOLUME=""

apply_volume() {
    if [ -f "$VOLUME_FILE" ]; then
        read -r volume < "$VOLUME_FILE"
        if [[ "$volume" =~ ^[0-9]+$ ]] && [ "$volume" -ge 0 ] && [ "$volume" -le 100 ] && [ "$volume" != "$LAST_VOLUME" ]; then
            LAST_VOLUME="$volume"
            volume_decimal=$(echo "scale=2; $volume / 100" | bc)
            wpctl set-volume @DEFAULT_AUDIO_SINK@ "$volume_decimal"
            echo "Volume set to: $volume% ($volume_decimal)"
        fi
    fi
}


while read -r line; do
    apply_volume
    sleep 0.1
done < <(tail -n0 -F "$VOLUME_FILE")
