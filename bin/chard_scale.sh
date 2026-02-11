#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
DISPLAY_SCALING=""
CURSOR_SIZE=""

update_env_file() {
    local var="$1"
    local value="$2"
    local env_file="$HOME/.bashrc"

    sed -i "/^export $var=/d" "$env_file"
    echo "export $var=$value" >> "$env_file"
}

set_display_scaling() {
    local input="$1"

    if [[ "$input" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        local scale=$(printf "%.2f" "$input")
        (( $(awk "BEGIN {print ($scale < 0.25)}") )) && scale=1.0
        (( $(awk "BEGIN {print ($scale > 4.0)}") )) && scale=4.0

        CHARD_SCALE="$scale"
        GDK_SCALE="$scale"
        QT_SCALE_FACTOR="$scale"
        ELECTRON_FORCE_DEVICE_SCALE_FACTOR="$scale"
        _JAVA_OPTIONS="-Dsun.java2d.uiScale=$scale"

        export CHARD_SCALE GDK_SCALE GDK_DPI_SCALE=1 QT_SCALE_FACTOR \
               QT_AUTO_SCREEN_SCALE_FACTOR=1 ELECTRON_FORCE_DEVICE_SCALE_FACTOR _JAVA_OPTIONS

        update_env_file "CHARD_SCALE" "$CHARD_SCALE"
        update_env_file "GDK_SCALE" "$GDK_SCALE"
        update_env_file "QT_SCALE_FACTOR" "$QT_SCALE_FACTOR"
        update_env_file "QT_AUTO_SCREEN_SCALE_FACTOR" "1"
        update_env_file "ELECTRON_FORCE_DEVICE_SCALE_FACTOR" "$ELECTRON_FORCE_DEVICE_SCALE_FACTOR"
        update_env_file "_JAVA_OPTIONS" "$_JAVA_OPTIONS"
        source "$HOME/.bashrc" 2>/dev/null
        echo "${GREEN}Display scaling set to $CHARD_SCALE .${RESET}" >&2
    else
        echo "${RED}Error: DISPLAY_SCALING must be a number between 0.25 and 4.0${RESET}" >&2
        return 1
    fi
}

set_cursor_scaling() {
    local input="$1"
    if ! [[ "$input" =~ ^[0-9]+$ ]]; then
        echo "${RED}Error: Cursor size must be an integer.${RESET}" >&2
        return 1
    fi

    CURSOR_SIZE=$input
    (( CURSOR_SIZE < 8 )) && CURSOR_SIZE=8
    (( CURSOR_SIZE > 200 )) && CURSOR_SIZE=200

    export XCURSOR_SIZE=$CURSOR_SIZE

    update_env_file "XCURSOR_SIZE" "$CURSOR_SIZE"

    echo "${GREEN}Cursor size set to $CURSOR_SIZE ${RESET}" >&2
}

case "$1" in
    display)
        if [[ -z "$2" ]]; then
            echo
            echo "${GREEN}Current display scaling: $AURORA_SCALE ${RESET}"
            echo
        else
            set_display_scaling "$2"
        fi
        ;;
    cursor)
        if [[ -z "$2" ]]; then
            echo
            echo "${GREEN}Current cursor size: $XCURSOR_SIZE ${RESET}"
            echo
        else
            set_cursor_scaling "$2"
        fi
        ;;
esac
