#!/bin/bash

# <<< CHARD_ROOT_MARKER >>>
CHARD_ROOT=""
CHARD_HOME=""
CHARD_USER=""
# <<< END_CHARD_ROOT_MARKER >>>

HOME=/$CHARD_HOME
USER=$CHARD_USER

MIRRORLIST="/etc/pacman.d/mirrorlist"
PACCONF="${PACCONF:-/etc/pacman.conf}"
ARCH=$(uname -m)

retry_pacman() {
    local max_retries=10
    local retry_count=0
    local wait_time=5
    local cmd="$@"
    
    while [ $retry_count -lt $max_retries ]; do
        echo "${CYAN}Attempt $((retry_count + 1)) / $max_retries: Running pacman...${RESET}"
        
        if eval "$cmd"; then
            echo "${GREEN}Package operation succeeded${RESET}"
            return 0
        else
            retry_count=$((retry_count + 1))
            
            if [ $retry_count -lt $max_retries ]; then
                echo "${YELLOW}Attempt $retry_count failed. Waiting ${wait_time}s before retry...${RESET}"
                sleep $wait_time
                
                wait_time=$((wait_time * 2))
                if [ $wait_time -gt 60 ]; then
                    wait_time=60
                fi
                
                echo "${CYAN}Refreshing package database...${RESET}"
                pacman -Syy --noconfirm 2>/dev/null || true
                pacman -Fy --noconfirm 2>/dev/null
            else
                echo "${RED}$max_retries attempts failed. Skipping this package.${RESET}"
                return 1
            fi
        fi
    done
    
    return 1
}

[[ -f "$MIRRORLIST" ]] || { echo "Mirrorlist not found: $MIRRORLIST"; exit 1; }

mapfile -t countries < <(grep -n '^## ' "$MIRRORLIST" | sed 's/:## /:/')
echo "Available mirror regions:"
for i in "${!countries[@]}"; do
    line="${countries[$i]}"
    linenum="${line%%:*}"
    name="${line#*:}"
    printf " [%2d] %s\n" "$((i+1))" "$name"
done
echo

ARCH=$(uname -m)
if [[ "$ARCH" == "aarch64" ]]; then
    default_choice=1
else
    default_choice=3
fi

echo "Default mirror will be auto-selected in 15 seconds."
while true; do
    read -t 15 -rp "Enter a region number to enable its mirrors [default: $default_choice]: " choice

    choice=${choice:-$default_choice}

    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#countries[@]} )); then
        break
    fi
    echo "Invalid choice. Please enter a number between 1 and ${#countries[@]}."
done

start_line=$(echo "${countries[$((choice-1))]}" | cut -d: -f1)
end_line=$(grep -n '^## ' "$MIRRORLIST" | awk -v s=$start_line -F: '$1 > s {print $1; exit}')
[[ -z "$end_line" ]] && end_line=$(wc -l < "$MIRRORLIST")

echo
echo "Enabling mirrors for region: $(echo "${countries[$((choice-1))]}" | cut -d: -f2-)"
echo "   Lines $start_line → $end_line"
sed -i "${start_line},${end_line}s/^#Server/Server/" "$MIRRORLIST"
echo "Mirrors enabled successfully!"
echo

if [[ ! -f "$PACCONF" ]]; then
    echo "pacman.conf not found — creating default config at $PACCONF..."
    cat <<'EOF' | tee "$PACCONF" >/dev/null
[options]
HoldPkg     = pacman glibc
Architecture = auto
Color
VerbosePkgLists
ParallelDownloads = 5
DisableSandbox
CheckSpace
DownloadUser = alpm
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
    echo "Created new $PACCONF with defaults."
fi

echo "Enabling key pacman options..."

for opt in "Color" "VerbosePkgLists" "DisableSandbox" "ParallelDownloads = 5"; do
    if grep -qE "^[#[:space:]]*${opt%%=*}" "$PACCONF"; then
        sed -i "s/^[#[:space:]]*${opt%%=*}.*/$opt/" "$PACCONF"
    elif ! grep -q "^${opt%%=*}" "$PACCONF"; then
        sed -i "/^\[options\]/a $opt" "$PACCONF"
    fi
done

if [[ "$ARCH" == "x86_64" ]]; then
    echo "Enabling multilib..."
    sed -i '/^#\?\[multilib\]/,/^#\?Include/ s/^#//' "$PACCONF"
else
    echo "Disabling multilib for non-x86 systems..."
    sed -i '/^#\?\[multilib\]/,/^#\?Include/ s/^/#/' "$PACCONF"
fi

grep -E '^\[multilib\]|^Color|^VerbosePkgLists|^ParallelDownloads|^DisableSandbox' "$PACCONF"
pacman-key --init
if [ "$(uname -m)" = "aarch64" ]; then
    pacman-key --populate archlinuxarm
else
    pacman-key --populate archlinux
fi
pacman-key --refresh-keys --keyserver --allow-weak-key-signatures hkps://keyserver.ubuntu.com 2>/dev/null
pacman -Syu --noconfirm
retry_pacman "pacman -Syu --noconfirm make"
retry_pacman "pacman -Syu --noconfirm gcc"
retry_pacman "pacman -Syu --noconfirm rsync"
retry_pacman "pacman -Syu --noconfirm base-devel"
retry_pacman "pacman -Syu --noconfirm ncurses"
retry_pacman "pacman -Syu --noconfirm flex"
retry_pacman "pacman -Syu --noconfirm bison"
retry_pacman "pacman -Syu --noconfirm bc"
retry_pacman "pacman -Syu --noconfirm sudo"
retry_pacman "pacman -Fy --noconfirm"
