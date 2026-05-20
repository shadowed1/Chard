#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

if ! ls /.chardrc > /dev/null 2>&1; then
    echo "${RED}This script must be run inside Chard, not the ChromeOS shell.${RESET}"
    sleep 3
    exit 1
fi

if ! command -v inkscape &>/dev/null; then
    echo "${RED}inkscape is not installed. If Arch:   sudo pacman -S --noconfirm inkscape${RESET}"
    echo "${RED}inkscape is not installed. If Gentoo: sudo emerge inkscape${RESET}"
    exit 1
fi

ICONS_HICOLOR="/usr/share/icons/hicolor"
ICONS_PIXMAPS="/usr/share/pixmaps"
SIZES=(16 32 48 64 96 128)
converted=0
skipped=0
failed=0

echo "${CYAN}${BOLD}Converting SVG icons to PNG for ChromeOS compatibility...${RESET}"
echo

convert_svg() {
    local src="$1"
    local dest="$2"
    local size="$3"

    if [ -f "$dest" ]; then
        skipped=$((skipped + 1))
        return 0
    fi

    mkdir -p "$(dirname "$dest")"

    if inkscape \
        --export-type=png \
        --export-width="$size" \
        --export-height="$size" \
        --export-filename="$dest" \
        "$src" > /dev/null 2>&1; then
        converted=$((converted + 1))
    else
        echo "  ${RED}Failed:${RESET} $(basename "$src") → ${size}x${size}"
        failed=$((failed + 1))
        return 1
    fi
}

echo "${CYAN}Processing scalable icons...${RESET}"
while IFS= read -r -d '' svg; do
    icon_name=$(basename "$svg" .svg)
    for size in "${SIZES[@]}"; do
        dest="$ICONS_HICOLOR/${size}x${size}/apps/${icon_name}.png"
        [ -f "$dest" ] && { skipped=$((skipped + 1)); continue; }
        printf "  ${YELLOW}%-40s${RESET} → %sx%s\n" "$icon_name" "$size" "$size"
        convert_svg "$svg" "$dest" "$size"
    done
done < <(find "$ICONS_HICOLOR/scalable/apps" -name "*.svg" -print0 2>/dev/null)

echo "${CYAN}Processing sized icon directories...${RESET}"
for size in "${SIZES[@]}"; do
    dir="$ICONS_HICOLOR/${size}x${size}/apps"
    [ -d "$dir" ] || continue
    while IFS= read -r -d '' svg; do
        icon_name=$(basename "$svg" .svg)
        dest="$dir/${icon_name}.png"
        [ -f "$dest" ] && { skipped=$((skipped + 1)); continue; }
        printf "  ${YELLOW}%-40s${RESET} → %sx%s\n" "$icon_name" "$size" "$size"
        convert_svg "$svg" "$dest" "$size"
    done < <(find "$dir" -maxdepth 1 -name "*.svg" -print0 2>/dev/null)
done

echo "${CYAN}Processing pixmap icons...${RESET}"
while IFS= read -r -d '' svg; do
    icon_name=$(basename "$svg" .svg)
    dest="$ICONS_PIXMAPS/${icon_name}.png"
    [ -f "$dest" ] && { skipped=$((skipped + 1)); continue; }
    printf "  ${YELLOW}%-40s${RESET} → pixmaps (128px)\n" "$icon_name"
    convert_svg "$svg" "$dest" 128
done < <(find "$ICONS_PIXMAPS" -maxdepth 1 -name "*.svg" -print0 2>/dev/null)

echo
echo "${GREEN}${BOLD}Done.${RESET} Converted: ${GREEN}$converted${RESET}, Already existed: ${YELLOW}$skipped${RESET}, Failed: ${RED}$failed${RESET}"
echo

if [ "$converted" -gt 0 ]; then
    echo "${CYAN}Now run ${BOLD}chard_shortcut${RESET}${CYAN} from the ChromeOS shell to register the apps.${RESET}"
fi
