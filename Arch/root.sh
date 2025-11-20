#!/bin/bash
export PATH=/usr/local/bubblepatch/bin:$PATH
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
USER_ID=1000
GROUP_ID=1000
export STEAM_USER_HOME="$HOME/.local/share/Steam"

[ -f ~/.bashrc ] && source ~/.bashrc
xhost +SI:localuser:root

sudo setfacl -Rm u:root:rwx /run/chrome 2>/dev/null
sudo setfacl -Rm u:1000:rwx /run/chrome 2>/dev/null

if [ $# -eq 0 ]; then
    echo "Example: root flatpak list"
    sudo setfacl -Rb /run/chrome 2>/dev/null
    exit 1
fi

sudo -i /usr/bin/env bash -c 'exec "$@"' -- "$@"
sudo setfacl -Rb /run/chrome 2>/dev/null

####

#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
HOME=/$CHARD_HOME
USER=$CHARD_USER
PATH=/usr/local/bubblepatch/bin:$PATH
export STEAM_USER_HOME="$HOME/.local/share/Steam"
USER_ID=1000
GROUP_ID=1000
xhost +SI:localuser:root
source ~/.bashrc
sudo -u $CHARD_USER /usr/bin/env bash -c 'exec "$@"' -- "$@"

