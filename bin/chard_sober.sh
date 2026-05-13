#!/usr/bin/env bash
# Author: Days (iamda-y)
# Version: 5

set -euo pipefail

CHARD_ROOT="${CHARD_ROOT:-/usr/local/chard}"
FLATPAK_ROOT="${FLATPAK_ROOT:-/usr/local/flatpak-1.16.6}"
CHARD_USER="${CHARD_USER:-$(sudo cat "$CHARD_ROOT/.chard_user" 2>/dev/null || printf '%s\n' chronos)}"
CHARD_HOME="${CHARD_HOME:-$(sudo cat "$CHARD_ROOT/.chard_home" 2>/dev/null || printf 'home/%s\n' "$CHARD_USER")}"
CHARD_HOME="/${CHARD_HOME#/}"
CHARD_UID="$(sudo chroot "$CHARD_ROOT" id -u "$CHARD_USER")"
CHARD_GID="$(sudo chroot "$CHARD_ROOT" id -g "$CHARD_USER")"
CHARD_GROUPS="$(sudo chroot "$CHARD_ROOT" id -G "$CHARD_USER" | tr ' ' ',')"
CHARD_WAYLAND_DISPLAY="${CHARD_WAYLAND_DISPLAY:-${WAYLAND_DISPLAY:-wayland-0}}"
CHARD_X11_DISPLAY="${CHARD_X11_DISPLAY-}"
CHARD_DBUS_SESSION_BUS_ADDRESS="${CHARD_DBUS_SESSION_BUS_ADDRESS:-${DBUS_SESSION_BUS_ADDRESS:-}}"
CHARD_SOBER_APPLICATION_ID="${CHARD_SOBER_APPLICATION_ID:-org.chromium.arc.session.1}"
CHARD_SOBER_FLATPAK_ID="${CHARD_SOBER_FLATPAK_ID:-org.vinegarhq.Sober}"
CHARD_SOBER_DOWNLOADS="${CHARD_SOBER_DOWNLOADS:-/home/chronos/user/MyFiles/Downloads}"
CHARD_SOBER_TS="$(date +%Y%m%d-%H%M%S)"
CHARD_SOBER_LOG="$CHARD_SOBER_DOWNLOADS/chard-sober-sommelier-$CHARD_SOBER_TS.log"
CHARD_SOBER_LOG_LATEST="$CHARD_SOBER_DOWNLOADS/chard-sober-sommelier.latest.log"
CHARD_SOBER_PIDFILE="$CHARD_SOBER_DOWNLOADS/chard-sober-sommelier.pid"

[[ -n "$CHARD_DBUS_SESSION_BUS_ADDRESS" || ! -S /run/user/1000/bus ]] || CHARD_DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
[[ -n "$CHARD_DBUS_SESSION_BUS_ADDRESS" ]] || CHARD_DBUS_SESSION_BUS_ADDRESS="disabled:"

