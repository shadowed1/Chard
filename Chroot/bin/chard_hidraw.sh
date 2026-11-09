#!/bin/bash
# chard_hidraw - enable hotswapping PS5 controllers hopefully

CHROMEOS_DIR="/home/chronos/user/MyFiles/Downloads"
LOG_FILE="/tmp/chard_hidraw.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"
}

if [[ ! -d "$CHROMEOS_DIR" ]]; then
    echo "Guard directory $CHROMEOS_DIR not found. Exiting."
    exit 1
fi

grant_perms() {
    for dev in /dev/hidraw*; do
        if [[ -e "$dev" ]]; then
            sudo chmod 666 "$dev" 2>/dev/null && log "chmod 666 $dev" || log "FAILED chmod $dev"
        fi
    done
}

log "=== chard_hidraw starting (PID $$) ==="
grant_perms

while true; do
    event=$(inotifywait \
        -q \
        --format '%e %f' \
        -e create -e delete \
        /dev 2>/dev/null) || true

    filename=$(echo "$event" | awk '{print $NF}')

    if [[ "$filename" == hidraw* ]]; then
        log "Event: $event"
        sleep 0.2
        grant_perms
    fi
done
