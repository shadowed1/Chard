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
    --xwayland-path="$CHARD_ROOT/usr/libexec/Xwayland"
)

if [[ "$ARCH" == "x86_64" ]]; then
    SOMMELIER_CMD+=(--force-drm-device="$SOMMELIER_DRM_DEVICE")
fi

env PATH="$CHARD_ROOT/usr/bin:$CHARD_ROOT/bin:$CHARD_ROOT/usr/$CHOST/gcc-bin/14:$CHARD_ROOT/usr/local/bin:$PATH" \
"${SOMMELIER_CMD[@]}" -- bash -c "
    echo 'Sommelier shell running...'
    export CHARD_ROOT='$CHARD_ROOT'
    export LD_LIBRARY_PATH='$PATH:$CHARD_ROOT/usr/lib:$CHARD_ROOT/lib:$CHARD_ROOT/usr/lib/gcc/$CHOST/14:$CHARD_ROOT/usr/$CHOST/gcc-bin/14'
    cd ~/
    exec bash
"
