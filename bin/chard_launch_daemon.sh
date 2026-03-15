#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

CHARD_HOME=$(cat /.chard_home)
WATCH_DIR="/$CHARD_HOME/user/MyFiles/Downloads/chard_icons/launch"
ALIASES_FILE="/$CHARD_HOME/user/MyFiles/Downloads/chard_icons/.chard_aliases"

mkdir -p "$WATCH_DIR"
rm -f "$WATCH_DIR"/* 2>/dev/null
sleep 1

if [ -S /tmp/.X11-unix/X0 ]; then
    export DISPLAY=:0
else
    DISPLAY=$(ls /tmp/.X11-unix/ 2>/dev/null | sed 's/^X/:/' | head -1)
    export DISPLAY
fi

echo "${CYAN}[chard_launch_daemon] DISPLAY=$DISPLAY watching $WATCH_DIR ${RESET}"

declare -A ALIASES
if [ -f "$ALIASES_FILE" ]; then
    while IFS='=' read -r key val; do
        [ -n "$key" ] && ALIASES["$key"]="$val"
    done < "$ALIASES_FILE"
    echo "${GREEN}[chard_launch_daemon] loaded ${#ALIASES[@]} aliases ${RESET}"
fi

resolve_exec() {
    local exec_cmd="$1"
    local bin=$(echo "$exec_cmd" | awk '{print $1}')
    local args=$(echo "$exec_cmd" | cut -s -d' ' -f2-)
    local base=$(basename "$bin")
    if [ -n "${ALIASES[$base]}" ]; then
        echo "${ALIASES[$base]}${args:+ $args}"
    else
        echo "$exec_cmd"
    fi
}

launch_app() {
    local desktop_file_id="$1"
    local df=""
    if [ -f "/usr/share/applications/${desktop_file_id}.desktop" ]; then
        df="/usr/share/applications/${desktop_file_id}.desktop"
    else
        df=$(find /usr/share/applications -name "*${desktop_file_id}*.desktop" 2>/dev/null | head -1)
    fi
    if [ -z "$df" ]; then
        echo "[chard_launch_daemon] no desktop file for: $desktop_file_id"
        return
    fi
    local exec_raw=$(grep -m1 '^Exec=' "$df" | cut -d= -f2- | sed 's/ %[a-zA-Z]//g')
    local terminal=$(grep -m1 '^Terminal=' "$df" | cut -d= -f2 | tr -d '[:space:]')
    local name=$(grep -m1 '^Name=' "$df" | cut -d= -f2-)
    local exec_cmd=$(resolve_exec "$exec_raw")
    echo "${BLUE}[chard_launch_daemon] launching: $name -> $exec_cmd ${RESET}"
    [ -f ~/.bashrc ] && source ~/.bashrc 2>/dev/null
    if [ "$terminal" = "true" ]; then
        DISPLAY=$DISPLAY xfce4-terminal -e "$exec_cmd" &
    else
        DISPLAY=$DISPLAY eval "$exec_cmd" &
    fi
}

while true; do
    for trigger in "$WATCH_DIR"/*; do
        [ -f "$trigger" ] || continue
        filename=$(basename "$trigger")
        rm -f "$trigger"
        echo "${CYAN}[chard_launch_daemon] trigger: $filename ${RESET}"
        launch_app "$filename" &
    done
    sleep 0.5
done
