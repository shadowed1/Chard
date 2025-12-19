#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

PRELOAD_LIST="$CHARD_ROOT/.chard_stage3_preload"
EXEC_WRAPPER="$CHARD_ROOT/bin/chard_exec"

echo "${BOLD}${CYAN}Merging Stage 1 and Stage 2...${RESET}"

source "$CHARD_ROOT/.chard.preload"
source "$CHARD_ROOT/.chard_safe_preload"

declare -A seen
LD_PRELOAD_LIBS_STAGE3=()

for lib in "${LD_PRELOAD_LIBS_STAGE1[@]}" "${LD_PRELOAD_LIBS_STAGE2[@]}"; do
    if [[ -f "$lib" && -z "${seen[$lib]}" ]]; then
        seen[$lib]=1
        LD_PRELOAD_LIBS_STAGE3+=("$lib")
    fi
done

echo "${BOLD}${CYAN}Writing preload list...${RESET}"

{
    echo "# CHARD preload list"
    echo "# Generated: $(date)"
    for lib in "${LD_PRELOAD_LIBS_STAGE3[@]}"; do
        echo "$lib"
    done
} | sudo tee "$PRELOAD_LIST" >/dev/null

sudo chmod 0644 "$PRELOAD_LIST"

echo "${BOLD}${CYAN}Writing exec wrapper...${RESET}"

sudo tee "$EXEC_WRAPPER" >/dev/null <<'EOF'
#!/bin/bash
PRELOAD_FILE="$CHARD_ROOT/.chard_stage3_preload"

if [[ ! -f "$PRELOAD_FILE" ]]; then
    exec "$@"
fi

LD_PRELOAD=$(paste -sd: "$PRELOAD_FILE")
export LD_PRELOAD

exec "$@"
EOF

sudo chmod +x "$EXEC_WRAPPER"

echo
echo "${BOLD}${GREEN}Stage 3 fixed successfully${RESET}"
echo "${BOLD}${CYAN}Libraries: ${#LD_PRELOAD_LIBS_STAGE3[@]}${RESET}"
echo
echo "${BOLD}${GREEN}Use:${RESET} chard_exec <program>"
