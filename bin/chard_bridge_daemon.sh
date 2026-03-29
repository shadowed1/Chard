#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

case "$1" in
    startup)
        SERVICE_DIR="$HOME/.config/systemd/user"
        SERVICE_FILE="$SERVICE_DIR/chard_bridge_daemon.service"

        mkdir -p "$SERVICE_DIR"
        echo "${GREEN}"
        read -rp "Start chard_bridge_daemon on Crostini boot? (y/n): " choice

        if [[ "$choice" =~ ^[Yy]$ ]]; then
            tee "$SERVICE_FILE" >/dev/null <<'EOF'
[Unit]
Description=chard_bridge_daemon
After=default.target

[Service]
Type=simple
ExecStart=%h/.local/bin/chard_bridge_daemon
Restart=on-failure
RestartSec=2

[Install]
WantedBy=default.target
EOF

            systemctl --user daemon-reexec
            systemctl --user daemon-reload
            systemctl --user enable chard_bridge_daemon.service
            systemctl --user start chard_bridge_daemon.service
            loginctl enable-linger "$USER" 2>/dev/null
            echo "chard_bridge_daemon will launch with Crostini ${RESET}"

        else
            systemctl --user disable chard_bridge_daemon.service 2>/dev/null
            systemctl --user stop chard_bridge_daemon.service 2>/dev/null
            rm -f "$SERVICE_FILE" 2>/dev/null
            systemctl --user daemon-reload 2>/dev/null
            echo "${RESET}${YELLOW}chard_bridge_daemon will not launch with Crostini ${RESET}"
        fi
        exit 0
        ;;
esac

DESKTOP_FILE_ID="$1"
[ -z "$DESKTOP_FILE_ID" ] && exit 1
if [ -d /mnt/chromeos/MyFiles ]; then
    BASE="/mnt/chromeos/MyFiles"
elif [ -d /mnt/shared/MyFiles ]; then
    BASE="/mnt/shared/MyFiles"
else
    exit 1
fi

SOCKET="$BASE/Downloads/chard_icons/chard.sock"
[ -S "$SOCKET" ] || exit 0
if command -v socat >/dev/null 2>&1; then
    printf "APP:%s" "$DESKTOP_FILE_ID" | socat -t 1 - UNIX-CONNECT:"$SOCKET" 2>/dev/null && exit 0
fi

python3 - "$DESKTOP_FILE_ID" "$SOCKET" <<'PY'
import socket, sys
try:
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.settimeout(1)
    sock.connect(sys.argv[2])
    sock.sendall(("APP:" + sys.argv[1]).encode())
    sock.close()
except Exception:
    pass
PY
