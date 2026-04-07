#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

detect_shared() {
if [ -d "/mnt/chromeos/MyFiles/Downloads" ]; then
echo "/mnt/chromeos/MyFiles/Downloads"
elif [ -d "/mnt/shared/MyFiles/Downloads" ]; then
echo "/mnt/shared/MyFiles/Downloads"
else
return 1
fi
}

SHARED="$(detect_shared)" || {
echo "${RED}${BOLD}[chard_bridge_daemon] ERROR:${RESET} Downloads folder is not shared with Linux."
echo "${YELLOW}Please enable sharing for Downloads in ChromeOS settings and retry.${RESET}"
exit 1
}

DESKTOPS_SRC="$SHARED/chard_icons/desktops"
DESKTOPS_DST="/usr/share/applications"
SYNC_TRIGGER="$SHARED/chard_icons/.sync_now"

SERVICE_NAME="chard-bridge-daemon"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

echo "${CYAN}${BOLD}[chard_bridge_daemon] using shared path: ${SHARED}${RESET}"

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
    echo "${GREEN}[chard_bridge_daemon] synced ${BOLD}$changed${RESET}${GREEN} desktop changes${RESET}"
fi


}

sync_icons() {
local count=0

for app_icon_dir in "$SHARED/chard_icons/icons"/*/; do
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

ensure_bridge() {
if [ ! -f "/bin/chard_bridge" ]; then
echo "${RED}[chard_bridge_daemon] installing /bin/chard_bridge...${RESET}"

    sudo tee /bin/chard_bridge << BRIDGE
#!/bin/bash
DESKTOP_FILE_ID="$1"
SHARED="$SHARED/chard_icons"

[ -z "$DESKTOP_FILE_ID" ] && exit 1

touch "$SHARED/launch/$DESKTOP_FILE_ID"
BRIDGE

    sudo chmod +x /bin/chard_bridge
fi

}

run_daemon() {
ensure_bridge
sync_desktops
sync_icons

echo
echo "${GREEN}[chard_bridge_daemon] waiting for updates...${RESET}"

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

}

cmd_startup() {
printf "${CYAN}${BOLD}Enable auto-start with Crostini? [Y/n]: ${RESET}"
read -r answer

case "${answer,,}" in
    ""|y|yes) _startup_enable ;;
    n|no)     _startup_disable ;;
    *) echo "${RED}No changes made.${RESET}"; exit 1 ;;
esac

}

_startup_enable() {
local shared_check
shared_check=$(detect_shared) || {
echo
echo "${RED}${BOLD}Cannot enable startup.${RESET}"
echo "${YELLOW}Please share your Downloads folder with Linux first.${RESET}"
exit 1
}


local daemon_path
daemon_path=$(command -v chard_bridge_daemon 2>/dev/null || echo "/bin/chard_bridge_daemon")

echo "${CYAN}Installing systemd service...${RESET}"

sudo tee "$SERVICE_FILE" > /dev/null << SERVICE
[Unit]
Description=Chard Bridge Daemon
After=local-fs.target
ConditionPathExists=${shared_check}

[Service]
Type=simple
ExecStart=${daemon_path}
Restart=always
RestartSec=5
ExecStartPre=/bin/sleep 3

[Install]
WantedBy=multi-user.target
SERVICE

sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
echo
echo "${GREEN}${BOLD}Startup enabled.${RESET}"
echo "${CYAN}Start now:${RESET} sudo systemctl start $SERVICE_NAME"

}

_startup_disable() {
sudo systemctl stop "$SERVICE_NAME" 2>/dev/null || true
sudo systemctl disable "$SERVICE_NAME" 2>/dev/null || true
sudo rm -f "$SERVICE_FILE"
sudo systemctl daemon-reload 2>/dev/null || true
echo "${YELLOW}Startup disabled.${RESET}"

}

case "${1:-}" in
startup)
cmd_startup
;;
"")
run_daemon
;;
*)
echo "Usage: $0 [startup]"
exit 1
;;
esac
