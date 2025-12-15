# Chard Debug

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

colors=($RED $YELLOW $GREEN $CYAN $BLUE $MAGENTA)
num_colors=${#colors[@]}
count=0
color_index=0
echo
vars=()
while IFS= read -r var; do
    vars+=("$var")
done < <(
    for var in $(compgen -v); do
        if declare -F "$var" >/dev/null 2>&1; then
            continue
        fi
        value="${!var}"
        if [[ "$value" == *$'\n'* ]]; then
            continue
        fi
        echo "$var=$value"
    done | sort
)

for ((i=0; i<${#vars[@]}; i++)); do
    printf "%s%s%s\n" "${colors[color_index]}" "${vars[i]}" "$RESET"
    count=$((count + 1))
    if ((count % 10 == 0)); then
        echo
        color_index=$(( (color_index + 1) % num_colors ))
    fi
done
