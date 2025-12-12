#!/bin/bash
# Test Script to attempt an Automatic LD_PRELOAD ARRAY
CANDIDATE_LIB_DIR="$CHARD_ROOT/lib64"
SAFE_PRELOAD_FILE="$CHARD_ROOT/.chard_safe_preload"
BLACKLIST_REGEX="^(libc\.so|libpthread\.so|libdl\.so|libm\.so|libstdc\+\+\.so|libgcc_s\.so)"

TEST_COMMANDS=(
    "/bin/true"
    "ls /"
    "file /bin/ls"
    "ldd /bin/bash"
    "curl --version 2>/dev/null"
)

LD_PRELOAD_LIBS=()
for lib in "$CANDIDATE_LIB_DIR"/*.so*; do
    [[ -f "$lib" ]] || continue
    libname=$(basename "$lib")
    [[ "$libname" =~ $BLACKLIST_REGEX ]] && continue
    file "$lib" | grep -q "ELF.*shared object" || continue
    LD_PRELOAD_LIBS+=("$lib")
done

SAFE_LIBS=()
LD_PRELOAD=""

echo "Testing ${#LD_PRELOAD_LIBS[@]} candidate libraries..."
for lib in "${LD_PRELOAD_LIBS[@]}"; do
    CANDIDATE="${LD_PRELOAD:+$LD_PRELOAD:}$lib"
    ALL_OK=true

    for cmd in "${TEST_COMMANDS[@]}"; do
        output=$(LD_PRELOAD="$CANDIDATE" bash -c "$cmd" 2>&1)
        exitcode=$?
        if [[ $exitcode -ne 0 ]]; then
            if echo "$output" | grep -q "invalid ELF header"; then
                echo "Skipping $lib (invalid ELF for preload)"
            else
                echo "Skipping $lib (breaks command: $cmd)"
            fi
            ALL_OK=false
            break
        fi
    done

    if $ALL_OK; then
        SAFE_LIBS+=("$lib")
        LD_PRELOAD="$CANDIDATE"
    fi
done

printf "%s\n" "${SAFE_LIBS[@]}" | sudo tee "$SAFE_PRELOAD_FILE" >/dev/null
echo "Safe LD_PRELOAD list saved to $SAFE_PRELOAD_FILE with ${#SAFE_LIBS[@]} libraries"

export LD_PRELOAD=$(IFS=:; echo "${SAFE_LIBS[*]}")
