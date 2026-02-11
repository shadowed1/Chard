#!/bin/bash
# Version 1.0 
# chard_garcon 
# Author: Days and shadowed1

# <<< CHARD_ROOT_MARKER >>>
CHARD_ROOT=""
CHARD_HOME=""
CHARD_USER=""
# <<< END_CHARD_ROOT_MARKER >>>

export PATH="/usr/bin:/bin:/usr/local/bin:/sbin:/usr/sbin:$PATH"
WATCH_DIR="/$CHARD_HOME/user/MyFiles/chard/"

declare -A APPS=(
    [xfce4-terminal]="sudo -u chronos /bin/bash -c '
        # Source DBUS session for preference sync
        [ -f /tmp/chard_dbus_session ] && source /tmp/chard_dbus_session 2>/dev/null
        
        # Environment setup matching auto-launched / upstart xfce4-terminal from chard.sh
        CHARD_HOME=$(cat /.chard_home)
        export HOME=$CHARD_HOME
        CHARD_USER=$(cat /.chard_user)
        export USER=$CHARD_USER
        export XDG_DATA_DIRS=/usr/local/share:/usr/share
        export XDG_RUNTIME_DIR=/tmp/chard_runtime
        export DISPLAY=:0
        export GDK_BACKEND=x11
        
        [ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc" 2>/dev/null
        [ -f "$HOME/.smrt_env.sh" ] && source "$HOME/.smrt_env.sh"
        xfce4-terminal
    '"
    # (TODO) Add: More apps to watch for... and test in the future DX 
)

/usr/bin/inotifywait -m -e create --format '%f' "$WATCH_DIR" -qq | while read filename; do
    if [[ -v APPS[$filename] ]]; then
        rm -f "$WATCH_DIR/$filename"
        eval "${APPS[$filename]}" &
    fi
done
