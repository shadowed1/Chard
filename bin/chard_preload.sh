#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

STAGE2_FILE="$CHARD_ROOT/.chard_safe_preload"
sudo rm -f "$STAGE2_FILE"

if [[ -z "$LD_PRELOAD" ]]; then
    echo "${RED}${BOLD} .chard.preload not loaded.${RESET}"
    sleep 5
    exit 1
fi

echo "${BOLD}${CYAN}Stage 1 loaded with $(echo "$LD_PRELOAD" | tr ':' '\n' | wc -l) libraries${RESET}"
echo "${BOLD}${BLUE}Scanning for additional safe libraries...${RESET}"
echo

TEST_CMD="curl --version"
CURRENT_LD_PRELOAD="$LD_PRELOAD"
LD_PRELOAD_LIBS_STAGE2=()

BANNED_REGEX="^(libc\.so|libpthread\.so|libdl\.so|libm\.so|libstdc\+\+\.so|libgcc_s\.so|libGL.*|libX11.*|libxcb.*|libbsd\.so|libc\+\+\.so)"
EXPLICIT_BANNED_REGEX="^(libgamemode(auto)?\.so|libmemusage\.so|libpcprofile\.so)"

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
    
    TEST_PRELOAD="${CURRENT_LD_PRELOAD:+$CURRENT_LD_PRELOAD:}$lib"
    TEST_OUTPUT=$(LD_PRELOAD="$TEST_PRELOAD" $TEST_CMD 2>&1)
    TEST_EXIT=$?
    
    if echo "$TEST_OUTPUT" | grep -qE "(Memory usage summary|heap total|total calls|total memory)"; then
        echo "${RED}${BOLD} $lib ${RESET}"
        continue
    fi
    
    if [[ $TEST_EXIT -eq 0 ]]; then
        LD_PRELOAD_LIBS_STAGE2+=("$lib")
        echo "${GREEN}${BOLD}$lib ${RESET}"
        CURRENT_LD_PRELOAD="$TEST_PRELOAD"
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
sleep 5
$CHARD_ROOT/bin/chard_stage3_preload
