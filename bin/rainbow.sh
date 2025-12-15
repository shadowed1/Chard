#!/bin/bash
# ChromeOS Rainbow Shell
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)
export PS1='\u@\h \w \$ '
colors=("$MAGENTA" "$BLUE" "$CYAN" "$GREEN" "$YELLOW" "$RED")
num_colors=${#colors[@]}

colorize() {
    local i=0
    local buffer=""
    local in_escape=0
    local char
    while IFS= read -r -n1 -d '' char; do
        if [ "$char" = $'\e' ] || [ "$char" = $'\x1b' ]; then
            in_escape=1
            buffer="$char"
            continue
        fi
        
        if [ $in_escape -eq 1 ]; then
            buffer+="$char"
            if [[ "$char" =~ [a-zA-Z~] ]]; then
                printf "%s" "$buffer"
                buffer=""
                in_escape=0
            fi
            continue
        fi
        
        printf "%s%s%s" "${colors[i]}" "$char" "${RESET}"
        ((i=(i+1)%num_colors))
    done
}

script -qfc "bash -c \"export PS1='\u@\h \w \$ '; exec bash --norc\"" /dev/null | colorize
