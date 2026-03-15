#!/bin/bash
# This daemon runs in Crostini - syncs Chard desktop stubs to garcon
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

SHARED="/mnt/chromeos/MyFiles/Downloads/chard_icons"
DESKTOPS_SRC="$SHARED/desktops"
DESKTOPS_DST="/usr/share/applications"
SYNC_TRIGGER="$SHARED/.sync_now"

echo "${CYAN}${BOLD}[chard_bridge_daemon] starting...${RESET}"

sync_desktops() {
    local changed=0
    for df in "$DESKTOPS_SRC"/chard-*.desktop; do
        [ -f "$df" ] || continue
        local name=$(basename "$df")
        if ! diff -q "$df" "$DESKTOPS_DST/$name" > /dev/null 2>&1; then
            sudo cp "$df" "$DESKTOPS_DST/$name"
            sudo chmod 644 "$DESKTOPS_DST/$name"
            changed=$((changed+1))
        fi
    done

    for installed in "$DESKTOPS_DST"/chard-*.desktop; do
        [ -f "$installed" ] || continue
        local name=$(basename "$installed")
        if [ ! -f "$DESKTOPS_SRC/$name" ]; then
            sudo rm -f "$installed"
            changed=$((changed+1))
            echo "${YELLOW}[chard_bridge_daemon] removed stale stub: ${BOLD}$name ${RESET}"
        fi
    done

    if [ $changed -gt 0 ]; then
        sudo update-desktop-database "$DESKTOPS_DST" 2>/dev/null
        echo "${GREEN}[chard_bridge_daemon] synced ${BOLD}$changed${RESET}${GREEN} desktop changes - garcon re-registering ${RESET}"
    fi
}
# Doing .png's only right now but I bet we can convert easily
sync_icons() {
    local count=0
    for app_icon_dir in "$SHARED/icons"/*/; do
        [ -d "$app_icon_dir" ] || continue
        local icon_name_file="$app_icon_dir/.icon_name"
        [ -f "$icon_name_file" ] || continue
        local icon_name=$(cat "$icon_name_file")
        for size in 16 32 48 64 96 128; do
            local src="$app_icon_dir/${size}.png"
            [ -f "$src" ] || continue
            local dst_dir="/usr/share/icons/hicolor/${size}x${size}/apps"
            sudo mkdir -p "$dst_dir"
            local dst="$dst_dir/${icon_name}.png"
            if [ ! -f "$dst" ] || ! diff -q "$src" "$dst" > /dev/null 2>&1; then
                sudo cp "$src" "$dst"
                count=$((count+1))
            fi
        done
    done
    if [ $count -gt 0 ]; then
        sudo gtk-update-icon-cache /usr/share/icons/hicolor 2>/dev/null || true
        echo "${BLUE}[chard_bridge_daemon] synced ${BOLD}$count${RESET} ${BLUE}icons${RESET}"
    fi
}

if [ ! -f "/usr/local/bin/chard_bridge" ]; then
    echo "${RED}[chard_bridge_daemon] chard_bridge not found, installing...${RESET}"
    sudo tee /usr/local/bin/chard_bridge << 'BRIDGE'
#!/bin/bash
DESKTOP_FILE_ID="$1"
SHARED="/mnt/chromeos/MyFiles/Downloads/chard_icons"
[ -z "$DESKTOP_FILE_ID" ] && exit 1
touch "$SHARED/launch/$DESKTOP_FILE_ID"
BRIDGE
    sudo chmod +x /usr/local/bin/chard_bridge
fi

sync_desktops
sync_icons

echo "${GREEN}[chard_bridge_daemon] watching for updates...${RESET}"

while true; do
    if [ -f "$SYNC_TRIGGER" ]; then
        rm -f "$SYNC_TRIGGER"
        sync_desktops
        sync_icons
    fi
    sleep 10
    sync_desktops
    sync_icons
done
