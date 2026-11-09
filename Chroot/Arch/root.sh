#!/bin/bash
export PATH=/usr/local/bubblepatch/bin:$PATH
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
USER_ID=1000
GROUP_ID=1000
export STEAM_USER_HOME="$HOME/.local/share/Steam"

source ~/.bashrc
xhost +SI:localuser:root

sudo setfacl -Rm u:root:rwx /run/chrome 2>/dev/null
sudo setfacl -Rm u:1000:rwx /run/chrome 2>/dev/null

if [ $# -eq 0 ]; then
    echo "Example: root [app] --argument"
    sudo setfacl -Rb /run/chrome 2>/dev/null
    exit 1
fi

sudo -i /usr/bin/env bash -c 'exec "$@"' -- "$@"
sudo setfacl -Rb /run/chrome 2>/dev/null
