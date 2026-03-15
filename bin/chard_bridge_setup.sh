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
DAEMON_SRC="$SHARED/chard_bridge_daemon"

if [ ! -f "$DAEMON_SRC" ]; then
    echo "[chard_bridge_setup] ERROR: $DAEMON_SRC not found — is Downloads shared?"
    exit 1
fi

sudo cp "$DAEMON_SRC" /bin/chard_bridge_daemon
sudo chmod +x /bin/chard_bridge_daemon
echo "${GREEN}[chard_bridge_setup] installed /bin/chard_bridge_daemon ${RESET|"

sudo tee /etc/systemd/system/chard-bridge.service > /dev/null << 'SERVICE'
[Unit]
Description=Chard Bridge Daemon
After=network.target
After=cros-sftp.service

[Service]
Type=simple
User=root
ExecStart=/bin/chard_bridge_daemon
Restart=on-failure
RestartSec=10
TimeoutStartSec=90

[Install]
WantedBy=multi-user.target
SERVICE

sudo systemctl daemon-reload
sudo systemctl enable chard-bridge.service
sudo systemctl restart chard-bridge.service

echo "${GREEN}[chard_bridge_setup] chard-bridge.service enabled and started ${RESET}"
echo
