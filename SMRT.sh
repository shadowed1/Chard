#!/bin/bash
# SMRT - Smart Multithreaded Resource Taskforce

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

HOME=/$CHARD_HOME
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

PCT="${1:-${SMRT_LAST_PCT:-75}}"
if ! [[ "$PCT" =~ ^[0-9]+$ ]] || (( PCT < 1 || PCT > 100 )); then
    echo "${RED}Error: Please provide a percentage between 1 and 100${RESET}"
    exit 1
fi

REQUESTED_THREADS=$(( (TOTAL_CORES * PCT + 99) / 100 ))
(( REQUESTED_THREADS < 1 )) && REQUESTED_THREADS=1

MEM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
MEM_GB=$(( (MEM_KB + 1024*1024 - 1) / (1024*1024) ))
if (( MEM_GB <= 2 )); then
    echo "${YELLOW}Low-memory device detected (${MEM_GB} GB) — enabling single-thread mode.${RESET}"
    REQUESTED_THREADS=1
fi

ALLOCATED_CORES=$(allocate_cores $REQUESTED_THREADS)
ALLOCATED_COUNT=$(echo "$ALLOCATED_CORES" | tr ',' '\n' | wc -l)

TASKSET="taskset -c $ALLOCATED_CORES"
MAKEOPTS="-j$ALLOCATED_COUNT"

cat > "$SMRT_ENV_FILE" <<EOF
# SMRT exports
export SMRT_LAST_PCT=$PCT
export TASKSET='taskset -c $ALLOCATED_CORES'
export MAKEOPTS='-j$ALLOCATED_COUNT'
export EMERGE_DEFAULT_OPTS="--quiet-build=y --jobs=$ALLOCATED_COUNT --load-average=$ALLOCATED_COUNT"

# Aliases
EOF

parallel_build_tools=(make emerge ninja scons meson cmake)
parallel_data_tools=(tar gzip bzip2 xz rsync pigz pxz pbzip2)

for tool in "${parallel_build_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "alias $tool='${TASKSET} $tool $MAKEOPTS'" >> "$SMRT_ENV_FILE"
    fi
done

for tool in "${parallel_data_tools[@]}"; do
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
echo "${BLUE}───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────${RESET}"
echo ""
