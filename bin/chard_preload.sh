#!/bin/bash
# Chard LD_PRELOAD
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

CHARD_ROOT="/usr/local/chard"
TEST_CMD="curl --version 2>/dev/null"

LD_PRELOAD_LIBS=()
SAFE_LIBS=()
BLACKLIST_REGEX="^(libc\.so|libpthread\.so|libdl\.so|libm\.so|libstdc\+\+\.so|libgcc_s\.so|libGL.*|libX11.*|libxcb.*|libbsd\.so|libc\+\+\.so)"

for lib in "$CHARD_ROOT/lib64"/*.so*; do
    [[ -f "$lib" ]] || continue
    libname=$(basename "$lib")
    [[ "$libname" =~ $BLACKLIST_REGEX ]] && continue
    if ! file "$lib" | grep -q "ELF.*shared object"; then
        echo "${YELLOW}Skipping $lib (not a shared object)${RESET}"
        continue
    fi
    LD_PRELOAD_LIBS+=("$lib")
done

LD_PRELOAD=""
for lib in "${LD_PRELOAD_LIBS[@]}"; do
    CANDIDATE="${LD_PRELOAD:+$LD_PRELOAD:}$lib"
    LD_PRELOAD="$CANDIDATE" $TEST_CMD >/dev/null 2>/dev/null
    if [[ $? -eq 0 ]]; then
        SAFE_LIBS+=("$lib")
        echo "${GREEN}Added $lib${RESET}"
        LD_PRELOAD="$CANDIDATE"
    else
        echo "${YELLOW}Skipping $lib (breaks command)${RESET}"
    fi
done

LD_PRELOAD=""
for lib in "${SAFE_LIBS[@]}"; do
    LD_PRELOAD="${LD_PRELOAD:+$LD_PRELOAD:}$lib"
done
export LD_PRELOAD

echo "${GREEN}CHARD_LD_PRELOAD generated ${RESET}${BOLD}${CYAN}${#SAFE_LIBS[@]}${RESET} ${GREEN}libraries ${RESET}"
