#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo
echo "${BOLD}${RED}Run: ${RESET}${BOLD}${GREEN}sudo rm $CHARD_ROOT/.chard_stage3_preload${RESET}${BOLD}${RED} to remove this LD_PRELOAD${RESET}"
echo "${GREEN}CTRL-C to exit. Starts in 15 seconds! ${RESET}"
echo
echo
echo "${BOLD}${CYAN}═══════════════════════════════════════${RESET}"
echo "${BOLD}${CYAN}Legend:${RESET}"
echo "  ${GREEN}Success $SUCCESS_COUNT${RESET}"
echo "  ${BLUE}Already loaded $ALREADY_COUNT${RESET}"
echo "  ${RED}Failed $FAILED_COUNT${RESET}"
echo "  ${RED}Banned $BANNED_COUNT${RESET}"
echo "  ${YELLOW}Not ELF $NOT_ELF_COUNT${RESET}"
echo "${BOLD}${CYAN}═══════════════════════════════════════${RESET}"
echo
sleep 15

STAGE2_FILE="$CHARD_ROOT/.chard_safe_preload"
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

sudo rm -f "$CHARD_ROOT/.chard_stage3_preload" 2>/dev/null
sudo rm -f "$STAGE2_FILE" 2>/dev/null

if [[ -z "$LD_PRELOAD" ]]; then
    echo "${RED}${BOLD}.chard.preload not loaded.${RESET}"
    sleep 5
    exit 1
fi

echo "${BOLD}${CYAN}Stage 1 loaded with $(echo "$LD_PRELOAD" | tr ':' '\n' | wc -l) libraries${RESET}"
echo
NUM_CORES=$(nproc)
(( NUM_CORES > 1 )) && (( NUM_CORES-- ))
echo "${BOLD}${CYAN}${NUM_CORES} CPU cores allocated ${RESET}"
echo
sleep 5

TEST_CMD="curl --version"
CURRENT_LD_PRELOAD="$LD_PRELOAD"

BANNED_REGEX="^(libc\.so|libpthread\.so|libdl\.so|libm\.so|libstdc\+\+\.so|libgcc_s\.so|libGL.*|libX11.*|libxcb.*|libbsd\.so|libc\+\+\.so)"
EXPLICIT_BANNED_REGEX="^(libgamemode(auto)?\.so|libmemusage\.so|libpcprofile\.so)"

SEARCH_DIRS=(
    "$CHARD_ROOT/lib64"
    "$CHARD_ROOT/usr"
    "$CHARD_ROOT/lib"
    "$CHARD_ROOT/opt"
    "$CHARD_ROOT/var"
)

echo "${BOLD}${GREEN}Discovering libraries...${RESET}"
ALL_LIBS=()
for dir in "${SEARCH_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        while IFS= read -r -d '' lib; do
            if [[ -f "$lib" && ! -L "$lib" ]]; then
                ALL_LIBS+=("$lib")
            fi
        done < <(find "$dir" -type f -name "*.so*" -print0 2>/dev/null)
    fi
done

echo "${BOLD}${MAGENTA}Found ${#ALL_LIBS[@]} potential libraries${RESET}"
echo

test_library() {
    local lib="$1"
    local current_preload="$2"
    local temp_dir="$3"
    
    [[ -f "$lib" && -r "$lib" ]] || return
    
    local libname=$(basename "$lib")
    local result_file="$temp_dir/$(echo "$lib" | md5sum | cut -d' ' -f1).result"
    
    if [[ "$libname" =~ $EXPLICIT_BANNED_REGEX ]]; then
        echo "${RED}${BOLD}$lib${RESET}"
        echo "BANNED_EXPLICIT:$lib" > "$result_file"
        return
    fi
    
    if [[ "$libname" =~ $BANNED_REGEX ]]; then
        echo "${RED}$lib${RESET}"
        echo "BANNED:$lib" > "$result_file"
        return
    fi
    
    case ":$current_preload:" in
        *":$lib:"*) 
            echo "${BLUE}$lib${RESET}"
            echo "ALREADY_LOADED:$lib" > "$result_file"
            return
            ;;
    esac
    
    local file_output
    file_output=$(file -b "$lib" 2>/dev/null | tr -d '\0' | head -n 1)
    if ! echo "$file_output" | grep -q "ELF.*shared object"; then
        echo "${YELLOW}$lib${RESET}"
        echo "NOT_ELF:$lib" > "$result_file"
        return
    fi
    
    TEST_PRELOAD="${current_preload:+$current_preload:}$lib"
    local test_output
    test_output=$(LD_PRELOAD="$TEST_PRELOAD" $TEST_CMD 2>&1 | tr -d '\0')
    local test_exit=$?
    
    if echo "$test_output" | grep -qE "(Memory usage summary|heap total|total calls|total memory)"; then
        echo "${RED}${BOLD}$lib${RESET}"
        echo "PROFILING:$lib" > "$result_file"
        return
    fi
    
    if [[ $test_exit -eq 0 ]]; then
        echo "${GREEN}${BOLD}$lib${RESET}"
        echo "SUCCESS:$lib" > "$result_file"
    else
        echo "${RED}$lib${RESET}"
        echo "FAILED:$lib" > "$result_file"
    fi
}

