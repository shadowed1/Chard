#!/bin/bash
# Run in Crostini
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
SHARED="/mnt/chromeos/MyFiles/Downloads/chard_icons"
DESKTOPS_SRC="$SHARED/desktops"
DESKTOPS_DST="/usr/share/applications"
INSTALLED_LOG="$SHARED/.installed_desktops"
echo "${CYAN}${BOLD}[chard_bridge_daemon] starting...${RESET}"
sync_desktops() {
    local count=0
    for df in "$DESKTOPS_SRC"/chard-*.desktop; do
        [ -f "$df" ] || continue
        name=$(basename "$df")
        if ! diff -q "$df" "$DESKTOPS_DST/$name" > /dev/null 2>&1; then
            sudo cp "$df" "$DESKTOPS_DST/$name"
            sudo chmod 644 "$DESKTOPS_DST/$name"
            count=$((count+1))
        fi
    done
    [ $count -gt 0 ] && sudo update-desktop-database "$DESKTOPS_DST" 2>/dev/null
    echo "[chard_bridge_daemon] synced $count desktop stubs"
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
echo "${GREEN}[chard_bridge_daemon] watching $DESKTOPS_SRC for updates...${RESET}"
while true; do
    sync_desktops
    sleep 5
done
