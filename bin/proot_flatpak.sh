#!/usr/bin/env bash
# Created by Days
set -euo pipefail

if ls /.chardrc > /dev/null 2>&1; then
    echo "${RED}proot_flatpak must be run from the host shell, not inside Chard.${RESET}"
    sleep 3
    exit 1
fi

R=$CHARD_ROOT
FLATPAK_ROOT=/usr/local/flatpak-1.16.6
sudo true
CHARD_USER="$(sudo cat "$R/.chard_user")"
CHARD_UID="$(sudo chroot "$R" id -u "$CHARD_USER")"
CHARD_GID="$(sudo chroot "$R" id -g "$CHARD_USER")"
CHARD_GROUPS="$(sudo chroot "$R" id -G "$CHARD_USER" | tr ' ' ',')"
CHARD_HOME="$(sudo cat "$R/.chard_home")"
CHARD_HOME="/${CHARD_HOME#/}"
CHARD_DISPLAY="${DISPLAY:-}"
CHARD_WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
WRAPPED_PATH="$R/usr/local/bwrap-nosuid/bin:$PATH"
[ "${CHARD_FORCE_NO_WAYLAND:-0}" = 1 ] && CHARD_WAYLAND_DISPLAY=""

CHARD_DBUS="${DBUS_SESSION_BUS_ADDRESS:-}"
if [ -z "$CHARD_DBUS" ] && [ -S /run/user/1000/bus ]; then
    CHARD_DBUS="unix:path=/run/user/1000/bus"
fi
[ -z "$CHARD_DBUS" ] && CHARD_DBUS="disabled:"

test -x "$R/usr/local/bwrap-nosuid/bin/bwrap"
test -x "$R/bin/bwrap-userns-chard"
test -x "$R$FLATPAK_ROOT/bin/flatpak"

NO_USER_CMDS=(
    make-current enter ps kill
    documents document-export document-unexport document-info
    permissions permission-remove permission-set permission-show permission-reset
    remotes remote-add remote-modify remote-delete remote-ls remote-info
    build-init build build-finish build-export build-bundle build-import-bundle
    build-sign build-update-repo build-commit-from repo
)

if [ $# -eq 0 ]; then
    FINAL_ARGS=()
else
    CMD="$1"
    shift
    USE_USER=1
    for c in "${NO_USER_CMDS[@]}"; do
        [ "$CMD" = "$c" ] && USE_USER=0 && break
    done
    case "$CMD" in
        -h|--help|--version|--default-arch|--supported-arches|--gl-drivers|--installations|--print-updated-env|--print-system-only|-v|--verbose|--ostree-verbose)
            USE_USER=0
            ;;
    esac
    if [ "$USE_USER" -eq 1 ]; then
        FINAL_ARGS=(--user "$CMD" "$@")
    else
        FINAL_ARGS=("$CMD" "$@")
    fi
fi

exec sudo env \
    R="$R" \
    #FLATPAK_ROOT="$FLATPAK_ROOT" \
    CHARD_USER="$CHARD_USER" \
    CHARD_UID="$CHARD_UID" \
    CHARD_GID="$CHARD_GID" \
    CHARD_GROUPS="$CHARD_GROUPS" \
    CHARD_HOME="$CHARD_HOME" \
    CHARD_DISPLAY="$CHARD_DISPLAY" \
    PATH="$WRAPPED_PATH"
    CHARD_WAYLAND_DISPLAY="$CHARD_WAYLAND_DISPLAY" \
    CHARD_DBUS="$CHARD_DBUS" \
    unshare -m -f /bin/bash -s -- "${FINAL_ARGS[@]}" <<'PIVOT'
set -euo pipefail

bind_dir() {
    local src="$1"
    local dst="$2"
    if [ -d "$src" ]; then
        mkdir -p "$dst"
        if mount --rbind "$src" "$dst" 2>/dev/null; then
            mount --make-rslave "$dst" 2>/dev/null || true
        fi
    fi
}

mount --make-rprivate /
mount --bind "$R" "$R"

mkdir -p \
    "$R/.oldroot" \
    "$R/proc" \
    "$R/dev" \
    "$R/sys" \
    "$R/run/chrome" \
    "$R/run/user/1000" \
    "$R/run/dbus" \
    "$R/run/cras" \
    "$R/run/udev" \
    "$R/tmp/.X11-unix" \
    "$R$CHARD_HOME/MyFiles"

mount --bind /proc "$R/proc"
mount --rbind /dev "$R/dev"
mount --make-rslave "$R/dev" 2>/dev/null || true
if mount --bind /sys "$R/sys" 2>/dev/null; then
    mount --make-rslave "$R/sys" 2>/dev/null || true
fi

bind_dir /run/chrome "$R/run/chrome"
bind_dir /run/user/1000 "$R/run/user/1000"
bind_dir /run/dbus "$R/run/dbus"
bind_dir /run/cras "$R/run/cras"
bind_dir /run/udev "$R/run/udev"
bind_dir /tmp/.X11-unix "$R/tmp/.X11-unix"
bind_dir /home/chronos/user/MyFiles "$R$CHARD_HOME/MyFiles"

cd "$R"
pivot_root . .oldroot
cd /
umount -l /.oldroot 2>/dev/null || true
rmdir /.oldroot 2>/dev/null || true

if [ -n "$CHARD_WAYLAND_DISPLAY" ] && [ ! -S "/run/chrome/$CHARD_WAYLAND_DISPLAY" ]; then
    CHARD_WAYLAND_DISPLAY=""
fi

ENV_ARGS=(
    HOME="$CHARD_HOME"
    USER="$CHARD_USER"
    LOGNAME="$CHARD_USER"
    XDG_RUNTIME_DIR=/run/chrome
    DBUS_SESSION_BUS_ADDRESS="$CHARD_DBUS"
    PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    LD_LIBRARY_PATH="$FLATPAK_ROOT/lib:$FLATPAK_ROOT/lib64"
    XDG_DATA_DIRS="$FLATPAK_ROOT/share:/usr/local/share:/usr/share:/usr/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$CHARD_HOME/.local/share/flatpak/exports/share"
    FLATPAK_BWRAP="/usr/local/bin/bwrap-nosuid/bin/bwrap"
)
[ -n "$CHARD_WAYLAND_DISPLAY" ] && ENV_ARGS+=(WAYLAND_DISPLAY="$CHARD_WAYLAND_DISPLAY")
[ -n "$CHARD_DISPLAY" ] && ENV_ARGS+=(DISPLAY="$CHARD_DISPLAY")

exec chroot \
    --userspec="$CHARD_UID:$CHARD_GID" \
    --groups="$CHARD_GROUPS" \
    / \
    /usr/bin/env -i "${ENV_ARGS[@]}" \
    "$FLATPAK_ROOT/bin/flatpak" "$@"
PIVOT
