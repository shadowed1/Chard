#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
SHARED="/mnt/chromeos/MyFiles/Downloads/chard_icons"
DESKTOPS_SRC="$SHARED/desktops"
DESKTOPS_DST="/usr/share/applications"
SYNC_TRIGGER="$SHARED/.sync_now"
SERVICE_NAME="chard-bridge-daemon"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
PID_FILE="/tmp/chard_bridge_daemon.pid"
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
        #echo "${BLUE}[chard_bridge_daemon] synced ${BOLD}$count${RESET} ${BLUE}icons${RESET}"
    fi
}
ensure_bridge() {
    if [ ! -f "//bin/chard_bridge" ]; then
        echo "${RED}[chard_bridge_daemon] chard_bridge not found, installing...${RESET}"
        sudo tee /bin/chard_bridge << 'BRIDGE'
#!/bin/bash
DESKTOP_FILE_ID="$1"
SHARED="/mnt/chromeos/MyFiles/Downloads/chard_icons"
[ -z "$DESKTOP_FILE_ID" ] && exit 1
touch "$SHARED/launch/$DESKTOP_FILE_ID"
BRIDGE
        sudo chmod +x /bin/chard_bridge
    fi
}
run_daemon() {
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        echo "${YELLOW}[chard_bridge_daemon] already running${RESET}"
        exit 1
    fi
    echo $$ > "$PID_FILE"
    trap 'rm -f "$PID_FILE"; exit 0' INT TERM EXIT
    echo "${CYAN}${BOLD}[chard_bridge_daemon] starting...${RESET}"
    ensure_bridge
    sync_desktops
    sync_icons
    echo "${GREEN}[chard_bridge_daemon] watching for updates...${RESET}"
    while true; do
        if [ -f "$SYNC_TRIGGER" ]; then
            rm -f "$SYNC_TRIGGER"
            sync_desktops
            sync_icons
        fi
        sleep 30
        sync_desktops
        sync_icons
    done
}
stop_daemon() {
    if [ ! -f "$PID_FILE" ]; then
        echo "${YELLOW}[chard_bridge_daemon] not running${RESET}"
        exit 1
    fi
    local pid
    pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
        kill "$pid"
        rm -f "$PID_FILE"
        echo "${GREEN}[chard_bridge_daemon] stopped${RESET}"
    else
        rm -f "$PID_FILE"
        echo "${YELLOW}[chard_bridge_daemon] stale pid removed${RESET}"
    fi
}
cmd_startup() {
    printf "${CYAN}${BOLD}Do you want chard_bridge_daemon to start automatically with Crostini? [Y/n]: ${RESET}"
    read -r answer
    case "${answer,,}" in
        ""|y|yes)
            _startup_enable
            ;;
        n|no)
            _startup_disable
            ;;
        *)
            echo
            echo "${RED}No changes made.${RESET}"
            exit 1
            ;;
    esac
}
_startup_enable() {
    local daemon_path
    daemon_path=$(command -v chard_bridge_daemon 2>/dev/null || echo "/bin/chard_bridge_daemon")
    local current_user="$USER"
    echo
    echo "${CYAN}Installing systemd service ${BOLD}${SERVICE_NAME}${RESET}${CYAN}...${RESET}"
    sudo tee "$SERVICE_FILE" > /dev/null << SERVICE
[Unit]
Description=Chard Bridge Daemon
Documentation=https://github.com/your-repo/chard
After=local-fs.target
ConditionPathExists=/mnt/chromeos/MyFiles/Downloads
[Service]
Type=simple
User=${current_user}
ExecStart=${daemon_path}
Restart=on-failure
RestartSec=5
ExecStartPre=/bin/sleep 3
StandardOutput=journal
StandardError=journal
SyslogIdentifier=chard-bridge-daemon
[Install]
WantedBy=multi-user.target
SERVICE
    echo
    sudo systemctl daemon-reload
    sudo systemctl enable "$SERVICE_NAME"
    echo
    echo "${GREEN}${BOLD}chard_bridge_daemon will now start automatically with Crostini.${RESET}"
    echo
    echo "${CYAN}To start it now without rebooting: ${BOLD}"
    echo "sudo systemctl start $SERVICE_NAME ${RESET}"
}
_startup_disable() {
    sudo systemctl stop "$SERVICE_NAME" 2>/dev/null || true
    sudo systemctl disable "$SERVICE_NAME" 2>/dev/null || true
    sudo rm -f "$SERVICE_FILE"
    sudo systemctl daemon-reload 2>/dev/null || true
}
case "${1:-}" in
    startup)
        cmd_startup
        ;;
    stop)
        stop_daemon
        ;;
    "")
        run_daemon
        ;;
    *)
        echo "Usage: $0 [startup|stop]" >&2
        echo "  (no args)  run the daemon" >&2
        echo "  startup    configure automatic startup with Crostini" >&2
        echo "  stop       stop the daemon" >&2
        exit 0
        ;;
esac
