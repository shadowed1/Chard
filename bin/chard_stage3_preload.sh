#!/bin/bash
# CHARD STAGE3 PRELOAD

CYAN=$(tput setaf 6)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BOLD=$(tput bold)
RESET=$(tput sgr0)

STAGE3_FILE="$CHARD_ROOT/.chard_stage3_preload"

if [[ ! -f "$CHARD_ROOT/.chard.preload" ]]; then
    echo "${RED}${BOLD}ERROR: .chard.preload not found!${RESET}"
fi

if [[ ! -f "$CHARD_ROOT/.chard_safe_preload" ]]; then
    echo "${RED}${BOLD}ERROR: .chard_safe_preload ${RESET}"
fi

echo "${BOLD}${CYAN}Merging Stage 1 and Stage 2... ${RESET}"
source "$CHARD_ROOT/.chard.preload"
source "$CHARD_ROOT/.chard_safe_preload"

declare -A seen
LD_PRELOAD_LIBS_STAGE3=()

for lib in "${LD_PRELOAD_LIBS_STAGE1[@]}"; do
    if [[ -z "${seen[$lib]}" && -f "$lib" ]]; then
        seen[$lib]=1
        LD_PRELOAD_LIBS_STAGE3+=("$lib")
    fi
done

for lib in "${LD_PRELOAD_LIBS_STAGE2[@]}"; do
    if [[ -z "${seen[$lib]}" && -f "$lib" ]]; then
        seen[$lib]=1
        LD_PRELOAD_LIBS_STAGE3+=("$lib")
    fi
done
echo
echo "${BOLD}${CYAN}Writing $STAGE3_FILE... ${RESET}"

{
    echo "#!/bin/bash"
    echo "# <<< CHARD_STAGE3 <<<"
    echo "# Merged and deduplicated Stage 1 + Stage 2"
    echo "# Generated: $(date)"
    echo "# Total libraries: ${#LD_PRELOAD_LIBS_STAGE3[@]}"
    echo
    echo "LD_PRELOAD_LIBS_STAGE3=("
    for lib in "${LD_PRELOAD_LIBS_STAGE3[@]}"; do
        echo "    \"$lib\""
    done
    echo ")"
    echo
    echo "LD_PRELOAD=\"\""
    echo "for lib in \"\${LD_PRELOAD_LIBS_STAGE3[@]}\"; do"
    echo "    [[ -f \"\$lib\" ]] && LD_PRELOAD=\"\${LD_PRELOAD:+\$LD_PRELOAD:}\$lib\""
    echo "done 2>/dev/null"
    echo
    echo "export LD_PRELOAD"
    echo "# <<< END CHARD_STAGE3 <<<"
} | sudo tee "$STAGE3_FILE" >/dev/null

sudo chmod +x "$STAGE3_FILE"

echo
echo "${BOLD}${GREEN} Stage 3 created with ${#LD_PRELOAD_LIBS_STAGE3[@]} total libraries! ${RESET}"
echo "${BOLD}${CYAN}  Stage 1: ${#LD_PRELOAD_LIBS_STAGE1[@]} libraries ${RESET}"
echo "${BOLD}${BLUE}  Stage 2: ${#LD_PRELOAD_LIBS_STAGE2[@]} libraries ${RESET}"
echo "${BOLD}${MAGENTA}  Stage 3: ${#LD_PRELOAD_LIBS_STAGE3[@]} libraries ${RESET}"
echo
