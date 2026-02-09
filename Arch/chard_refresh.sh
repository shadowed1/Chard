#!/bin/bash
STAMP_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/chard_last_refresh"
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/chard_refresh.lock"
INTERVAL=$((24*60*60))
mkdir -p "$(dirname "$STAMP_FILE")"
now=$(date +%s)
last=0
[[ -f "$STAMP_FILE" ]] && last=$(cat "$STAMP_FILE" 2>/dev/null || echo 0)
(( now - last < INTERVAL )) && exit 0
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0
last=0
[[ -f "$STAMP_FILE" ]] && last=$(cat "$STAMP_FILE" 2>/dev/null || echo 0)
(( now - last < INTERVAL )) && exit 0
echo "$now" > "$STAMP_FILE"
(
    echo "[chard_refresh] Updating sync databases..."
    sudo -E pacman -Sy
    sudo -E pacman -Fy
    printf "y\nn\n" | sudo pacman -Scc
    printf "y\nn\ny\nn\n" | yay -Sc
) >/dev/null 2>&1 &
