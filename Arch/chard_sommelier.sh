#!/bin/bash
SOMMELIER_DISPLAY="/run/chrome/wayland-0"
SOMMELIER_DRM_DEVICE="/dev/dri/renderD128"
ARCH="$(uname -m)"
SOMMELIER_CMD=(
    sommelier
    -X
    --glamor
    --force-drm-device="$SOMMELIER_DRM_DEVICE"
    --display="$SOMMELIER_DISPLAY"
    --noop-driver
    --fullscreen-mode=plain
    --direct-scale
    --stable-scaling
    --enable-xshape
    --sd-notify=READY=1
    --allow-xwayland-emulate-screen-pos-size
    --only-client-can-exit-fullscreen
    --application-id-x11-property=STEAM_GAME
    --accelerators="<Shift><Control>w,<Alt>tab,<Shift><Alt>tab,<Alt>minus," 
    --windowed-accelerators="Super_L,<Shift><Control>q,<Alt><Control>slash,<Control>n,<Shift><Control>n,<Control>t,<Shift><Control>t,<Shift><Alt>l,<Alt>bracketleft,<Alt>bracketright,<Alt>equal,<Shift><Alt>m,<Shift><Alt>s,<Alt>1,<Alt>2,<Alt>3,<Alt>4,<Alt>5,<Alt>6,<Alt>7,<Alt>8,<Alt>9,<Shift><Alt>n,<Shift><Control>plus,<Shift><Control>minus,<Shift><Control>0,<Alt><Control>period,<Alt><Control>comma,<Shift><Control>XF86Reload,<Control>XF86Forward,<Control>XF86Back,"
    --frame-color="#202020"
    --enable-linux-dmabuf
    --xwayland-path=/usr/bin/Xwayland
    --vm-identifier=termina
    --only-client-can-exit-fullscreen
)

   "${SOMMELIER_CMD[@]}" -- bash -c '
   sleep 0.1
    export DISPLAY=$(ls /tmp/.X11-unix | sed "s/^X/:/" | head -n1)
    [ -f ~/.bashrc ] && source ~/.bashrc
    cd ~/
    pipewire 2>/dev/null &
    sleep 0.2
    pulseaudio 2>/dev/null &
    sleep 0.2
    powercontrol-gui 2>/dev/null &
    sleep 0.2
    chardwire 2>/dev/null &
    sleep 0.2
    color_reset 2>/dev/null &
    exec bash
'
error_color
sudo setfacl -Rb /root 2>/dev/null
killall -9 chardwire 2>/dev/null

if [ -f /tmp/.pulseaudio_pid ]; then
    kill "$(cat /tmp/.pulseaudio_pid)" 2>/dev/null
    rm -f /tmp/.pulseaudio_pid
fi