pivot_script() {
    cat <<'PIVOT'
set -euo pipefail

bind_dir() {
    local src="$1" dst="$2"
    [[ -d "$src" ]] || return 0
    mkdir -p "$dst"
    mount --rbind "$src" "$dst" 2>/dev/null || return 0
    mount --make-rslave "$dst" 2>/dev/null || true
}

mount --make-rprivate /
mount --bind "$CHARD_ROOT" "$CHARD_ROOT"

mkdir -p \
    "$CHARD_ROOT/.oldroot" \
    "$CHARD_ROOT/proc" \
    "$CHARD_ROOT/dev" \
    "$CHARD_ROOT/sys" \
    "$CHARD_ROOT/run/chrome" \
    "$CHARD_ROOT/run/user/1000" \
    "$CHARD_ROOT/run/dbus" \
    "$CHARD_ROOT/run/cras" \
    "$CHARD_ROOT/run/udev" \
    "$CHARD_ROOT/tmp/.X11-unix" \
    "$CHARD_ROOT$CHARD_HOME/MyFiles"

mount --bind /proc "$CHARD_ROOT/proc"
mount --rbind /dev "$CHARD_ROOT/dev"
mount --make-rslave "$CHARD_ROOT/dev" 2>/dev/null || true
mount --bind /sys "$CHARD_ROOT/sys" 2>/dev/null || true
mount --make-rslave "$CHARD_ROOT/sys" 2>/dev/null || true

bind_dir /run/chrome "$CHARD_ROOT/run/chrome"
bind_dir /run/user/1000 "$CHARD_ROOT/run/user/1000"
bind_dir /run/dbus "$CHARD_ROOT/run/dbus"
bind_dir /run/cras "$CHARD_ROOT/run/cras"
bind_dir /run/udev "$CHARD_ROOT/run/udev"
bind_dir /tmp/.X11-unix "$CHARD_ROOT/tmp/.X11-unix"
bind_dir "/home/$CHARD_USER/user/MyFiles" "$CHARD_ROOT$CHARD_HOME/MyFiles"

cd "$CHARD_ROOT"
pivot_root . .oldroot
cd /
umount -l /.oldroot 2>/dev/null || true
rmdir /.oldroot 2>/dev/null || true

[[ -z "$CHARD_WAYLAND_DISPLAY" || -S "/run/chrome/$CHARD_WAYLAND_DISPLAY" ]] || CHARD_WAYLAND_DISPLAY=""

env_args=(
    HOME="$CHARD_HOME"
    USER="$CHARD_USER"
    XDG_RUNTIME_DIR=/run/chrome
    DBUS_SESSION_BUS_ADDRESS="$CHARD_DBUS_SESSION_BUS_ADDRESS"
    PATH="$FLATPAK_ROOT/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    LD_LIBRARY_PATH="$FLATPAK_ROOT/lib:$FLATPAK_ROOT/lib64"
    XDG_DATA_DIRS="$FLATPAK_ROOT/share:/usr/local/share:/usr/share:/usr/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$CHARD_HOME/.local/share/flatpak/exports/share"
    FLATPAK_BWRAP="$CHARD_HOME/bwrap-userns-chard"
)

[[ -z "$CHARD_WAYLAND_DISPLAY" ]] || env_args+=(WAYLAND_DISPLAY="$CHARD_WAYLAND_DISPLAY")
[[ -z "$CHARD_X11_DISPLAY" ]] || env_args+=(DISPLAY="$CHARD_X11_DISPLAY")

exec chroot --userspec="$CHARD_UID:$CHARD_GID" --groups="$CHARD_GROUPS" / \
    /usr/bin/env -i "${env_args[@]}" \
    "$FLATPAK_ROOT/bin/flatpak" "$@"
PIVOT
}

flatpak_pivot() {
    exec sudo env \
        CHARD_ROOT="$CHARD_ROOT" \
        CHARD_USER="$CHARD_USER" \
        CHARD_HOME="$CHARD_HOME" \
        CHARD_UID="$CHARD_UID" \
        CHARD_GID="$CHARD_GID" \
        CHARD_GROUPS="$CHARD_GROUPS" \
        CHARD_WAYLAND_DISPLAY="$CHARD_WAYLAND_DISPLAY" \
        CHARD_X11_DISPLAY="$CHARD_X11_DISPLAY" \
        CHARD_DBUS_SESSION_BUS_ADDRESS="$CHARD_DBUS_SESSION_BUS_ADDRESS" \
        FLATPAK_ROOT="$FLATPAK_ROOT" \
        unshare -m -f /bin/bash -s -- "$@" < <(pivot_script)
}

sober_kill() {
    ( flatpak_pivot --user kill "$CHARD_SOBER_FLATPAK_ID" ) >/dev/null 2>&1 || true
    sleep 0.3

    local pids
    pids="$(ps -eo pid=,ppid=,args= | awk -v me="$$" '
        $1 != me && $2 != me &&
        /org\.vinegarhq\.Sober|\/app\/bin\/sober|[ /]sober([ ]|$)/ &&
        !/chard_sober/ && !/awk -v me=/ { print $1 }
    ')"

    [[ -z "$pids" ]] || {
        printf '%s\n' "$pids" | xargs -r sudo kill -TERM 2>/dev/null || true
        sleep 0.7
        printf '%s\n' "$pids" | xargs -r sudo kill -KILL 2>/dev/null || true
    }

    echo "Sober stopped"
}

