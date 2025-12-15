#!/bin/bash
# Chard Stage 2 Generator - Run manually to scan for safe libs
# Usage: chard_generate_stage2

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

STAGE2_FILE="$CHARD_ROOT/.chard_safe_preload"
sudo rm -f "$STAGE2_FILE"

# Checkpoint: Stage 1 must be loaded
if [[ -z "$LD_PRELOAD" ]]; then
    echo "${RED}${BOLD}ERROR: Stage 1 not loaded. Source .chard.preload first!${RESET}"
    exit 1
fi

echo "${BOLD}${CYAN}Stage 1 loaded with $(echo "$LD_PRELOAD" | tr ':' '\n' | wc -l) libraries${RESET}"
echo "${BOLD}${CYAN}Scanning for additional safe libraries...${RESET}"
echo

TEST_CMD="curl --version 2>/dev/null"
CURRENT_LD_PRELOAD="$LD_PRELOAD"
LD_PRELOAD_LIBS_STAGE2=()

BANNED_REGEX="^(libc\.so|libpthread\.so|libdl\.so|libm\.so|libstdc\+\+\.so|libgcc_s\.so|libGL.*|libX11.*|libxcb.*|libbsd\.so|libc\+\+\.so)"

for lib in "$CHARD_ROOT/lib64"/*.so*; do
    [[ -f "$lib" ]] || continue
    
    libname=$(basename "$lib")
    [[ "$libname" =~ $BANNED_REGEX ]] && continue
    
    # Skip if already in Stage 1
    case ":$CURRENT_LD_PRELOAD:" in
        *":$lib:"*) 
            echo "${BLUE}⊙ $lib${RESET} (already in Stage 1)"
            continue 
            ;;
    esac
    
    if ! file "$lib" | grep -q "ELF.*shared object"; then
        echo "${YELLOW}⊘ $lib${RESET} (not shared object)"
        continue
    fi
    
    LD_PRELOAD="${CURRENT_LD_PRELOAD:+$CURRENT_LD_PRELOAD:}$lib" $TEST_CMD >/dev/null 2>&1
    
    if [[ $? -eq 0 ]]; then
        LD_PRELOAD_LIBS_STAGE2+=("$lib")
        echo "${GREEN}${BOLD}✓ $lib${RESET}"
        CURRENT_LD_PRELOAD="${CURRENT_LD_PRELOAD:+$CURRENT_LD_PRELOAD:}$lib"
    else
        echo "${RED}✗ $lib${RESET} (causes crash)"
    fi
done

echo
echo "${BOLD}${CYAN}Writing $STAGE2_FILE...${RESET}"

{
    echo "# <<< CHARD_STAGE2 <<<"
    echo "# Auto-generated Stage 2 libraries"
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
echo "${BOLD}${GREEN}✓ Stage 2 generated with ${#LD_PRELOAD_LIBS_STAGE2[@]} new libraries!${RESET}"
echo "${BOLD}${CYAN}Run 'chard_merge_stages' to create Stage 3${RESET}"
