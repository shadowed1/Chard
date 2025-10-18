#!/bin/bash
# SMRT - Smart Multithreaded Resource Tasker
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

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
    
    E_CORES_ALL=$(printf '%s\n' "${CORES[@]}" | \
        awk -v t="$threshold" -F: '{if ($2 <= t) print $1}' | paste -sd, -)
    P_CORES_ALL=$(printf '%s\n' "${CORES[@]}" | \
        awk -v t="$threshold" -F: '{if ($2 > t) print $1}' | paste -sd, -)
    
    if [[ -z "$E_CORES_ALL" ]]; then
        E_CORES_ALL=$(seq -s, 0 $((TOTAL_CORES - 1)))
        P_CORES_ALL=""
    fi
fi

MEM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
MEM_GB=$(( MEM_KB / 1024 / 1024 ))

allocate_cores() {
    local requested_threads=$1
    local selected_cores=""
    
    IFS=',' read -ra E_CORE_ARRAY <<< "$E_CORES_ALL"
    IFS=',' read -ra P_CORE_ARRAY <<< "$P_CORES_ALL"
    
    local e_count=${#E_CORE_ARRAY[@]}
    local p_count=${#P_CORE_ARRAY[@]}
    
    (( requested_threads > TOTAL_CORES )) && requested_threads=$TOTAL_CORES
    (( requested_threads < 1 )) && requested_threads=1
    
    if (( requested_threads <= e_count )); then
        selected_cores=$(printf '%s,' "${E_CORE_ARRAY[@]:0:$requested_threads}" | sed 's/,$//')
    else
        selected_cores="$E_CORES_ALL"
        local remaining=$((requested_threads - e_count))
        
        if [[ -n "$P_CORES_ALL" ]] && (( remaining > 0 )); then
            local p_cores_needed=$(printf '%s,' "${P_CORE_ARRAY[@]:0:$remaining}" | sed 's/,$//')
            selected_cores="${selected_cores},${p_cores_needed}"
        fi
    fi
    
    echo "$selected_cores"
}

if [[ -z "$1" ]]; then
    AUTO_THREADS=$((MEM_GB / 2))
    ((AUTO_THREADS < 1)) && AUTO_THREADS=1
    
    if [[ -n "$E_CORES_ALL" ]]; then
        ECORE_COUNT=$(echo "$E_CORES_ALL" | tr ',' '\n' | wc -l)
        ECORE_RATIO=$(awk "BEGIN {print $ECORE_COUNT / $TOTAL_CORES}")
        if (( $(awk "BEGIN {print ($ECORE_RATIO >= 0.65)}") )); then
            AUTO_THREADS=$(awk -v t="$AUTO_THREADS" 'BEGIN {printf("%d", t * 2.25)}')
        fi
    fi
    
    ALLOCATED_CORES=$(allocate_cores $AUTO_THREADS)
    ALLOCATED_COUNT=$(echo "$ALLOCATED_CORES" | tr ',' '\n' | wc -l)
    
    echo "${BLUE}──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────${RESET}"
    echo "${BOLD}${RED}Chard ${YELLOW}SMRT${RESET}${BOLD}${MAGENTA} - $REQUESTED_THREADS threads${RESET}"
    echo ""
    echo "${BLUE}Thread Array:                    ${BOLD}${CORES[*]} ${RESET}"
    echo "${GREEN}E-Cores Available:               ${BOLD}$E_CORES_ALL ${RESET}"
    if [[ -n "$P_CORES_ALL" ]]; then
        echo "${CYAN}P-Cores Available:               ${BOLD}$P_CORES_ALL ${RESET}"
    fi
    if (( ALLOCATED_COUNT != REQUESTED_THREADS )); then
            echo "${YELLOW}Requested $REQUESTED_THREADS threads, allocated $ALLOCATED_COUNT (max available)${RESET}"
        fi
    echo ""
    echo "${GREEN}Detected Memory:                 ${BOLD}${MEM_GB} GB ${RESET}"
    echo "${GREEN}Allocated Threads:               ${BOLD}$ALLOCATED_CORES ${RESET}"
    echo ""
    echo "${MAGENTA}Makeopts:                        ${BOLD}-j$ALLOCATED_COUNT ${RESET}"
    echo "${MAGENTA}Taskset:                         ${BOLD}taskset -c $ALLOCATED_CORES ${RESET}"
    echo
    echo "${YELLOW}Example: SMRT $E_CORES_ALL to allocate specific thread count${RESET}"
    echo "${BLUE}──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────${RESET}"
    echo ""
else
    REQUESTED_THREADS=$1
    
    if ! [[ "$REQUESTED_THREADS" =~ ^[0-9]+$ ]]; then
        echo "${RED}Error: Please provide a valid number of threads${RESET}"
        exit 1
    fi
    
    ALLOCATED_CORES=$(allocate_cores $REQUESTED_THREADS)
    ALLOCATED_COUNT=$(echo "$ALLOCATED_CORES" | tr ',' '\n' | wc -l)
    
    export TASKSET="taskset -c $ALLOCATED_CORES"
    export MAKEOPTS="-j$ALLOCATED_COUNT"
    
    parallel_tools=(make emerge ninja scons meson cmake tar gzip bzip2 xz rsync pigz pxz pbzip2)
    for tool in "${parallel_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            alias "$tool"="$TASKSET $tool $MAKEOPTS"
        fi
    done
    
    serial_tools=(cargo go rustc gcc g++ clang clang++ ccache waf python pip install npm yarn node gyp bazel b2 bjam dune dune-build)
    for tool in "${serial_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            alias "$tool"="$TASKSET $tool"
        fi
    done
    
    if [[ -t 1 ]]; then
       echo "${BLUE}──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────${RESET}"
        echo "${BOLD}${RED}Chard ${YELLOW}SMRT${RESET}${BOLD}${MAGENTA} - $REQUESTED_THREADS threads${RESET}"
        echo ""
        echo "${BLUE}Thread Array:                    ${BOLD}${CORES[*]} ${RESET}"
        echo "${GREEN}E-Cores Available:               ${BOLD}$E_CORES_ALL ${RESET}"
        if [[ -n "$P_CORES_ALL" ]]; then
            echo "${CYAN}P-Cores Available:               ${BOLD}$P_CORES_ALL ${RESET}"
        fi
        if (( ALLOCATED_COUNT != REQUESTED_THREADS )); then
                echo "${YELLOW}Requested $REQUESTED_THREADS threads, allocated $ALLOCATED_COUNT (max available)${RESET}"
            fi
        echo ""
        echo "${GREEN}Detected Memory:                 ${BOLD}${MEM_GB} GB ${RESET}"
        echo "${GREEN}Allocated Threads:               ${BOLD}$ALLOCATED_CORES ${RESET}"
        echo ""
        echo "${MAGENTA}Makeopts:                        ${BOLD}-j$ALLOCATED_COUNT ${RESET}"
        echo "${MAGENTA}Taskset:                         ${BOLD}taskset -c $ALLOCATED_CORES ${RESET}"
        echo
        echo "${YELLOW}Example: SMRT $ALLOCATED_COUNT to allocate specific thread count${RESET}"
        echo "${BLUE}──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────${RESET}"
        echo ""
        if (( ALLOCATED_COUNT != REQUESTED_THREADS )); then
            echo "${YELLOW}Requested $REQUESTED_THREADS threads, allocated $ALLOCATED_COUNT (max available)${RESET}"
        fi
    fi
fi