sommelier_stop() {
    [[ ! -f "$CHARD_SOBER_PIDFILE" ]] || {
        local pid
        pid="$(cat "$CHARD_SOBER_PIDFILE" 2>/dev/null || true)"
        [[ -z "$pid" ]] || {
            sudo kill -TERM "$pid" 2>/dev/null || true
            sleep 0.3
            sudo kill -KILL "$pid" 2>/dev/null || true
        }
        rm -f "$CHARD_SOBER_PIDFILE"
    }

    local pids
    pids="$(ps -eo pid=,ppid=,args= | awk '
        /[s]ommelier/ && /-X/ && /xwayland-path/  { print $1; next }
        /[X]wayland/  && /-displayfd/              { print $1; next }
        /[s]leep 360000/                           { print $1; next }
    ')"

    [[ -z "$pids" ]] || {
        printf '%s\n' "$pids" | xargs -r sudo kill -TERM 2>/dev/null || true
        sleep 0.6
        printf '%s\n' "$pids" | xargs -r sudo kill -KILL 2>/dev/null || true
    }

    sudo rm -f /tmp/.X11-unix/X{0..32} "$CHARD_ROOT"/tmp/.X11-unix/X{0..32} 2>/dev/null || true
}

setup_mounts() {
    sudo mkdir -p "$CHARD_ROOT/proc" "$CHARD_ROOT/dev" "$CHARD_ROOT/sys" "$CHARD_ROOT/run/chrome" "$CHARD_ROOT/tmp/.X11-unix"
    sudo chmod 1777 "$CHARD_ROOT/tmp" "$CHARD_ROOT/tmp/.X11-unix" 2>/dev/null || true

    [[ -d "$CHARD_ROOT/proc/1" ]] || sudo mount --bind /proc "$CHARD_ROOT/proc" 2>/dev/null || true
    [[ -d "$CHARD_ROOT/sys/class" ]] || sudo mount --bind /sys "$CHARD_ROOT/sys" 2>/dev/null || true
    [[ -c "$CHARD_ROOT/dev/null" ]] || sudo mount --rbind /dev "$CHARD_ROOT/dev" 2>/dev/null || true
    [[ -S "$CHARD_ROOT/run/chrome/$CHARD_WAYLAND_DISPLAY" ]] || sudo mount --rbind /run/chrome "$CHARD_ROOT/run/chrome" 2>/dev/null || true
}

xdpyinfo_check() {
    sudo chroot --userspec="$CHARD_UID:$CHARD_GID" --groups="$CHARD_GROUPS" "$CHARD_ROOT" \
        /usr/bin/env -i \
            HOME="$CHARD_HOME" \
            USER="$CHARD_USER" \
            "DISPLAY=:$1" \
            XDG_RUNTIME_DIR=/run/chrome \
            PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin \
        /usr/sbin/xdpyinfo \
        >/tmp/chard-sober-xdpyinfo.out 2>/tmp/chard-sober-xdpyinfo.err
}

wait_for_display() {
    local pid="$1" mode="$2"
    local n start="$SECONDS" elapsed

    while (( (elapsed = SECONDS - start) < 25 )); do
        kill -0 "$pid" 2>/dev/null || {
            echo "Sommelier exited early (mode=$mode, t=${elapsed}s)" | tee -a "$CHARD_SOBER_LOG"
            return 1
        }

        for (( n = 0; n <= 32; n++ )); do
            [[ -S "$CHARD_ROOT/tmp/.X11-unix/X$n" ]] || continue

            xdpyinfo_check "$n" && {
                CHARD_X11_DISPLAY=":$n"
                echo "Sommelier X11 ready: $CHARD_X11_DISPLAY (mode=$mode, t=${elapsed}s)"
                echo
                echo "── socket listing ──"
                ls -la "$CHARD_ROOT/tmp/.X11-unix/" /tmp/.X11-unix/ 2>/dev/null || true
                echo
                echo "── xdpyinfo header ──"
                head -25 /tmp/chard-sober-xdpyinfo.out || true
                return 0
            }

            break
        done

        sleep 0.1
    done

    echo "Timed out waiting for X display (mode=$mode)" | tee -a "$CHARD_SOBER_LOG"
    return 1
}

