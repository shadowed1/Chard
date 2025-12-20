#!/bin/bash
# ChromeOS Rainbow Shell
RESET=$(tput sgr0)
export PS1='\u@\h \w \$ '
rainbow_indices=()

for ((g=0; g<=5; g++)); do rainbow_indices+=( $((16 + 36*5 + 6*g + 0)) ); done
for ((r=5; r>=0; r--)); do rainbow_indices+=( $((16 + 36*r + 6*5 + 0)) ); done
for ((b=0; b<=5; b++)); do rainbow_indices+=( $((16 + 36*0 + 6*5 + b)) ); done
for ((g=5; g>=0; g--)); do rainbow_indices+=( $((16 + 36*0 + 6*g + 5)) ); done
for ((r=0; r<=5; r++)); do rainbow_indices+=( $((16 + 36*r + 6*0 + 5)) ); done
for ((b=5; b>=0; b--)); do rainbow_indices+=( $((16 + 36*5 + 6*0 + b)) ); done

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

script -qfc "bash -c \"export PS1='\u@\h \w \$ '; exec bash --norc\"" /dev/null | colorize
