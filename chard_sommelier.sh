#!/bin/bash
# <<< CHARD .SOMMELIER >>>

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
export XDG_RUNTIME=""
# <<< END CHARD_XDG_RUNTIME_DIR >>>

# <<< CHARD_MESA_MARKER >>>"
export MESA_DRIVER=""
# <<< END CHARD_MESA_MARKER >>>"


all_perl_versions=()

if command -v equery >/dev/null 2>&1; then
    while read -r line; do
        # Example line: [IP-] [  ] dev-lang/perl-5.40.0:5.40
        ver=$(echo "$line" | grep -oP 'dev-lang/perl-\K[0-9]+\.[0-9]+')
        [[ -n "$ver" ]] && all_perl_versions+=("$ver")
    done < <(equery list -p dev-lang/perl 2>/dev/null | grep 'dev-lang/perl-')
fi

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

if command -v equery >/dev/null 2>&1; then
    while read -r line; do
        ver=$(echo "$line" | grep -oP 'dev-lang/python-\K[0-9]+\.[0-9]+')
        [[ -n "$ver" ]] && all_python_versions+=("$ver")
    done < <(equery list -p dev-lang/python 2>/dev/null | grep 'dev-lang/python-')
fi

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

if command -v equery >/dev/null 2>&1; then
    while read -r line; do
        ver=$(echo "$line" | grep -oP 'sys-devel/gcc-\K[0-9]+')
        [[ -n "$ver" ]] && all_gcc_versions+=("$ver")
    done < <(equery list -p sys-devel/gcc 2>/dev/null | grep 'sys-devel/gcc-')
fi

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

if command -v equery >/dev/null 2>&1; then
    while read -r line; do
        ver=$(echo "$line" | grep -oP 'llvm-core/llvm-\K[0-9]+\.[0-9]+')
        [[ -n "$ver" ]] && all_llvm_versions+=("$ver")
    done < <(equery list -p llvm-core/llvm 2>/dev/null | grep 'llvm-core/llvm-')
fi

if [[ ${#all_llvm_versions[@]} -eq 0 ]] && [[ -d "$LLVM_BASE" ]]; then
    echo "Equery not available or no versions found, scanning $LLVM_BASE..."
    for d in "$LLVM_BASE"/*/; do
        [[ -d "$d" ]] || continue
        ver=$(basename "$d" | grep -oP '^[0-9]+\.[0-9]+')
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

if [[ -n "$third_latest_llvm" ]]; then
    LLVM_DIR="$LLVM_BASE/$third_latest_llvm"
    export LLVM_DIR
    export LLVM_VERSION="$third_latest_llvm"
    [[ -d "$LLVM_DIR/bin" ]] && export PATH="$LLVM_DIR/bin:$PATH"
    [[ -d "$LLVM_DIR/lib" ]] && export LD_LIBRARY_PATH="$LLVM_DIR/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    [[ -d "$LLVM_DIR/lib/pkgconfig" ]] && export PKG_CONFIG_PATH="$LLVM_DIR/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
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
    "$LLVM_DIR/lib"
)
PKG_TO_ADD=(
    "$ROOT/usr/lib/pkgconfig"
    "$ROOT/usr/lib64/pkgconfig"
    "$ROOT/usr/local/lib/pkgconfig"
    "$ROOT/usr/local/share/pkgconfig"
    "$LLVM_DIR/lib/pkgconfig"
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

export LIBGL_DRIVERS_PATH="$ROOT/usr/lib64/dri"
export LIBEGL_DRIVERS_PATH="$ROOT/usr/lib64/dri"
export LD_LIBRARY_PATH=/usr/lib64\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}
export LIBGL_ALWAYS_INDIRECT=0
export QT_QPA_PLATFORM=wayland
export SOMMELIER_DRM_DEVICE=/dev/dri/renderD128
export SOMMELIER_GLAMOR=1
export SOMMELIER_VERSION=0.20

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

alias smrt='SMRT'
dbus-daemon --system --fork 2>/dev/null
export EMERGE_DEFAULT_OPTS=--quiet-build=y

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
