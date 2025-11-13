#!/bin/bash
MIRRORLIST="/etc/pacman.d/mirrorlist"
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
