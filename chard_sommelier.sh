#!/bin/bash

# <<< CHARD_ROOT_MARKER >>>
CHARD_ROOT=""
CHARD_HOME=""
CHARD_USER=""
# <<< END_CHARD_ROOT_MARKER >>>

export SOMMELIER_DISPLAY="/run/chrome/wayland-0"
export SOMMELIER_DRM_DEVICE="/dev/dri/renderD128"

SOMMELIER_CMD=(
    sommelier
    --display="$SOMMELIER_DISPLAY"
    --noop-driver
    --force-drm-device="$SOMMELIER_DRM_DEVICE"
    -X
    --glamor
    --enable-linux-dmabuf
    --xwayland-path=/usr/libexec/Xwayland
)

"${SOMMELIER_CMD[@]}" -- bash -c '
    sleep 0.1
    export DISPLAY=$(ls /tmp/.X11-unix | sed "s/^X/:/" | head -n1)
    pulseaudio &>/dev/null &
    [ -f ~/.bashrc ] && source ~/.bashrc
    cd ~/
    exec bash
'

if [ -f /tmp/.pulseaudio_pid ]; then
    kill "$(cat /tmp/.pulseaudio_pid)" 2>/dev/null
    rm -f /tmp/.pulseaudio_pid
fi