export -f test_library
export TEST_CMD CURRENT_LD_PRELOAD BANNED_REGEX EXPLICIT_BANNED_REGEX
export RED GREEN YELLOW BLUE MAGENTA CYAN BOLD RESET

echo "${BOLD}${BLUE}Testing libraries: ${RESET}"
echo
printf "%s\n" "${ALL_LIBS[@]}" | \
    xargs -P "$NUM_CORES" -I {} bash -c "test_library '{}' '$CURRENT_LD_PRELOAD' '$TEMP_DIR'"

echo
echo "${BOLD}${CYAN}Collecting results...${RESET}"
LD_PRELOAD_LIBS_STAGE2=()

BANNED_COUNT=0
ALREADY_COUNT=0
NOT_ELF_COUNT=0
FAILED_COUNT=0
SUCCESS_COUNT=0

for result_file in "$TEMP_DIR"/*.result; do
    [[ -f "$result_file" ]] || continue
    
    result=$(cat "$result_file")
    status="${result%%:*}"
    lib="${result#*:}"
    
    case "$status" in
        BANNED_EXPLICIT)
            ((BANNED_COUNT++))
            ;;
        BANNED)
            ((BANNED_COUNT++))
            ;;
        ALREADY_LOADED)
            ((ALREADY_COUNT++))
            ;;
        NOT_ELF)
            ((NOT_ELF_COUNT++))
            ;;
        PROFILING)
            ((FAILED_COUNT++))
            ;;
        SUCCESS)
            LD_PRELOAD_LIBS_STAGE2+=("$lib")
            ((SUCCESS_COUNT++))
            ;;
        FAILED)
            ((FAILED_COUNT++))
            ;;
    esac
done

echo
echo "${BOLD}${CYAN}═══════════════════════════════════════${RESET}"
echo "${BOLD}${CYAN}Summary:${RESET}"
echo "  ${GREEN}Success: $SUCCESS_COUNT${RESET}"
echo "  ${BLUE}Already loaded: $ALREADY_COUNT${RESET}"
echo "  ${RED}Failed: $FAILED_COUNT${RESET}"
echo "  ${RED}Banned: $BANNED_COUNT${RESET}"
echo "  ${YELLOW}Not ELF: $NOT_ELF_COUNT${RESET}"
echo "${BOLD}${CYAN}═══════════════════════════════════════${RESET}"
echo

echo "${BOLD}${CYAN}Writing $STAGE2_FILE...${RESET}"
{
    echo "# <<< CHARD_STAGE2 <<<"
    echo "# Generated: $(date)"
    echo "# Scanned directories:"
    for dir in "${SEARCH_DIRS[@]}"; do
        echo "#   $dir"
    done
    echo "# Found ${#LD_PRELOAD_LIBS_STAGE2[@]} safe libraries"
    echo
    echo "LD_PRELOAD_LIBS_STAGE2=("
    for lib in "${LD_PRELOAD_LIBS_STAGE2[@]}"; do
        echo "    \"$lib\""
    done
    echo ")"
    echo "# <<< END CHARD_STAGE2 <<<"
} | sudo tee "$STAGE2_FILE" >/dev/null

echo
echo "${BOLD}${GREEN}Stage 2 generated with ${#LD_PRELOAD_LIBS_STAGE2[@]} new libraries!${RESET}"
echo "${BOLD}${YELLOW}Processed ${#ALL_LIBS[@]} total libraries using $NUM_CORES cores${RESET}"
echo
sleep 5

if [[ -x "$CHARD_ROOT/bin/chard_stage3_preload" ]]; then
    "$CHARD_ROOT/bin/chard_stage3_preload"
fi
