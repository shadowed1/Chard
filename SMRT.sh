#!/bin/bash
# SMRT - Smart Multithreaded Resource Tasker (Percentage-based)

# <<< CHARD_ROOT_MARKER >>>
CHARD_ROOT=""
CHARD_HOME=""
CHARD_USER=""
# <<< END_CHARD_ROOT_MARKER >>>

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

HOME=$CHARD_HOME
SMRT_ENV_FILE="$HOME/.smrt_env.sh"

if command -v lscpu >/dev/null 2>&1 && lscpu -e=CPU,MAXMHZ >/dev/null 2>&1; then
    mapfile -t CORES < <(lscpu -e=CPU,MAXMHZ 2>/dev/null | \
        awk 'NR>1 && $2 ~ /^[0-9.]+$/ {print $1 ":" $2}' | sort -t: -k2,2n)
else
    mapfile -t CORES < <(awk -v c=-1 '
        /^processor/ {c=$3}
        /cpu MHz/ && c>=0 {print c ":" $4; c=-1}
    ' /proc/cpuinfo | sort -t: -k2,2n)
fi
TOTAL_CORES=$(nproc)

if (( ${#CORES[@]} == 0 )); then
    E_CORES_ALL=$(seq -s, 0 $((TOTAL_CORES - 1)))
    P_CORES_ALL=""
else
    mhz_values=($(printf '%s\n' "${CORES[@]}" | cut -d: -f2 | sort -n))
    count=${#mhz_values[@]}
    mid=$((count / 2))
    if (( count % 2 == 0 )); then
        threshold=$(awk "BEGIN {print (${mhz_values[mid-1]} + ${mhz_values[mid]}) / 2}")
    else
        threshold="${mhz_values[mid]}"
    fi
    E_CORES_ALL=$(printf '%s\n' "${CORES[@]}" | awk -v t="$threshold" -F: '{if ($2 <= t) print $1}' | paste -sd, -)
    P_CORES_ALL=$(printf '%s\n' "${CORES[@]}" | awk -v t="$threshold" -F: '{if ($2 > t) print $1}' | paste -sd, -)
    [[ -z "$E_CORES_ALL" ]] && { E_CORES_ALL=$(seq -s, 0 $((TOTAL_CORES - 1))); P_CORES_ALL=""; }

    E_CORES_ALL=$(echo "$E_CORES_ALL" | tr ',' '\n' | sort -n | paste -sd, -)
    P_CORES_ALL=$(echo "$P_CORES_ALL" | tr ',' '\n' | sort -n | paste -sd, -)

    if [[ -z "$ALLOCATED_CORES" ]]; then
    TASKSET=""
    else
        TASKSET="taskset -c $ALLOCATED_CORES"
    fi
fi

allocate_cores() {
    local requested_threads=$1
    local selected_cores=""
    IFS=',' read -ra E_CORE_ARRAY <<< "$E_CORES_ALL"
    IFS=',' read -ra P_CORE_ARRAY <<< "$P_CORES_ALL"
    local e_count=${#E_CORE_ARRAY[@]}
    (( requested_threads > TOTAL_CORES )) && requested_threads=$TOTAL_CORES
    (( requested_threads < 1 )) && requested_threads=1
    
    if (( requested_threads <= e_count )); then
        selected_cores=$(printf '%s,' "${E_CORE_ARRAY[@]:0:$requested_threads}" | sed 's/,$//')
    else
        selected_cores="$E_CORES_ALL"
        local remaining=$((requested_threads - e_count))
        if (( remaining > 0 )); then
            selected_cores="${selected_cores},$(printf '%s,' "${P_CORE_ARRAY[@]:0:$remaining}" | sed 's/,$//')"
        fi
    fi
    echo "$selected_cores"
}

PCT="${1:-75}" 
if ! [[ "$PCT" =~ ^[0-9]+$ ]] || (( PCT < 1 || PCT > 100 )); then
    echo "${RED}Error: Please provide a percentage between 1 and 100${RESET}"
    exit 1
fi
REQUESTED_THREADS=$(( (TOTAL_CORES * PCT + 99) / 100 ))
(( REQUESTED_THREADS < 1 )) && REQUESTED_THREADS=1
ALLOCATED_CORES=$(allocate_cores $REQUESTED_THREADS)
ALLOCATED_COUNT=$(echo "$ALLOCATED_CORES" | tr ',' '\n' | wc -l)

MEM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
MEM_GB=$(( (MEM_KB + 1024*1024 - 1) / (1024*1024) ))

if (( MEM_GB <= 1 )); then
    MEM_LIMIT_MB=128
    THREADS=1
elif (( MEM_GB <= 2 )); then
    MEM_LIMIT_MB=192
    THREADS=1
elif (( MEM_GB <= 4 )); then
    MEM_LIMIT_MB=384
    THREADS=$REQUESTED_THREADS
elif (( MEM_GB <= 8 )); then
    MEM_LIMIT_MB=768
    THREADS=$REQUESTED_THREADS
elif (( MEM_GB <= 12 )); then
    MEM_LIMIT_MB=1024
    THREADS=$REQUESTED_THREADS
elif (( MEM_GB <= 16 )); then
    MEM_LIMIT_MB=1536
    THREADS=$REQUESTED_THREADS
elif (( MEM_GB <= 24 )); then
    MEM_LIMIT_MB=2048
    THREADS=$REQUESTED_THREADS
elif (( MEM_GB <= 32 )); then
    MEM_LIMIT_MB=3072
    THREADS=$REQUESTED_THREADS
elif (( MEM_GB <= 48 )); then
    MEM_LIMIT_MB=6144
    THREADS=$REQUESTED_THREADS
elif (( MEM_GB <= 64 )); then
    MEM_LIMIT_MB=8192
    THREADS=$REQUESTED_THREADS
elif (( MEM_GB <= 96 )); then
    MEM_LIMIT_MB=12288
    THREADS=$REQUESTED_THREADS
elif (( MEM_GB <= 128 )); then
    MEM_LIMIT_MB=16384
    THREADS=$REQUESTED_THREADS
else
    MEM_LIMIT_MB=0
    THREADS=$REQUESTED_THREADS
fi

THREADS=$(( THREADS > 0 ? THREADS : 1 ))

ALLOCATED_COUNT=$(echo "$ALLOCATED_CORES" | tr ',' '\n' | wc -l)
TASKSET="taskset -c $ALLOCATED_CORES"
MAKEOPTS="-j$ALLOCATED_COUNT"

cat > "$SMRT_ENV_FILE" <<EOF
# SMRT exports
export TASKSET='taskset -c $ALLOCATED_CORES'
export MAKEOPTS='-j$ALLOCATED_COUNT'
export EMERGE_DEFAULT_OPTS="--quiet-build=y --jobs=$ALLOCATED_COUNT --load-average=$ALLOCATED_COUNT"

ulimit -v $(( MEM_LIMIT_MB * 1024 ))

# Aliases
EOF

parallel_tools=(make emerge ninja scons meson cmake tar gzip bzip2 xz rsync pigz pxz pbzip2)
for tool in "${parallel_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "alias $tool='${TASKSET} $tool $MAKEOPTS'" >> "$SMRT_ENV_FILE"
    fi
done

serial_tools=(cargo go rustc gcc g++ clang clang++ ccache waf python pip install npm yarn node gyp bazel b2 bjam dune dune-build)
for tool in "${serial_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "alias $tool='${TASKSET} $tool'" >> "$SMRT_ENV_FILE"
    fi
done

source "$SMRT_ENV_FILE"

echo "${BLUE}───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────${RESET}"
echo "${BOLD}${RED}Chard ${YELLOW}SMRT${RESET}${BOLD}${CYAN} - Allocated ${ALLOCATED_COUNT} threads (${PCT}%)${RESET}"
echo ""
echo "${BLUE}Thread Array:                    ${BOLD}${CORES[*]} ${RESET}"
echo "${CYAN}Allocated Threads:               ${BOLD}$ALLOCATED_CORES ${RESET}"
echo
[[ -n "$E_CORES_ALL" ]] && echo "${GREEN}E-Cores Available:               ${BOLD}$E_CORES_ALL ${RESET}"
[[ -n "$P_CORES_ALL" ]] && echo "${GREEN}P-Cores Available:               ${BOLD}$P_CORES_ALL ${RESET}"
echo ""
echo "${MAGENTA}Makeopts:                        ${BOLD}$MAKEOPTS ${RESET}"
echo "${MAGENTA}Taskset:                         ${BOLD}$TASKSET ${RESET}"
echo ""
echo "${YELLOW}Detected Memory:                 ${BOLD}${MEM_GB} GB ${RESET}"
if (( MEM_LIMIT_MB > 0 )); then
    echo "${YELLOW}Thread Memory Limit:             ${BOLD}${MEM_LIMIT_MB} MB ${RESET}"
else
    echo "${YELLOW}Thread Memory Limit:         ${BOLD}Unlimited ${RESET}"
fi
echo "${BLUE}───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────${RESET}"
echo ""
