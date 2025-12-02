#!/bin/bash
SOMMELIER_DISPLAY="/run/chrome/wayland-0"
SOMMELIER_DRM_DEVICE="/dev/dri/renderD128"
ARCH="$(uname -m)"
SOMMELIER_CMD=(
    sommelier
    --display="$SOMMELIER_DISPLAY"
    --noop-driver
    -X
    --glamor
    --enable-linux-dmabuf
    --xwayland-path=$CHARD_ROOT/usr/libexec/Xwayland)

if [[ "$ARCH" == "x86_64" ]]; then
    SOMMELIER_CMD+=( --force-drm-device="$SOMMELIER_DRM_DEVICE" )
fi

"${SOMMELIER_CMD[@]}" -- bash -c '
    sleep 0.1
    export DISPLAY=$(ls $CHARD_ROOT/tmp/.X11-unix | sed "s/^X/:/" | head -n1)
    cd ~/
    exec bash
'
sudo setfacl -Rb /root 2>/dev/null
if [ -f $CHARD_ROOT/tmp/.pulseaudio_pid ]; then
    kill "$(cat $CHARD_ROOT/tmp/.pulseaudio_pid)" 2>/dev/null
    rm -f $CHARD_ROOT/tmp/.pulseaudio_pid
fi
