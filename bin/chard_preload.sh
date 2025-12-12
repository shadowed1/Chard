#!/bin/bash
# Chard automated safe LD_PRELOAD generator
# MUST be run outside of Chard in Host OS shell!

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

SAFE_PRELOAD_FILE="$CHARD_ROOT/.chard_safe_preload"
sudo rm -f "$SAFE_PRELOAD_FILE"
TEST_CMD="curl --version 2>/dev/null"
CURRENT_LD_PRELOAD="$LD_PRELOAD"
LD_PRELOAD_LIBS=()
BLACKLIST_REGEX="^(libc\.so|libpthread\.so|libdl\.so|libm\.so|libstdc\+\+\.so|libgcc_s\.so|libGL.*|libX11.*|libxcb.*|libbsd\.so|libc\+\+\.so)"

for lib in "$CHARD_ROOT/lib64"/*.so*; do
    [[ -f "$lib" ]] || continue
    libname=$(basename "$lib")
    [[ "$libname" =~ $BLACKLIST_REGEX ]] && continue

    case ":$CURRENT_LD_PRELOAD:" in
        *":$lib:"*) continue ;;
    esac

    if ! file "$lib" | grep -q "ELF.*shared object"; then
        echo "${YELLOW}$lib ${RESET}" #Not shared object
        continue
    fi

    LD_PRELOAD="${CURRENT_LD_PRELOAD:+$CURRENT_LD_PRELOAD:}$lib" $TEST_CMD >/dev/null 2>/dev/null
    if [[ $? -eq 0 ]]; then
        LD_PRELOAD_LIBS+=("$lib")
        echo
        echo "${GREEN}${BOLD}$lib ${RESET}"
        echo
        CURRENT_LD_PRELOAD="${CURRENT_LD_PRELOAD:+$CURRENT_LD_PRELOAD:}$lib"
    else
        echo "${RED}$lib ${RESET}" #Segfault
    fi
done

{
    echo "# <<< CHARD_SAFE_PRELOAD <<<"
    echo "# Auto-generated safe libraries. Appends to existing LD_PRELOAD."
    echo "LD_PRELOAD_LIBS_SAFE=("
    for lib in "${LD_PRELOAD_LIBS[@]}"; do
        echo "    \"$lib\""
    done
    echo ")"
    echo
    echo "for lib in \"\${LD_PRELOAD_LIBS_SAFE[@]}\"; do"
    echo "    [[ -f \"\$lib\" ]] && LD_PRELOAD=\"\${LD_PRELOAD:+\$LD_PRELOAD:}\$lib\""
    echo "done 2>/dev/null"
    echo
    echo "export LD_PRELOAD"
    echo "# <<< END CHARD_SAFE_PRELOAD <<<"
} | sudo tee "$SAFE_PRELOAD_FILE" >/dev/null

echo "${CYAN}Chard LD_PRELOAD tested ${BOLD}${${#LD_PRELOAD_LIBS[@]} libraries! ${RESET}"
