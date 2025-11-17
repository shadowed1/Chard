# <<< CHARD .BASHRC >>>
# To do - Organize, clean up, and then outsource.
# <<< CHARD_ROOT_MARKER >>>
CHARD_ROOT=""
CHARD_HOME=""
CHARD_USER=""
# <<< END_CHARD_ROOT_MARKER >>>

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        CHOST="x86_64-pc-linux-gnu"
        ;;
    aarch64|arm64)
        CHOST="aarch64-unknown-linux-gnu"
        ;;
    *)
        echo "[!] Unsupported architecture: $ARCH"
        ;;
esac

HOME="/$CHARD_HOME"
USER="$CHARD_USER"
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

if [[ "$ROOT" != "/" ]]; then
    ROOT="${ROOT%/}"
fi

export ARCH
export CHOST
export CHARD_RC="$ROOT/.chardrc"
export GIT_EXEC_PATH="$ROOT/usr/lib/git-core"
export PYTHONMULTIPROCESSING_START_METHOD=fork

# <<< CHARD_XDG_RUNTIME_DIR >>>
export XDG_RUNTIME_DIR=""
# <<< END CHARD_XDG_RUNTIME_DIR >>>

export CC="$ROOT/usr/bin/gcc"
export CXX="$ROOT/usr/bin/g++"
export AR="$ROOT/usr/bin/ar"
export NM="$ROOT/usr/bin/gcc-nm"
export RANLIB="$ROOT/usr/bin/gcc-ranlib"
export STRIP="$ROOT/usr/bin/strip"
export LD="$ROOT/usr/bin/ld"

# <<< CHARD_MARCH_NATIVE >>>
CFLAGS="-march=native -O2 -pipe "
[[ -d "$ROOT/usr/include" ]] && CFLAGS+="-I$ROOT/usr/include "
[[ -d "$ROOT/include" ]] && CFLAGS+="-I$ROOT/include "
export CFLAGS

COMMON_FLAGS="-march=native -O2 -pipe"
FCFLAGS="$COMMON_FLAGS"
FFLAGS="$COMMON_FLAGS"

CXXFLAGS="$CFLAGS"
# <<< END CHARD_MARCH_NATIVE >>>

LDFLAGS=""
[[ -d "$ROOT/usr/lib64" ]] && LDFLAGS+="-L$ROOT/usr/lib64 "
[[ -d "$ROOT/lib64" ]] && LDFLAGS+="-L$ROOT/lib64 "
[[ -d "$ROOT/usr/local/lib64" ]] && LDFLAGS+="-L$ROOT/usr/local/lib64 "
[[ -d "$ROOT/usr/lib" ]] && LDFLAGS+="-L$ROOT/usr/lib "
[[ -d "$ROOT/lib" ]] && LDFLAGS+="-L$ROOT/lib "
[[ -d "$ROOT/usr/local/lib" ]] && LDFLAGS+="-L$ROOT/usr/local/lib "

export LDFLAGS
export FCFLAGS
export FFLAGS

PATHS_TO_ADD=(
    "$PYEXEC_DIR"
    "$ROOT/usr/bin"
    "$ROOT/bin"
    "$ROOT/usr/local/bin"
    "$ROOT/usr/bin"
)
LIBS_TO_ADD=(
    "$ROOT/usr/lib64"
    "$ROOT/lib64"
    "$ROOT/usr/lib"
    "$ROOT/lib"
    "$LLVM_DIR/lib"
)


unique_join() {
    local IFS=':'
    local seen=()
    for p in "$@"; do
        [[ -n "$p" && -d "$p" && ! " ${seen[*]} " =~ " $p " ]] && seen+=("$p")
    done
    echo "${seen[*]}"
}

export PATH="$(unique_join "${PATHS_TO_ADD[@]}"):$PATH"
export LD_LIBRARY_PATH="$(unique_join "${LIBS_TO_ADD[@]}")${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export MAGIC="$ROOT/usr/share/file/misc/magic.mgc"
export GIT_TEMPLATE_DIR="$ROOT/usr/share/git-core/templates"
export CPPFLAGS="-I$ROOT/usr/include"
export ACLOCAL_PATH="$ROOT/usr/share/aclocal${ACLOCAL_PATH:+:$ACLOCAL_PATH}"
export M4PATH="$ROOT/usr/share/m4${M4PATH:+:$M4PATH}"
export MANPATH="$ROOT/usr/share/man:$ROOT/usr/local/share/man${MANPATH:+:$MANPATH}"
export XDG_DATA_DIRS="$ROOT/usr/share:$ROOT/usr/local/share:/usr/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"
export DISPLAY=":0"
export GDK_BACKEND="wayland"
export CLUTTER_BACKEND="wayland"
export WAYLAND_DISPLAY=wayland-0
export WAYLAND_DISPLAY_LOW_DENSITY=wayland-1
export EGL_PLATFORM=wayland

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax )"
    export DBUS_SESSION_BUS_ADDRESS
    export DBUS_SESSION_BUS_PID
