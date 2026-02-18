#!/usr/bin/env bash
CONCEAL="/opt/google"
CROSTINI_USER="$USER"
CROSTINI_UID="$(id -u)"
CROSTINI_DISPLAY="${DISPLAY:-:0}"
CROSTINI_XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
CROSTINI_XDG="${XDG_RUNTIME_DIR:-/run/user/$CROSTINI_UID}"
CROSTINI_DBUS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$CROSTINI_XDG/bus}"
CROSTINI_WAYLAND="${WAYLAND_DISPLAY:-}"
CROSTINI_PULSE="${PULSE_SERVER:-unix:$CROSTINI_XDG/pulse/native}"

exec sudo unshare --mount --propagation private bash -c '
    CONCEAL="'"$CONCEAL"'"
    CROSTINI_USER="'"$CROSTINI_USER"'"
    mount --make-rprivate /
    SHADOW=$(mktemp -d /tmp/.obs-shadow-XXXXXX)
    mount -t tmpfs -o size=4k,mode=0755 tmpfs "$SHADOW"
    mount --bind "$SHADOW" "$CONCEAL"
    exec runuser -u "$CROSTINI_USER" -- env \
        DISPLAY="'"$CROSTINI_DISPLAY"'" \
        XAUTHORITY="'"$CROSTINI_XAUTHORITY"'" \
        XDG_RUNTIME_DIR="'"$CROSTINI_XDG"'" \
        DBUS_SESSION_BUS_ADDRESS="'"$CROSTINI_DBUS"'" \
        WAYLAND_DISPLAY="'"$CROSTINI_WAYLAND"'" \
        PULSE_SERVER="'"$CROSTINI_PULSE"'" \
        obs "$@"
' _ "$@"
