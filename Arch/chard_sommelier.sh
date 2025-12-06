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
    --enable-linux-dmabuf
    --xwayland-path=/usr/bin/Xwayland
)

   "${SOMMELIER_CMD[@]}" -- bash -c '
    sleep 0.1
    export DISPLAY=$(ls /tmp/.X11-unix | sed "s/^X/:/" | head -n1)
    [ -f ~/.bashrc ] && source ~/.bashrc
    cd ~/
    pipewire &
    sleep 0.2
    wireplumber &
    sleep 0.2
    pipewire-pulse &
    sleep 0.2
    exec bash
'
sudo setfacl -Rb /root 2>/dev/null
