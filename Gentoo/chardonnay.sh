#!/bin/bash
SOMMELIER_DISPLAY="/run/chrome/wayland-0"
SOMMELIER_DRM_DEVICE="/dev/dri/renderD128"
SOMMELIER_CMD=(
    sommelier
    --display="$SOMMELIER_DISPLAY"
    --force-drm-device="$SOMMELIER_DRM_DEVICE"
    --noop-driver
    --glamor
    --enable-linux-dmabuf
    --xwayland-path=/usr/bin/Xwayland)
"${SOMMELIER_CMD[@]}" -- bash -c '
    sleep 0.1
    export DISPLAY=$(ls /usr/local/chard/tmp/.X11-unix | sed "s/^X/:/" | head -n1)
    cd ~/
    sudo /usr/local/chard/bin/chard safe
'
