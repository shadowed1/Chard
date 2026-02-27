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
    x86_64) CHOST=x86_64-pc-linux-gnu ;;
    aarch64) CHOST=aarch64-unknown-linux-gnu ;;
    *) echo "Unknown architecture: $ARCH"; exit 1 ;;
esac

ARCH="aarch64"
sed -n -e "s|^${ARCH}[[:space:]]\+\([^[:space:]]\+\)[[:space:]]\+\([^[:space:]]\+\).*$|\1::\2|p" /usr/portage/profiles/profiles.desc > /dev/null 2>&1
ARCH="arm64"
sed -n -e "s|^${ARCH}[[:space:]]\+\([^[:space:]]\+\)[[:space:]]\+\([^[:space:]]\+\).*$|\1::\2|p" /usr/portage/profiles/profiles.desc > /dev/null 2>&1

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
export SANDBOX="$ROOT/usr/bin/sandbox"
export GIT_EXEC_PATH="$ROOT/usr/libexec/git-core"
export PYTHONMULTIPROCESSING_START_METHOD=fork

export PORTDIR="$ROOT/usr/portage"
export DISTDIR="$ROOT/var/cache/distfiles"
export PKGDIR="$ROOT/var/cache/packages"
export PORTAGE_TMPDIR="$ROOT/var/tmp"

# <<< CHARD_XDG_RUNTIME_DIR >>>
export XDG_RUNTIME_DIR=""
# <<< END CHARD_XDG_RUNTIME_DIR >>>

all_perl_versions=()

