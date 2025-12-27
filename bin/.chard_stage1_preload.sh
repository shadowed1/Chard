#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo
echo "${BOLD}${BLUE}Chard Stage 1 Preload${RESET}"
echo

STAGE1_FILE="$CHARD_ROOT/.chard_stage1_preload"
sudo rm -f "$STAGE1_FILE" 2>/dev/null

TEST_CMD_CURL="curl --version"
TEST_CMD_COREUTILS="/usr/bin/coreutils --coreutils-prog=echo ''"

LD_PRELOAD_LIBS_STAGE1=()

BANNED_REGEX="^(libc\.so|libpthread\.so|libdl\.so|libm\.so|libstdc\+\+\.so|libgcc_s\.so|libGL.*|libX11.*|libxcb.*|libbsd\.so|libc\+\+\.so)"
EXPLICIT_BANNED_REGEX="^(libgamemode(auto)?\.so|libmemusage\.so|libpcprofile\.so)"

echo "${BOLD}${CYAN}Scanning libraries...${RESET}"
echo
sleep 5

for lib in \
    "$CHARD_ROOT/lib64"/*.so* \
    "$CHARD_ROOT/lib"/*.so* \
    "$CHARD_ROOT/opt"/*.so* \
    "$CHARD_ROOT/usr/lib"/*.so* \
    "$CHARD_ROOT/usr/lib64"/*.so*; do

    [[ -e "$lib" ]] || continue
    libname=$(basename "$lib")

    if [[ "$libname" =~ $EXPLICIT_BANNED_REGEX ]]; then
        echo "${RED}${BOLD}$lib${RESET}"
        continue
    fi

    if [[ "$libname" =~ $BANNED_REGEX ]]; then
        echo "${RED}$lib${RESET}"
        continue
    fi

    case ":$CURRENT_LD_PRELOAD:" in
        *":$lib:"*) echo "${BLUE}$lib${RESET}" ; continue ;;
    esac

    if ! head -c 4 "$lib" 2>/dev/null | grep -q $'\x7fELF'; then
        echo "${YELLOW}x$lib${RESET}"
        continue
    fi

    if ! LD_PRELOAD="$lib" $TEST_CMD_CURL >/dev/null 2>&1; then
        echo "${RED}$lib${RESET}"
        continue
    fi

    if ! LD_PRELOAD="$lib" $TEST_CMD_COREUTILS >/dev/null 2>&1; then
        echo "${RED}$lib${RESET}"
        continue
    fi

    LD_PRELOAD_LIBS_STAGE1+=("$lib")
    echo "${GREEN}${BOLD}$lib${RESET}"

done

echo
echo "${BOLD}${CYAN}source $STAGE1_FILE${RESET}"

{
    echo "# <<< CHARD_STAGE1 <<<"
    echo "# Generated: $(date)"
    echo
    echo "LD_PRELOAD_LIBS_STAGE1=("
    for lib in "${LD_PRELOAD_LIBS_STAGE1[@]}"; do
        echo "    \"$lib\""
    done
    echo ")"
    echo
    echo 'LD_PRELOAD=""'
    echo 'for lib in "${LD_PRELOAD_LIBS_STAGE1[@]}"; do'
    echo '    [[ -f "$lib" ]] && LD_PRELOAD="${LD_PRELOAD:+$LD_PRELOAD:}$lib"'
    echo 'done'
    echo 'export LD_PRELOAD'
    echo "# <<< END CHARD_STAGE1 <<<"
} | sudo tee "$STAGE1_FILE" >/dev/null

echo
echo "${BOLD}${GREEN}Stage 1 generated with ${#LD_PRELOAD_LIBS_STAGE1[@]} libraries${RESET}"
echo
