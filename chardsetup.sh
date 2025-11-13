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
    read -rp "Select a region number to enable its mirrors: " choice
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
echo
sed -i "${start_line},${end_line}s/^#Server/Server/" "$MIRRORLIST"
echo "Mirrors enabled successfully!"
echo
if [[ ! -f "$PACCONF" ]]; then
    echo "⚙️  pacman.conf not found — creating default config at $PACCONF..."
    cat <<'EOF' | tee "$PACCONF" >/dev/null
#
# /etc/pacman.conf
#
# See the pacman.conf(5) manpage for option and repository directives

#
# GENERAL OPTIONS
#
[options]
# The following paths are commented out with their default values listed.
#RootDir     = /
#DBPath      = /var/lib/pacman/
#CacheDir    = /var/cache/pacman/pkg/
#LogFile     = /var/log/pacman.log
#GPGDir      = /etc/pacman.d/gnupg/
#HookDir     = /etc/pacman.d/hooks/
HoldPkg     = pacman glibc
#XferCommand = /usr/bin/curl -L -C - -f -o %o %u
#XferCommand = /usr/bin/wget --passive-ftp -c -O %o %u
Architecture = auto

# Misc options
Color
VerbosePkgLists
ParallelDownloads = 5
DisableSandbox
CheckSpace
DownloadUser = alpm

# Signature verification
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional
#RemoteFileSigLevel = Required

#
# REPOSITORIES
#

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

if ! grep -q '^\[options\]' "$PACCONF"; then
    echo -e "\n[options]" >> "$PACCONF"
fi

for opt in "Color" "VerbosePkgLists" "DisableSandbox"; do
    if grep -qE "^[#[:space:]]*$opt" "$PACCONF"; then
        sed -i "s/^[#[:space:]]*$opt/$opt/" "$PACCONF"
    elif ! grep -q "^$opt" "$PACCONF"; then
        sed -i "/^\[options\]/a $opt" "$PACCONF"
    fi
done

if grep -qE "^[#[:space:]]*ParallelDownloads" "$PACCONF"; then
    sed -i "s/^[#[:space:]]*ParallelDownloads.*/ParallelDownloads = 5/" "$PACCONF"
elif ! grep -q "^ParallelDownloads" "$PACCONF"; then
    sed -i "/^\[options\]/a ParallelDownloads = 5" "$PACCONF"
fi

if grep -q "^\#\[multilib\]" "$PACCONF"; then
    sed -i '/^\#\[multilib\]/,/Include/s/^#//' "$PACCONF"
elif ! grep -q "^\[multilib\]" "$PACCONF"; then
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> "$PACCONF"
fi

echo
grep -E '^\[multilib\]|^Color|^VerbosePkgLists|^ParallelDownloads|^DisableSandbox' "$PACCONF"

pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys --keyserver hkps://keyserver.ubuntu.com --allow-weak-key-signatures
pacman -Syu --noconfirm
pacman -Syu --noconfirm make --overwrite '*'
pacman -Syu --noconfirm gcc --overwrite '*'
pacman -Syu --noconfirm rsync --overwrite '*'
