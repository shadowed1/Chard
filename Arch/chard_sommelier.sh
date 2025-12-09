#!/bin/bash
SOMMELIER_DISPLAY="/run/chrome/wayland-0"
SOMMELIER_DRM_DEVICE="/dev/dri/renderD128"
ARCH="$(uname -m)"
SOMMELIER_CMD=(
    sommelier
    --force-drm-device="$SOMMELIER_DRM_DEVICE"
    --display="$SOMMELIER_DISPLAY"
    --noop-driver
    --stable-scaling
    --enable-xshape
    --sd-notify=READY=1
    -X
    --glamor
    --frame-color="#202020"
    --enable-linux-dmabuf
    --xwayland-path=/usr/bin/Xwayland
)

if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    "${SOMMELIER_CMD[@]}" -- bash -c '
    sleep 0.1
    export DISPLAY=$(ls /tmp/.X11-unix | sed "s/^X/:/" | head -n1)
    [ -f ~/.bashrc ] && source ~/.bashrc
    pipewire &
    sleep 0.2
    pulseaudio &
    cd ~/
    exec bash
'
else
   "${SOMMELIER_CMD[@]}" -- bash -c '
   sleep 0.1
    export DISPLAY=$(ls /tmp/.X11-unix | sed "s/^X/:/" | head -n1)
    [ -f ~/.bashrc ] && source ~/.bashrc
    cd ~/
    pipewire &
    sleep 0.2
    pulseaudio &
    sleep 0.2
    chardwire 2>/dev/null &
    exec bash
'
fi

sudo setfacl -Rb /root 2>/dev/null
killall -9 chardwire 2>/dev/null

if [ -f /tmp/.pulseaudio_pid ]; then
    kill "$(cat /tmp/.pulseaudio_pid)" 2>/dev/null
    rm -f /tmp/.pulseaudio_pid
fi
