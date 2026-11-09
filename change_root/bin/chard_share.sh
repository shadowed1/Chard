#!/bin/bash
if [ -f /mnt/shared/MyFiles/Downloads/chard_icons/chard_bridge_daemon ]; then
    sudo cp /mnt/shared/MyFiles/Downloads/chard_icons/chard_bridge_daemon /bin/
    sudo cp /mnt/shared/MyFiles/Downloads/chard_icons/chard_bridge_daemon.service /etc/systemd/system/
elif [ -f /mnt/chromeos/MyFiles/Downloads/chard_icons/chard_bridge_daemon ]; then
    sudo cp /mnt/chromeos/MyFiles/Downloads/chard_icons/chard_bridge_daemon /bin/
    sudo cp /mnt/chromeos/MyFiles/Downloads/chard_icons/chard_bridge_daemon.service /etc/systemd/system/
fi
sudo systemctl daemon-reload
sudo systemctl enable --now chard_bridge_daemon.service
sudo chmod +x /bin/chard_bridge_daemon
chard_bridge_daemon startup
chard_bridge_daemon &  
