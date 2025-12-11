#!/bin/bash
SOMMELIER_CMD=(
    sommelier
    --force-drm-device="/dev/dri/renderD128"
    --display="/run/chrome/wayland-0"
    --stable-scaling
    --enable-xshape
    --sd-notify=READY=1
    -X
    --glamor
    --accelerators="<Shift><Control>w,<Alt>tab,<Shift><Alt>tab,<Alt>minus," 
    --windowed-accelerators="Super_L,<Shift><Control>q,<Alt><Control>slash,<Control>n,<Shift><Control>n,<Control>t,<Shift><Control>t,<Shift><Alt>l,<Alt>bracketleft,<Alt>bracketright,<Alt>equal,<Shift><Alt>m,<Shift><Alt>s,<Alt>1,<Alt>2,<Alt>3,<Alt>4,<Alt>5,<Alt>6,<Alt>7,<Alt>8,<Alt>9,<Shift><Alt>n,<Shift><Control>plus,<Shift><Control>minus,<Shift><Control>0,<Alt><Control>period,<Alt><Control>comma,<Shift><Control>XF86Reload,<Control>XF86Forward,<Control>XF86Back,"
    --frame-color="#202020"
    --enable-linux-dmabuf
    --xwayland-path=$CHARD_ROOT/usr/libexec/Xwayland
)

   "${SOMMELIER_CMD[@]}" -- bash -c '
   [ -f $CHARD_ROOT/.chardrc ] && source $CHARD_ROOT/.chardrc
    sleep 0.1
    cd ~/
    exec bash
'
