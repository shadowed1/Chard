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
CHROME_VER=$(cat /.chard_chrome)
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
    "$ROOT/usr/lib32"
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

ARCH="$(uname -m)"
if [ "$ARCH" = "x86_64" ]; then
export PULSE_SERVER=unix:/run/chrome/pulse/native
fi

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax )"
    export DBUS_SESSION_BUS_ADDRESS
    export DBUS_SESSION_BUS_PID
fi

CHARD_DBUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS/unix:path=\/tmp\//unix:path=$CHARD_ROOT\/tmp\/}"

sudo tee "/.chard_dbus" >/dev/null <<EOF
export DBUS_SESSION_BUS_ADDRESS='$CHARD_DBUS_ADDRESS'
export DBUS_SESSION_BUS_PID='$DBUS_SESSION_BUS_PID'
EOF

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
    /usr/bin/obs "$@" &
}

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
alias gvim='wx gvim'
alias prismlauncher='chard_prismlauncher'
alias cs='chard_sommelier'
alias smrt='SMRT'
alias gparted='sudo -E gparted'
alias isoimagewriter='QT_QPA_PLATFORM=xcb isoimagewriter'

alias ls='ls --color=auto'
#dbus-daemon --system --fork 2>/dev/null

# Steam
alias steam='/bin/chard_steam'

# Firefox
alias firefox='/bin/chard_firefox'
alias torbrowser-launcher='/bin/chard_tor'
alias thunderbird='/bin/chard_thunderbird'
#export MOZ_CUBEB_FORCE_PULSE=1

# Brave
#export BRAVE_USE_SYSTEM_KEYRING=0
alias brave='brave --force-dark-mode --enable-features=WebUIDarkMode'

# Flatpak
alias flatpak='/bin/chard_flatpak'

# Dolphin
alias dolphin='QT_QPA_PLATFORM=xcb dolphin'

# Gwenview
alias gwenview='QT_QPA_PLATFORM=xcb gwenview'

# Handbrake
alias handbrake='ghb'

# Powercontrol
alias powercontrol-gui='sudo -E powercontrol-gui'

# virtm
alias virtm='sudo -E virtm'

command -v chard_refresh >/dev/null && chard_refresh

export EDITOR=gedit

# <<< CHARD_SMRT >>>
SMRT_ENV_FILE="$HOME/.smrt_env.sh"

smrt_refresh_prompt() {
    [[ -f "$SMRT_ENV_FILE" ]] && source "$SMRT_ENV_FILE" 2>/dev/null
}

case "$PROMPT_COMMAND" in
  *smrt_refresh_prompt*) ;;
  *) PROMPT_COMMAND="smrt_refresh_prompt; $PROMPT_COMMAND" ;;
esac
# <<< END_CHARD_SMRT >>>

# <<< END CHARD .BASHRC >>>
