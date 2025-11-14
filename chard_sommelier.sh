# <<< CHARD_SOMMELIER >>>
SOMMELIER_DISPLAY="/run/chrome/wayland-0"
SOMMELIER_DRM_DEVICE="/dev/dri/renderD128"
SOMMELIER_CMD=(
    sommelier
    --display="$SOMMELIER_DISPLAY"
    --noop-driver
    --force-drm-device="$SOMMELIER_DRM_DEVICE"
    -X
    --glamor
    --enable-linux-dmabuf
    --xwayland-path=/usr/bin/Xwayland
)
"${SOMMELIER_CMD[@]}" -- bash -c '
    sleep 0.1
    export DISPLAY=$(ls /tmp/.X11-unix | sed "s/^X/:/" | head -n1)
    [ -f ~/.bashrc ] && source ~/.bashrc
    pulseaudio &>/dev/null &
    cd ~/
    exec bash
'
if [ -f /tmp/.pulseaudio_pid ]; then
    kill "$(cat /tmp/.pulseaudio_pid)" 2>/dev/null
    rm -f /tmp/.pulseaudio_pid
fi
# <<< END CHARD_SOMMELIER >>>
