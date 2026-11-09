# Chard Debug

RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

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
