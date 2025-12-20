#!/bin/bash
# Version 1.0 
# chard_garcon 
# Author: Days

export PATH="/usr/bin:/bin:/usr/local/bin:/sbin:/usr/sbin:$PATH"
WATCH_DIR="/home/chronos/user/MyFiles/chard/"

declare -A APPS=(
    [xfce4-terminal]="sudo -u chronos /bin/bash -c '
        # Source DBUS session for preference sync
        [ -f /tmp/chard_dbus_session ] && source /tmp/chard_dbus_session 2>/dev/null
        
        # Environment setup matching auto-launched / upstart xfce4-terminal from chard.sh
        export HOME=/home/chronos
        export USER=chronos
        export XDG_DATA_DIRS=/usr/local/share:/usr/share
        export XDG_RUNTIME_DIR=/tmp/chard_runtime
        export DISPLAY=:0
        export GDK_BACKEND=x11
        
        # Source user bashrc for PATH and aliases
        [ -f /home/chronos/.bashrc ] && source /home/chronos/.bashrc 2>/dev/null
        
        # Launch terminal with matching flags
        xfce4-terminal --disable-server --class=Xfce4-terminal --maximize=true --zoom=1.2
    '"
    # (TODO) Add: More apps to watch for... and test in the future DX 
)

/usr/bin/inotifywait -m -e create --format '%f' "$WATCH_DIR" -qq | while read filename; do
    if [[ -v APPS[$filename] ]]; then
        rm -f "$WATCH_DIR/$filename"
        eval "${APPS[$filename]}" &
    fi
done
