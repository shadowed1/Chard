#!/bin/bash

RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

if ! ls /.chardrc > /dev/null 2>&1; then
    echo "${RED}This script must be run inside Chard, not the ChromeOS shell.${RESET}"
    sleep 3
    exit 1
fi

if ! command -v inkscape &>/dev/null; then
    echo "${RED}inkscape is not installed. Installing Inkscape${RESET}"
    sleep 3
    sudo pacman -S --noconfirm inkscape 2>/dev/null
    sudo -E emerge -S inkscape 2>/dev/null
fi

ICON_ROOTS=(
    "/usr/share/icons/hicolor"
    "$HOME/.local/share/flatpak/exports/share/icons/hicolor"
)

ICONS_PIXMAPS="/usr/share/pixmaps"
SIZES=(16 32 48 64 96 128)

PROCESSED_FILE="$HOME/.chard_processed_svgs"
touch "$PROCESSED_FILE"

converted=0
skipped=0
failed=0

echo "${CYAN}${BOLD}Converting SVG icons to PNG for ChromeOS compatibility...${RESET}"
echo

already_processed() {
    grep -Fxq "$1" "$PROCESSED_FILE"
}

convert_svg() {
    local src="$1"
    local dest="$2"
    local size="$3"

    [ -f "$dest" ] && return 0

    mkdir -p "$(dirname "$dest")"

    timeout 10s inkscape \
        --export-type=png \
        --export-width="$size" \
        --export-height="$size" \
        --export-filename="$dest" \
        "$src" >/dev/null 2>&1

    case $? in
        0)
            converted=$((converted + 1))
            return 0
            ;;
        124)
            echo "  ${RED}Timed out:${RESET} $(basename "$src")"
            ;;
        *)
            echo "  ${RED}Failed:${RESET} $(basename "$src")"
            ;;
    esac

    failed=$((failed + 1))
    return 1
}

echo
echo "${CYAN}Processing scalable icons${RESET}"
echo
for root in "${ICON_ROOTS[@]}"; do
    [ -d "$root/scalable/apps" ] || continue

    while IFS= read -r -d '' svg; do

        if already_processed "$svg"; then
            continue
        fi

        icon_name=$(basename "$svg" .svg)

        for size in "${SIZES[@]}"; do
            dest="$root/${size}x${size}/apps/${icon_name}.png"
            [ -f "$dest" ] && { skipped=$((skipped + 1)); continue; }

            printf "  ${YELLOW}%-40s${RESET} ${GREEN}->${RESET} ${BLUE}%sx%s${RESET}\n" \
                "$icon_name" "$size" "$size"

            if ! convert_svg "$svg" "$dest" "$size"; then
                break
            fi
        done

        echo "$svg" >> "$PROCESSED_FILE"

    done < <(find "$root/scalable/apps" -name "*.svg" -print0 2>/dev/null)
done

echo
echo "${CYAN}Processing sized icon directories...${RESET}"

for size in "${SIZES[@]}"; do
    dir="$ICONS_HICOLOR/${size}x${size}/apps"
    [ -d "$dir" ] || continue

    while IFS= read -r -d '' svg; do

        if already_processed "$svg"; then
            continue
        fi

        icon_name=$(basename "$svg" .svg)
        dest="$dir/${icon_name}.png"

        [ -f "$dest" ] && { skipped=$((skipped + 1)); continue; }

        printf "  ${YELLOW}%-40s${RESET} ${GREEN}->${RESET} ${YELLOW}%sx%s${RESET}\n" \
            "$icon_name" "$size" "$size"

        convert_svg "$svg" "$dest" "$size"

        echo "$svg" >> "$PROCESSED_FILE"

    done < <(find "$dir" -maxdepth 1 -name "*.svg" -print0 2>/dev/null)
done

echo
echo "${CYAN}Processing pixmap icons:${RESET}"
while IFS= read -r -d '' svg; do
    icon_name=$(basename "$svg" .svg)
    dest="$ICONS_PIXMAPS/${icon_name}.png"
    [ -f "$dest" ] && { skipped=$((skipped + 1)); continue; }
    printf "  ${YELLOW}%-40s${RESET} ${RESET}${GREEN}->${RESET}${BLUE} pixmaps (128px)\n${RESET}" "$icon_name"
    convert_svg "$svg" "$dest" 128
done < <(find "$ICONS_PIXMAPS" -maxdepth 1 -name "*.svg" -print0 2>/dev/null)

echo
echo "${RESET}${GREEN}Converted:           ${BOLD}${GREEN}$converted${RESET}"
echo "${MAGENTA}Already existed:     ${BOLD}${MAGENTA}$skipped${RESET}"
echo "${RED}Failed:              ${BOLD}${RED}$failed${RESET}"
echo
