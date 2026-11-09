#!/bin/bash
# ChromeOS Rainbow Shell
# shadowed1
# Thanks to days for help with color research and finding device name

RESET=$(tput sgr0)

if [[ -f /tmp/machine-info ]]; then
    DEVICE_NAME=$(grep '^customization_id=' /tmp/machine-info 2>/dev/null | cut -d= -f2 | tr -d '"')
else
    DEVICE_NAME="rainbow"
fi

if [[ -f /sys/class/chromeos/cros_ec/version ]]; then
    BOARD_REV=$(grep '^Board version:' /sys/class/chromeos/cros_ec/version 2>/dev/null | awk '{print $3}')
    BOARD_REV="rev$BOARD_REV"
else
    BOARD_REV="rev?"
fi

USER_NAME=${USER:-$(whoami)}
ORIGINAL_PS1="$USER_NAME@$DEVICE_NAME-$BOARD_REV \w # "
export ORIGINAL_PS1
rainbow_indices=()

for ((g=0; g<=5; g++)); do rainbow_indices+=( $((16 + 36*5 + 6*g + 0)) ); done # Red to Yellow Cube
for ((r=5; r>=0; r--)); do rainbow_indices+=( $((16 + 36*r + 6*5 + 0)) ); done # Yellow to Green Cube
for ((b=0; b<=5; b++)); do rainbow_indices+=( $((16 + 36*0 + 6*5 + b)) ); done # Green to Cyan Cube
for ((g=5; g>=0; g--)); do rainbow_indices+=( $((16 + 36*0 + 6*g + 5)) ); done # Cyan to Blue Cube
for ((r=0; r<=5; r++)); do rainbow_indices+=( $((16 + 36*r + 6*0 + 5)) ); done # Blue to Magenta Cube
for ((b=5; b>=0; b--)); do rainbow_indices+=( $((16 + 36*5 + 6*0 + b)) ); done # Magenta to Red Cube

num_colors=${#rainbow_indices[@]}
colorize() {
    local i=0
    local buffer=""
    local in_escape=0
    local char

    while IFS= read -r -n1 -d '' char; do
        if [[ "$char" == $'\e' ]]; then
            in_escape=1
            buffer="$char"
            continue
        fi

        if (( in_escape )); then
            buffer+="$char"
            if [[ "$char" =~ [a-zA-Z~] ]]; then
                printf "%s" "$buffer"
                buffer=""
                in_escape=0
            fi
            continue
        fi

        printf "%s%s%s" \
            "$(tput setaf "${rainbow_indices[i]}")" \
            "$char" \
            "$RESET"

        (( i = (i + 1) % num_colors ))
    done
}

script -qfc \
"source ~/.bashrc 2>/dev/null; export PS1=\"\$ORIGINAL_PS1\"; exec bash --norc -i" \
/dev/null | colorize

