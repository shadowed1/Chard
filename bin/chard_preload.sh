#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

STAGE2_FILE="$CHARD_ROOT/.chard_safe_preload"
sudo rm -f "$STAGE2_FILE"

if [[ -z "$LD_PRELOAD" ]]; then
    echo "${RED}${BOLD}Stage 1 not loaded. Source .chard.preload first!${RESET}"
fi

echo "${BOLD}${CYAN}Stage 1 loaded with $(echo "$LD_PRELOAD" | tr ':' '\n' | wc -l) libraries${RESET}"
echo "${BOLD}${BLUE}Scanning for additional safe libraries...${RESET}"
echo

TEST_CMD="curl --version 2>/dev/null"
CURRENT_LD_PRELOAD="$LD_PRELOAD"
LD_PRELOAD_LIBS_STAGE2=()

BANNED_REGEX="^(libc\.so|libpthread\.so|libdl\.so|libm\.so|libstdc\+\+\.so|libgcc_s\.so|libGL.*|libX11.*|libxcb.*|libbsd\.so|libc\+\+\.so)"
EXPLICIT_BANNED_REGEX="^(libgamemode(auto)?\.so)"

for lib in "$CHARD_ROOT/lib64"/*.so*; do
    [[ -f "$lib" ]] || continue
    
    libname=$(basename "$lib")
    if [[ "$libname" =~ $EXPLICIT_BANNED_REGEX ]]; then
        echo "${RED}${BOLD}$lib ${RESET}"
        continue
    fi
    
    if [[ "$libname" =~ $BANNED_REGEX ]]; then
        echo "${RED}$lib ${RESET}"
        continue
    fi
    
    case ":$CURRENT_LD_PRELOAD:" in
        *":$lib:"*) 
            echo "${BLUE}$lib ${RESET}"
            continue 
            ;;
    esac
    
    if ! file "$lib" | grep -q "ELF.*shared object"; then
        echo "${YELLOW}$lib ${RESET}"
        continue
    fi
    
    LD_PRELOAD="${CURRENT_LD_PRELOAD:+$CURRENT_LD_PRELOAD:}$lib" $TEST_CMD >/dev/null 2>&1
    
    if [[ $? -eq 0 ]]; then
        LD_PRELOAD_LIBS_STAGE2+=("$lib")
        echo
        echo "${GREEN}${BOLD}$lib ${RESET}"
        echo
        CURRENT_LD_PRELOAD="${CURRENT_LD_PRELOAD:+$CURRENT_LD_PRELOAD:}$lib"
    else
        echo "${RED}$lib ${RESET}"
    fi
done

echo
echo "${BOLD}${CYAN}Writing $STAGE2_FILE...${RESET}"

{
    echo "# <<< CHARD_STAGE2 <<<"
    echo "# Generated: $(date)"
    echo
    echo "LD_PRELOAD_LIBS_STAGE2=("
    for lib in "${LD_PRELOAD_LIBS_STAGE2[@]}"; do
        echo "    \"$lib\""
    done
    echo ")"
    echo "# <<< END CHARD_STAGE2 <<<"
} | sudo tee "$STAGE2_FILE" >/dev/null

echo
echo "${BOLD}${GREEN}Stage 2 generated with ${#LD_PRELOAD_LIBS_STAGE2[@]} new libraries! ${RESET}"
echo