if [[ ${#all_perl_versions[@]} -eq 0 ]]; then
    PERL_BASES=("$ROOT/usr/lib64/perl5" "$ROOT/usr/local/lib64/perl5" "$ROOT/usr/lib/perl5" "$ROOT/usr/lib64/perl5")
    for base in "${PERL_BASES[@]}"; do
        [[ -d "$base" ]] || continue
        for dir in "$base"/*; do
            [[ -d "$dir" ]] || continue
            ver=$(basename "$dir" | grep -oP '^[0-9]+\.[0-9]+')
            [[ -n "$ver" ]] && all_perl_versions+=("$ver")
        done
    done
fi

mapfile -t all_perl_versions < <(printf '%s\n' "${all_perl_versions[@]}" | sort -V | uniq)

third_latest_perl=""
if (( ${#all_perl_versions[@]} >= 3 )); then
    third_latest_perl="${all_perl_versions[-3]}"
elif (( ${#all_perl_versions[@]} > 0 )); then
    third_latest_perl="${all_perl_versions[0]}"
fi

PERL5LIB=""
if [[ -n "$third_latest_perl" ]]; then
    PERL_BASES=("$ROOT/usr/lib64/perl5" "$ROOT/usr/local/lib64/perl5" "$ROOT/usr/lib/perl5" "$ROOT/usr/lib64/perl5")
    for base in "${PERL_BASES[@]}"; do
        for sub in "" "vendor_perl" "$CHOST" "vendor_perl/$CHOST"; do
            dir="$base/$third_latest_perl/$sub"
            if [[ -d "$dir" ]]; then
                PERL5LIB="$dir${PERL5LIB:+:$PERL5LIB}"
            fi
        done
    done
    export PERL5LIB
fi

PYEXEC_BASE="$ROOT/usr/lib/python-exec"
all_python_versions=()

if (( ${#all_python_versions[@]} == 0 )); then
    mapfile -t all_python_dirs < <(ls -1 "$PYEXEC_BASE" 2>/dev/null | grep -E '^python[0-9]+\.[0-9]+$' | sort -V)
    for d in "${all_python_dirs[@]}"; do
        ver="${d#python}"
        [[ -n "$ver" ]] && all_python_versions+=("$ver")
    done
fi

mapfile -t all_python_versions < <(printf '%s\n' "${all_python_versions[@]}" | sort -V | uniq)

latest_python=""
third_latest_python=""

if (( ${#all_python_versions[@]} > 0 )); then
    latest_python="${all_python_versions[-1]}"
fi
if (( ${#all_python_versions[@]} >= 3 )); then
    third_latest_python="${all_python_versions[-3]}"
elif (( ${#all_python_versions[@]} > 0 )); then
    third_latest_python="${all_python_versions[0]}"
fi

second_underscore="${third_latest_python//./_}"

export PYTHON_TARGETS="python${second_underscore}"
export PYTHON_SINGLE_TARGET="python${second_underscore}"

python_site_third="$ROOT/usr/lib/python${third_latest_python}/site-packages"
python_site_latest="$ROOT/usr/lib/python${latest_python}/site-packages"
export PYTHONPATH="${python_site_third}:${python_site_latest}${PYTHONPATH:+:$(realpath -m "$PYTHONPATH")}"

export PYEXEC_DIR="${PYEXEC_BASE}/python${third_latest_python}"
export EPYTHON="python${third_latest_python}"
export PYTHON="python${third_latest_python}"
export PORTAGE_PYTHON="python${third_latest_python}"

if command -v python3 >/dev/null && python3 --version 2>&1 | grep -q "$latest_python"; then
    alias python3="$ROOT/usr/bin/python${third_latest_python}"
fi

all_gcc_versions=()

if [[ ${#all_gcc_versions[@]} -eq 0 && -d "$ROOT/usr/$CHOST/gcc-bin" ]]; then
    for dir in "$ROOT/usr/$CHOST/gcc-bin"/*; do
        [[ -d "$dir" ]] || continue
        ver=$(basename "$dir")
        [[ $ver =~ ^[0-9]+$ ]] && all_gcc_versions+=("$ver")
    done
fi

mapfile -t all_gcc_versions < <(printf '%s\n' "${all_gcc_versions[@]}" | sort -V | uniq)

third_latest_gcc=""
if (( ${#all_gcc_versions[@]} >= 3 )); then
    third_latest_gcc="${all_gcc_versions[-3]}"
elif (( ${#all_gcc_versions[@]} > 0 )); then
    third_latest_gcc="${all_gcc_versions[0]}"
fi

if [[ -n "$third_latest_gcc" && -n "$CHOST" ]]; then
    gcc_bin_path="$ROOT/usr/$CHOST/gcc-bin/${third_latest_gcc}"
    gcc_lib_path="$ROOT/usr/lib/gcc/$CHOST/${third_latest_gcc}"
fi

export PATH="$gcc_bin_path:$PATH"
export LD_LIBRARY_PATH="$gcc_lib_path${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

LLVM_BASE="$ROOT/usr/lib/llvm"
all_llvm_versions=()
if [[ -d "$LLVM_BASE" ]]; then
    for d in "$LLVM_BASE"/*/; do
        [[ -d "$d" ]] || continue
        ver=$(basename "$d" | grep -oP '^[0-9]+(\.[0-9]+)?')
        [[ -n "$ver" ]] && all_llvm_versions+=("$ver")
    done
fi

mapfile -t all_llvm_versions < <(printf '%s\n' "${all_llvm_versions[@]}" | sort -V | uniq)

latest_llvm=""
third_latest_llvm=""

if (( ${#all_llvm_versions[@]} > 0 )); then
    latest_llvm="${all_llvm_versions[-1]}"
fi
if (( ${#all_llvm_versions[@]} >= 3 )); then
    third_latest_llvm="${all_llvm_versions[-3]}"
elif (( ${#all_llvm_versions[@]} > 0 )); then
    third_latest_llvm="${all_llvm_versions[0]}"
fi

LLVM_DIR=""
LLVM_LIB_DIR=""

if [[ -n "$third_latest_llvm" ]]; then
    LLVM_DIR="$LLVM_BASE/$third_latest_llvm"
    export LLVM_DIR
    export LLVM_VERSION="$third_latest_llvm"
    if [[ -d "$LLVM_DIR/lib64" ]]; then
        LLVM_LIB_DIR="$LLVM_DIR/lib64"
    elif [[ -d "$LLVM_DIR/lib" ]]; then
        LLVM_LIB_DIR="$LLVM_DIR/lib"
    fi
fi

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
    "$gcc_bin_path"
    "$LLVM_DIR/bin"
    "$ROOT/usr/local/bin"
    "$ROOT/usr/bin"
)
LIBS_TO_ADD=(
    "$ROOT/usr/lib64"
    "$ROOT/lib64"
    "$ROOT/usr/lib"
    "$ROOT/lib"
    "$gcc_lib_path"
    "$LLVM_LIB_DIR"
)
PKG_TO_ADD=(
    "$ROOT/usr/lib64/pkgconfig"
    "$ROOT/usr/lib/pkgconfig"
    "$ROOT/usr/local/lib/pkgconfig"
    "$ROOT/usr/local/share/pkgconfig"
    "$LLVM_LIB_DIR/pkgconfig"
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
export PKG_CONFIG_PATH="$(unique_join "${PKG_TO_ADD[@]}")${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
export MAGIC="$ROOT/usr/share/misc/magic.mgc"
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

CHARD_DBUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS/unix:path=\/tmp\//unix:path=$CHARD_ROOT\/tmp\/}"

sudo tee "/.chard_dbus" >/dev/null <<EOF
export DBUS_SESSION_BUS_ADDRESS='$CHARD_DBUS_ADDRESS'
export DBUS_SESSION_BUS_PID='$DBUS_SESSION_BUS_PID'
EOF

export LIBGL_DRIVERS_PATH="$CHARD_ROOT/usr/lib64/dri:$CHARD_ROOT/usr/lib/dri"
export LIBEGL_DRIVERS_PATH="$CHARD_ROOT/usr/lib64/dri:$CHARD_ROOT/usr/lib/dri"

export LD_LIBRARY_PATH=/usr/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
export LIBGL_ALWAYS_INDIRECT=0
export QT_QPA_PLATFORM=wayland
export SOMMELIER_DRM_DEVICE=/dev/dri/renderD128
export SOMMELIER_GLAMOR=1
export SOMMELIER_VERSION=0.20
export PULSE_SERVER=unix:/run/chrome/pulse/native

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

# Firefox
alias firefox-bin='chard_firefox-bin'
alias firefox='chard_firefox-bin'
alias torbrowser-launcher='/bin/chard_tor'
alias thunderbird='/bin/chard_thunderbird'
alias torbrowser-launcher-bin='/bin/chard_tor'
alias thunderbird-bin='/bin/chard_thunderbird'
# Brave
#export BRAVE_USE_SYSTEM_KEYRING=0
alias brave='brave-browser-stable --force-dark-mode --enable-features=WebUIDarkMode'

# KSP
alias ksp='LC_ALL=C ./KSP_x86_64'

# xcb
alias pcsx2-qt='QT_QPA_PLATFORM=xcb pcsx2-qt'
alias seamonkey='GDK_BACKEND=x11 seamonkey'
alias powercontrol-gui='sudo -E powercontrol-gui'
alias cs='chard_sommelier'
alias smrt='SMRT'
alias gparted='sudo -E gparted'
export EMERGE_DEFAULT_OPTS=--quiet-build=y
dbus-daemon --system --fork 2>/dev/null

# virtm
alias virtm='sudo -E virtm'

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