sommelier_start_one() {
    local mode="$1"
    local -a args env
    local pid

    echo
    echo "== start mode=$mode ==" | tee -a "$CHARD_SOBER_LOG"

    args=(
        /usr/local/bin/sommelier
        -X
        "--application-id=$CHARD_SOBER_APPLICATION_ID"
        --noop-driver
        "--display=$CHARD_WAYLAND_DISPLAY"
        --log-level=0
        --xwayland-path=/usr/sbin/Xwayland
        --enable-xshape
        --fullscreen-mode=immersive
        --no-exit-with-child
    )

    [[ "$mode" != glamor ]] || args+=(
        --glamor
        --force-drm-device=/dev/dri/renderD128
        --enable-linux-dmabuf
    )

    args+=(-- /bin/sleep 360000)

    env=(
        HOME="$CHARD_HOME"
        USER="$CHARD_USER"
        XDG_RUNTIME_DIR=/run/chrome
        WAYLAND_DISPLAY="$CHARD_WAYLAND_DISPLAY"
        PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
        GALLIUM_DRIVER=iris
        MESA_LOADER_DRIVER_OVERRIDE=iris
        VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.json
        "VK_LOADER_LAYERS_DISABLE=*"
    )

    sudo chroot --userspec="$CHARD_UID:$CHARD_GID" --groups="$CHARD_GROUPS" "$CHARD_ROOT" \
        /usr/bin/env -i "${env[@]}" "${args[@]}" >>"$CHARD_SOBER_LOG" 2>&1 &

    pid="$!"
    echo "$pid" > "$CHARD_SOBER_PIDFILE"
    echo "sommelier wrapper pid: $pid"

    wait_for_display "$pid" "$mode"
}

sommelier_start() {
    mkdir -p "$CHARD_SOBER_DOWNLOADS"
    rm -f "$CHARD_SOBER_LOG_LATEST"
    : > "$CHARD_SOBER_LOG"
    ( cd "$CHARD_SOBER_DOWNLOADS" && ln -sf "$(basename "$CHARD_SOBER_LOG")" "$(basename "$CHARD_SOBER_LOG_LATEST")" )

    echo "log: $CHARD_SOBER_LOG"

    sudo -v
    sommelier_stop >/dev/null 2>&1 || true
    setup_mounts

    sommelier_start_one glamor && return 0

    echo
    echo "---- glamor failed; recent log ----"
    tail -n 120 "$CHARD_SOBER_LOG" || true

    sommelier_stop >/dev/null 2>&1 || true
    sommelier_start_one noglamor && return 0

    echo "ERROR: no usable Sommelier X display found" >&2
    echo "log: $CHARD_SOBER_LOG" >&2
    tail -n 240 "$CHARD_SOBER_LOG" >&2 || true
    return 1
}

pulse_start() {
    /usr/local/bin/chard_pulse_chrome_start >/tmp/chard-pulse-chrome-sober.last.log 2>&1 || {
        cat /tmp/chard-pulse-chrome-sober.last.log >&2 || true
        echo "warning: chard_pulse_chrome_start failed; continuing without audio" >&2
    }
}

cmd_run() {
    echo "== stop old Sober =="
    sober_kill || true

    echo
    echo "== start Sommelier/X11 =="
    sommelier_start

    echo
    echo "== start PulseAudio =="
    pulse_start

    sudo rm -rf /run/chrome/.flatpak/"$CHARD_SOBER_FLATPAK_ID"/xdg-run/pulse 2>/dev/null || true

    echo
    echo "== launch Sober (DISPLAY=$CHARD_X11_DISPLAY) =="

    local -a fp_args=(
        --user
        run
        --nosocket=wayland
        --socket=x11
        --socket=fallback-x11
        --socket=pulseaudio
        --device=dri
        --device=input
        "--env=DISPLAY=$CHARD_X11_DISPLAY"
        "--env=WAYLAND_DISPLAY="
        "--env=GDK_BACKEND=x11"
        "--env=SDL_VIDEODRIVER=x11"
        "--env=SDL_AUDIO_DRIVER=pulseaudio"
        "--env=SDL_AUDIODRIVER=pulseaudio"
        "--env=MANGOHUD=${CHARD_SOBER_MANGOHUD:-0}"
        "--env=MANGOHUD_CONFIG=${CHARD_SOBER_MANGOHUD_CONFIG:-fps,frametime,frame_timing=1,gpu_stats,cpu_stats,ram,vram,vulkan_driver,engine_version,position=top-left,font_size=18}"
        "$CHARD_SOBER_FLATPAK_ID"
    )

    CHARD_WAYLAND_DISPLAY="" flatpak_pivot "${fp_args[@]}" "$@"
}

cmd_kill() {
    echo "== kill Sober =="
    sober_kill
}

cmd_update() {
    flatpak_pivot --user update "$CHARD_SOBER_FLATPAK_ID" "$@"
}

usage() {
    echo "usage: chard_sober [run|kill|update] [args...]" >&2
    exit 1
}

subcmd="${1:-run}"
(( $# == 0 )) || shift

case "$subcmd" in
    run) cmd_run "$@" ;;
    kill) cmd_kill "$@" ;;
    update) cmd_update "$@" ;;
    *) usage ;;
esac