fi

ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    export LIBGL_DRIVERS_PATH="$ROOT/usr/lib64/dri"
    export LIBEGL_DRIVERS_PATH="$ROOT/usr/lib64/dri"
elif [[ "$ARCH" == "aarch64" ]]; then
    export LIBGL_DRIVERS_PATH="$ROOT/usr/lib/dri"
    export LIBEGL_DRIVERS_PATH="$ROOT/usr/lib/dri"
fi

export LD_LIBRARY_PATH=/usr/lib64\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}
export LIBGL_ALWAYS_INDIRECT=0
export QT_QPA_PLATFORM=wayland
export SOMMELIER_DRM_DEVICE=/dev/dri/renderD128
export SOMMELIER_GLAMOR=1
export SOMMELIER_VERSION=0.20

obs() {
    export QT_QPA_PLATFORM=xcb
    export OBS_VKCAPTURE=1
    export OBS_GAMECAPTURE=1
    local LD_PRELOAD_LIBS=(
        "/usr/lib64/obs-plugins/linux-vkcapture.so"
        "/usr/lib64/obs_glcapture/libobs_glcapture.so"
    )
    local LD_PRELOAD=""
    for lib in "${LD_PRELOAD_LIBS[@]}"; do
        [[ -f "$lib" ]] && LD_PRELOAD="${LD_PRELOAD:+$LD_PRELOAD:}$lib"
    done
    export LD_PRELOAD
    /usr/bin/obs "$@" &
}

#x() {
#    if [[ -z "$WAYLAND_DISPLAY" ]]; then
#        echo "ERROR: WAYLAND_DISPLAY is not set"
#        return 1
#    fi
#
#    [ ! -d /tmp/.X11-unix ] && sudo mkdir -p /tmp/.X11-unix && sudo chmod 1777 /tmp/.X11-unix
#
#    SOMMELIER_CMD="sommelier --noop-driver --display=$WAYLAND_DISPLAY -X --glamor --xwayland-path=/usr/libexec/Xwayland"
#
#    exec $SOMMELIER_CMD "$@"
#}

#sommelier --display=/run/chrome/wayland-0 --noop-driver --force-drm-device=/dev/dri/renderD128 -X --glamor --enable-linux-dmabuf --xwayland-path=/usr/libexec/Xwayland -- bash -c 'sleep 1; export DISPLAY=$(ls /tmp/.X11-unix | sed "s/^X/:/"); echo "DISPLAY=$DISPLAY"; [ -f ~/.bashrc ] && source ~/.bashrc; exec bash'

if [ -z "$XFCE_STARTED" ] && [ ! -f /tmp/.xfce_started ]; then
    export XFCE_STARTED=1
    if ! pgrep -x "startxfce4" >/dev/null 2>&1; then
        nohup sudo -u $USER bash -c 'DISPLAY=:1 startxfce4 >/tmp/xfce4.log 2>&1 &' &
        touch /tmp/.xfce_started
    fi
fi

MAKECONF="$ROOT/etc/portage/make.conf"
if [[ -w "$MAKECONF" ]]; then
    sed -i "/^PYTHON_TARGETS=/d" "$MAKECONF"
    sed -i "/^PYTHON_SINGLE_TARGET=/d" "$MAKECONF"
    echo "PYTHON_TARGETS=\"python${second_underscore}\"" >> "$MAKECONF"
    echo "PYTHON_SINGLE_TARGET=\"python${second_underscore}\"" >> "$MAKECONF"
fi

eselect python set "python${second_underscore}" 2>/dev/null || true
eselect python set --python3 "python${second_underscore}" 2>/dev/null || true

# Chard Scale
: "${CHARD_SCALE:=1.25}"
: "${XCURSOR_SIZE:=32}"
: "${XCURSOR_THEME:=Adwaita}"
export GDK_SCALE="$CHARD_SCALE"
export GDK_DPI_SCALE=1
export QT_SCALE_FACTOR="$CHARD_SCALE"
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_WAYLAND_FORCE_DPI=$(awk "BEGIN {print int(96 * $CHARD_SCALE)}")
export ELECTRON_FORCE_DEVICE_SCALE_FACTOR="$CHARD_SCALE"
export _JAVA_OPTIONS="-Dsun.java2d.uiScale=$CHARD_SCALE"
export XCURSOR_SIZE
export XCURSOR_THEME

safe_wine() {
    wineserver -k 2>/dev/null
    pkill -9 -f 'wine|winedevice|wineserver' 2>/dev/null
    sleep 0.5
    rm -rf ~/.wine/*.lock ~/.wine/dosdevices/* 2>/dev/null
    winegui
}

alias winegui='safe_wine'
# KSP
alias ksp='LC_ALL=C ./KSP_x86_64'

# xcb
alias pcsx2-qt='QT_QPA_PLATFORM=xcb pcsx2-qt'
alias seamonkey='GDK_BACKEND=x11 seamonkey'

alias cs='chard_sommelier'
alias smrt='SMRT'
dbus-daemon --system --fork 2>/dev/null

alias steam='/bin/chard_steam'

# <<< END CHARD .BASHRC >>>
