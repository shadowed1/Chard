# <<< CHARD .SOMMELIER >>>
#!/bin/bash
export LC_ALL=C
export SOMMELIER_DISPLAY="/run/chrome/wayland-0"
export SOMMELIER_DRM_DEVICE="/dev/dri/renderD128"
export LIBGL_DRIVERS_PATH="/usr/lib64/dri"
export LIBEGL_DRIVERS_PATH="/usr/lib64/dri"
export LD_LIBRARY_PATH=/usr/lib64\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}
export LIBGL_ALWAYS_INDIRECT=0
export QT_QPA_PLATFORM=wayland
export SOMMELIER_DRM_DEVICE=/dev/dri/renderD128
export SOMMELIER_GLAMOR=1
export SOMMELIER_VERSION=0.20

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

# <<< END CHARD .SOMMELIER >>>
