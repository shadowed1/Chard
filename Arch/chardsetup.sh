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

while true; do
    read -rp "Enter the best region number to enable its mirrors: " choice
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

if [[ "$ARCH" == "aarch64" ]]; then
    sed -i '/^\[multilib\]/,/Include/s/^/#/' "$PACCONF"
else
    sed -i '/^\[multilib\]/,/Include/s/^#//' "$PACCONF"
fi

grep -E '^\[multilib\]|^Color|^VerbosePkgLists|^ParallelDownloads|^DisableSandbox' "$PACCONF"

pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys --keyserver --allow-weak-key-signatures hkps://keyserver.ubuntu.com 2>/dev/null
pacman -Syu --noconfirm
pacman -Syu --noconfirm make --overwrite '*'
pacman -Syu --noconfirm gcc --overwrite '*'
pacman -Syu --noconfirm rsync --overwrite '*'
pacman -Syu --noconfirm base-devel --overwrite '*'
pacman -Syu --noconfirm ncurses --overwrite '*'
pacman -Syu --noconfirm flex --overwrite '*'
pacman -Syu --noconfirm bison --overwrite '*'
pacman -Syu --noconfirm bc --overwrite '*'
pacman -Syu --noconfirm sudo --overwrite '*'
