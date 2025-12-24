#!/bin/bash

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
CLEANUP_ENABLED=0

cleanup_chroot() {
        [[ "$CLEANUP_ENABLED" -eq 1 ]] || return 0
        sudo umount -l "$CHARD_ROOT/run/cras"   2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/udev"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/dbus"   2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/chrome" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/etc/ssl"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/pts"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/shm"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev"        2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/sys"        2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/proc"       2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/$CHARD_HOME/external" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/user/1000" 2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"               2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT" 2>/dev/null || true
        sleep 0.05
        sudo setfacl -Rb /run/chrome 2>/dev/null
        sudo chown -R root:audio /dev/snd 2>/dev/null
        sudo chown -R root:root /dev/snd/by-path 2>/dev/null
        sudo umount -l "$CHARD_ROOT/run/cras"   2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/udev"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/dbus"   2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/chrome" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/etc/ssl"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/pts"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/shm"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev"        2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/sys"        2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/proc"       2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/user/1000" 2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"               2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT" 2>/dev/null || true
        sleep 0.05
        sudo setfacl -Rb /run/chrome 2>/dev/null
        sudo chown -R root:audio /dev/snd 2>/dev/null
        sudo chown -R root:root /dev/snd/by-path 2>/dev/null
}

trap cleanup_chroot EXIT INT TERM

CHARD_RC="$CHARD_ROOT/.chardrc"

if [ -f "$CHARD_RC" ]; then
    source "$CHARD_RC"
else
    echo "Please run Chard commands outside of Chard Root"
    exit 1
fi

CHARD_BASH="/bin/bash"
if [ ! -x "$CHARD_BASH" ]; then
    echo "ERROR: /bin/bash not found on host system!"
    return 1
fi

ARCH=$(uname -m)
case "$ARCH" in
    x86_64) CHOST=x86_64-pc-linux-gnu ;;
    aarch64) CHOST=aarch64-unknown-linux-gnu ;;
    *) echo "Unknown architecture: $ARCH"; exit 1 ;;
esac

chard_unmount() { 
        echo
        echo "${RESET}${YELLOW}Chard unmounting... ${RESET}"
        echo
        sudo umount -l "$CHARD_ROOT/run/cras"   2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/udev"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/dbus"   2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/chrome" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/etc/ssl"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/pts"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/shm"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev"        2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/sys"        2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/proc"       2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/user/1000" 2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"               2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT" 2>/dev/null || true
        sleep 0.05
        sudo setfacl -Rb /run/chrome 2>/dev/null
        sudo umount -l "$CHARD_ROOT/run/cras"   2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/udev"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/dbus"   2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/chrome" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/etc/ssl"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/pts"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/shm"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev"        2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/sys"        2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/proc"       2>/dev/null || true
        sleep 0.05
        $CHARD_ROOT/bin/chard_unmount
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/user/1000" 2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"               2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT" 2>/dev/null || true
        sleep 0.05
        sudo setfacl -Rb /run/chrome 2>/dev/null
        echo "${RESET}${GREEN}Chard safely unmounted${RESET}"
        echo
}

chard_run() {
    if [ $# -lt 1 ]; then
        echo "${GREEN}chard ${RESET}${RED}binary${YELLOW} --args${RESET}"
        return 1
    fi

    ARCH=$(uname -m)
        case "$ARCH" in
            x86_64) CHOST=x86_64-pc-linux-gnu ;;
            aarch64) CHOST=aarch64-unknown-linux-gnu ;;
            *) echo "Unknown architecture: $ARCH"; exit 1 ;;
        esac

HOME="$CHARD_ROOT/$CHARD_HOME"
USER="$CHARD_USER"

export LANG=C.UTF-8
export LC_ALL=C.UTF-8

if [[ "$CHARD_ROOT" != "/" ]]; then
    ROOT="${ROOT%/}"
fi

export ARCH
export CHOST
export CHARD_RC="$CHARD_ROOT/.chardrc"
export SANDBOX="$CHARD_ROOT/usr/bin/sandbox"
export GIT_EXEC_PATH="$CHARD_ROOT/usr/libexec/git-core"
export PYTHONMULTIPROCESSING_START_METHOD=fork
export PORTDIR="$CHARD_ROOT/usr/portage"
export DISTDIR="$CHARD_ROOT/var/cache/distfiles"
export PKGDIR="$CHARD_ROOT/var/cache/packages"
export PORTAGE_TMPDIR="$CHARD_ROOT/var/tmp"
export XDG_RUNTIME_DIR="/run/chrome/"

export GTK_PATH="$CHARD_ROOT/usr/lib/gtk-3.0:$CHARD_ROOT/usr/lib64/gtk-3.0"
export GTK_EXE_PREFIX="$CHARD_ROOT/usr"
export GTK_DATA_PREFIX="$CHARD_ROOT/usr"
export GDK_PIXBUF_MODULEDIR="$CHARD_ROOT/usr/lib64/gdk-pixbuf-2.0/2.10.0/loaders"
export GDK_PIXBUF_MODULE_FILE="$CHARD_ROOT/usr/lib64/gdk-pixbuf-2.0/2.10.0/loaders.cache"

export FLATPAK_SYSTEM_DIR="$CHARD_ROOT/var/lib/flatpak"
export FLATPAK_USER_DIR="$HOME/.local/share/flatpak"
export FLATPAK_SYSTEM_HELPER="$CHARD_ROOT/usr/libexec/flatpak-system-helper"
export TMPDIR="$CHARD_ROOT/tmp"
export TMP="$CHARD_ROOT/tmp"
export TEMP="$CHARD_ROOT/tmp"
export FONTCONFIG_PATH="$CHARD_ROOT/etc/fonts"
export FONTCONFIG_FILE="$CHARD_ROOT/etc/fonts/fonts.conf"
export GIO_MODULE_DIR="$CHARD_ROOT/usr/lib64/gio/modules"
export GSETTINGS_SCHEMA_DIR="$CHARD_ROOT/usr/share/glib-2.0/schemas"
export GSETTINGS_BACKEND="memory"
export XAUTHORITY="$CHARD_ROOT/tmp/.Xauthority"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export LIBRARY_PATH="$CHARD_ROOT/usr/lib64:$CHARD_ROOT/usr/lib:$CHARD_ROOT/lib64:$CHARD_ROOT/lib"
export LIBGL_DRIVERS_PATH="$CHARD_ROOT/usr/lib64/dri:$CHARD_ROOT/usr/lib/dri"
export __GLX_VENDOR_LIBRARY_NAME=mesa
export PORTAGE_CONFIGROOT="$CHARD_ROOT"
export SYSROOT="$CHARD_ROOT"

all_perl_versions=()

if [[ ${#all_perl_versions[@]} -eq 0 ]]; then
    PERL_BASES=(
        "$CHARD_ROOT/usr/lib64/perl5"
        "$CHARD_ROOT/usr/local/lib64/perl5"
        "$CHARD_ROOT/usr/lib/perl5"
    )

    for base in "${PERL_BASES[@]}"; do
        [[ -d "$base" ]] || continue

        for dir in "$base"/*; do
            [[ -d "$dir" ]] || continue

            name=$(basename "$dir")
            ver=$(printf '%s\n' "$name" | sed -n 's/^\([0-9]\+\.[0-9]\+\).*$/\1/p')

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
    PERL_BASES=("$CHARD_ROOT/usr/lib64/perl5" "$CHARD_ROOT/usr/local/lib64/perl5" "$CHARD_ROOT/usr/lib/perl5" "$CHARD_ROOT/usr/lib64/perl5")
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

PYEXEC_BASE="$CHARD_ROOT/usr/lib/python-exec"
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

python_site_third="$CHARD_ROOT/usr/lib/python${third_latest_python}/site-packages"
python_site_latest="$CHARD_ROOT/usr/lib/python${latest_python}/site-packages"
export PYTHONPATH="${python_site_third}:${python_site_latest}${PYTHONPATH:+:$(realpath -m "$PYTHONPATH")}"

export PYEXEC_DIR="${PYEXEC_BASE}/python${third_latest_python}"
export EPYTHON="python${third_latest_python}"
export PYTHON="python${third_latest_python}"
export PORTAGE_PYTHON="python${third_latest_python}"

if command -v python3 >/dev/null && python3 --version 2>&1 | grep -q "$latest_python"; then
    alias python3="$CHARD_ROOT/usr/bin/python${third_latest_python}"
fi

all_gcc_versions=()

if [[ ${#all_gcc_versions[@]} -eq 0 && -d "$CHARD_ROOT/usr/$CHOST/gcc-bin" ]]; then
    for dir in "$CHARD_ROOT/usr/$CHOST/gcc-bin"/*; do
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
    gcc_bin_path="$CHARD_ROOT/usr/$CHOST/gcc-bin/${third_latest_gcc}"
    gcc_lib_path="$CHARD_ROOT/usr/lib/gcc/$CHOST/${third_latest_gcc}"
fi

export PATH="$gcc_bin_path:$PATH"
export LD_LIBRARY_PATH="$gcc_lib_path${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

LLVM_BASE="$CHARD_ROOT/usr/lib/llvm"
all_llvm_versions=()

if [[ ${#all_llvm_versions[@]} -eq 0 ]] && [[ -d "$LLVM_BASE" ]]; then
    for d in "$LLVM_BASE"/*; do
        [[ -d "$d" ]] || continue

        name=$(basename "$d")
        ver=$(printf '%s\n' "$name" | sed -n 's/^\([0-9]\+\.[0-9]\+\).*$/\1/p')

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

export CC="$CHARD_ROOT/usr/bin/gcc"
export CXX="$CHARD_ROOT/usr/bin/g++"
export AR="$CHARD_ROOT/usr/bin/ar"
export NM="$CHARD_ROOT/usr/bin/gcc-nm"
export RANLIB="$CHARD_ROOT/usr/bin/gcc-ranlib"
export STRIP="$CHARD_ROOT/usr/bin/strip"
export LD="$CHARD_ROOT/usr/bin/ld"
export MOZ_APP_LAUNCHER="$CHARD_ROOT/usr/bin/firefox-bin"

# <<< CHARD_MARCH_NATIVE >>>
CFLAGS="-march=native -O2 -pipe "
[[ -d "$CHARD_ROOT/usr/include" ]] && CFLAGS+="-I$CHARD_ROOT/usr/include "
[[ -d "$CHARD_ROOT/include" ]] && CFLAGS+="-I$CHARD_ROOT/include "
export CFLAGS
COMMON_FLAGS="-march=native -O2 -pipe"
FCFLAGS="$COMMON_FLAGS"
FFLAGS="$COMMON_FLAGS"
CXXFLAGS="$CFLAGS"
# <<< END CHARD_MARCH_NATIVE >>>

LDFLAGS=""
[[ -d "$CHARD_ROOT/usr/lib64" ]] && LDFLAGS+="-L$CHARD_ROOT/usr/lib64 "
[[ -d "$CHARD_ROOT/lib64" ]] && LDFLAGS+="-L$CHARD_ROOT/lib64 "
[[ -d "$CHARD_ROOT/usr/local/lib64" ]] && LDFLAGS+="-L$CHARD_ROOT/usr/local/lib64 "
[[ -d "$CHARD_ROOT/usr/lib" ]] && LDFLAGS+="-L$CHARD_ROOT/usr/lib "
[[ -d "$CHARD_ROOT/lib" ]] && LDFLAGS+="-L$CHARD_ROOT/lib "
[[ -d "$CHARD_ROOT/usr/local/lib" ]] && LDFLAGS+="-L$CHARD_ROOT/usr/local/lib "
[[ -d "$CHARD_ROOT/opt" ]] && LDFLAGS+="-L$CHARD_ROOT/opt "
export LDFLAGS
export FCFLAGS
export FFLAGS

PATHS_TO_ADD=(
    "$PYEXEC_DIR"
    "$CHARD_ROOT/usr/bin"
    "$CHARD_ROOT/bin"
    "$gcc_bin_path"
    "$LLVM_DIR/bin"
    "$CHARD_ROOT/usr/local/bin"
    "$CHARD_ROOT/usr/bin"
    "$CHARD_ROOT/opt"
    "$CHARD_ROOT/opt/firefox"
)
LIBS_TO_ADD=(
    "$CHARD_ROOT/usr/lib"
    "$CHARD_ROOT/usr/lib64/gedit"
    "$CHARD_ROOT/lib"
    "$CHARD_ROOT/usr/lib64/glib-2.0"
    "$CHARD_ROOT/usr/lib64/gtk-3.0"
    "$CHARD_ROOT/usr/lib/gtk-3.0" 
    "$gcc_lib_path"
    "$LLVM_DIR/lib"
    "$CHARD_ROOT/opt"
    "$CHARD_ROOT/opt/firefox"
    #"$CHARD_ROOT/usr/lib64"
    #"$CHARD_ROOT/lib64"
)
PKG_TO_ADD=(
    "$CHARD_ROOT/usr/lib/pkgconfig"
    "$CHARD_ROOT/usr/lib64/pkgconfig"
    "$CHARD_ROOT/usr/local/lib/pkgconfig"
    "$CHARD_ROOT/usr/local/share/pkgconfig"
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

export LD_LIBRARY_PATH="$(unique_join "${LIBS_TO_ADD[@]}")${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export PKG_CONFIG_PATH="$(unique_join "${PKG_TO_ADD[@]}")${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
export MAGIC="$CHARD_ROOT/usr/share/misc/magic.mgc"
export GIT_TEMPLATE_DIR="$CHARD_ROOT/usr/share/git-core/templates"
export CPPFLAGS="-I$CHARD_ROOT/usr/include"
export ACLOCAL_PATH="$CHARD_ROOT/usr/share/aclocal${ACLOCAL_PATH:+:$ACLOCAL_PATH}"
export M4PATH="$CHARD_ROOT/usr/share/m4${M4PATH:+:$M4PATH}"
export MANPATH="$CHARD_ROOT/usr/share/man:$CHARD_ROOT/usr/local/share/man${MANPATH:+:$MANPATH}"
export XDG_DATA_DIRS="$CHARD_ROOT/usr/share:$CHARD_ROOT/usr/local/share:/usr/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"
export DISPLAY=":0"
export GDK_BACKEND="wayland"
export CLUTTER_BACKEND="wayland"
export WAYLAND_DISPLAY=wayland-0
export WAYLAND_DISPLAY_LOW_DENSITY=wayland-1
export EGL_PLATFORM=wayland

ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    export LIBGL_DRIVERS_PATH="$CHARD_ROOT/usr/lib64/dri"
    export LIBEGL_DRIVERS_PATH="$CHARD_ROOT/usr/lib64/dri"
elif [[ "$ARCH" == "aarch64" ]]; then
    export LIBGL_DRIVERS_PATH="$CHARD_ROOT/usr/lib/dri"
    export LIBEGL_DRIVERS_PATH="$CHARD_ROOT/usr/lib/dri"
fi

export PATH="$PATH:$(unique_join "${PATHS_TO_ADD[@]}")"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH:+$PKG_CONFIG_PATH:}$(unique_join "${PKG_TO_ADD[@]}")"
export LIBGL_ALWAYS_INDIRECT=0
export QT_QPA_PLATFORM=wayland
export SOMMELIER_DRM_DEVICE=/dev/dri/renderD128
export SOMMELIER_GLAMOR=1
export SOMMELIER_VERSION=0.20
export PULSE_SERVER=unix:/run/chrome/pulse/native

MAKECONF="$CHARD_ROOT/etc/portage/make.conf"
if [[ -w "$MAKECONF" ]]; then
    sed -i "/^PYTHON_TARGETS=/d" "$MAKECONF"
    sed -i "/^PYTHON_SINGLE_TARGET=/d" "$MAKECONF"
    echo "PYTHON_TARGETS=\"python${second_underscore}\"" >> "$MAKECONF"
    echo "PYTHON_SINGLE_TARGET=\"python${second_underscore}\"" >> "$MAKECONF"
fi

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax )"
    export DBUS_SESSION_BUS_ADDRESS
    export DBUS_SESSION_BUS_PID
fi

CHARD_DBUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS/unix:path=\/tmp\//unix:path=$CHARD_ROOT\/tmp\/}"

sudo env -u LD_LIBRARY_PATH -u LD_PRELOAD \
    tee "$CHARD_ROOT/.chard_dbus" >/dev/null <<EOF
export DBUS_SESSION_BUS_ADDRESS='$CHARD_DBUS_ADDRESS'
export DBUS_SESSION_BUS_PID='$DBUS_SESSION_BUS_PID'
EOF

export DBUS_SYSTEM_BUS_ADDRESS="unix:path=$CHARD_ROOT/run/dbus/system_bus_socket"

if [ -f "/home/chronos/user/.bashrc" ]; then
    if [ -d "/usr/share/fydeos_shell" ]; then
        DEFAULT_BASHRC="$HOME/.bashrc"
        BASHRC_PATH="$DEFAULT_BASHRC"
        IS_CHROMEOS=0
    else
        CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
        BASHRC_PATH="$CHROMEOS_BASHRC"
        IS_CHROMEOS=1
    fi
else
    DEFAULT_BASHRC="$HOME/.bashrc"
    BASHRC_PATH="$DEFAULT_BASHRC"
    IS_CHROMEOS=0
fi

ORIGINAL_LD_PRELOAD="$LD_PRELOAD"

if [ "$IS_CHROMEOS" -eq 1 ]; then
    unset LD_PRELOAD
    [ -f "$CHARD_ROOT/.chard_stage3_preload" ] && source "$CHARD_ROOT/.chard_stage3_preload"
fi

echo "[*] Running '$*' inside Chard environment..."

env \
    ROOT="$CHARD_ROOT" \
    PORTAGE_CONFIGROOT="$PORTAGE_CONFIGROOT" \
    PORTAGE_TMPDIR="$PORTAGE_TMPDIR" \
    DISTDIR="$DISTDIR" \
    PKGDIR="$PKGDIR" \
    PATH="$PATH" \
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH" \
    SANDBOX="$SANDBOX" \
    FEATURES="$FEATURES" \
    USE="$USE" \
    PYTHON_TARGETS="$PYTHON_TARGETS" \
    PYTHON_SINGLE_TARGET="$PYTHON_SINGLE_TARGET" \
    PYTHONPATH="$PYTHONPATH" \
    HOME="$CHARD_ROOT/$CHARD_HOME" \
    "$@"

COMMAND_EXIT_CODE=$?

unset LD_PRELOAD
[ -f "$CHARD_ROOT/.chard.preload" ] && source "$CHARD_ROOT/.chard.preload"

if [ -n "$ORIGINAL_LD_PRELOAD" ]; then
    export LD_PRELOAD="$ORIGINAL_LD_PRELOAD"
fi

return $COMMAND_EXIT_CODE
}

chard_uninstall() {
    if [ -z "$CHARD_ROOT" ]; then
        echo "Error: CHARD_ROOT not found."
        exit 1
    fi

    local script="$CHARD_ROOT/Uninstall_Chard.sh"

    if [ -d "$CHARD_ROOT" ]; then
        if [ -x "$script" ]; then
            echo "Uninstalling Chard..."
            sudo bash "$script"
        else
            sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/Uninstall_Chard.sh"  -o "$CHARD_ROOT/bin/Uninstall_Chard.sh"
            sudo chmod +x "$CHARD_ROOT/bin/Uninstall_Chard.sh"
            $CHARD_ROOT/bin/Uninstall_Chard.sh
        fi
    else
        echo "${RED}Installation directory not found: $CHARD_ROOT ${RESET}"
        exit 1
    fi
}

cmd="$1"; shift || true

case "$cmd" in
    ""|run)
        chard_run "$@"
        ;;
    help)
        CLEANUP_ENABLED=0
        echo
        echo "${GREEN}Chard commands:"
        echo "  chard <binary> <arguments>    -- to run a command wrapped within /usr/local/chard paths outside of chroot (Not fully supported right now)"
        echo "  chard root | cr               -- Enter Chard Chroot with Sommelier Xwayland GPU acceleration with OpenGL,Vulkan, GUI, and audio support."
        echo "  chard reinstall               -- Option 1 for FAST reinstall. Option 2 is a FULL reinstall."
        echo "  chard uninstall               -- Remove Chard environment and entries"
        echo "  chard categories | chard cat  -- List available Portage categories"
        echo "  chard chariot or chariot      -- Chard companion tool for setting itself up with a checkpoint system."
        echo "  chard version                 -- Check for updates"
        echo "  chard help                    -- Show this help message"
        echo "${RESET}${CYAN}"
        echo "Inside Chard Root:"
        echo
        echo "  SMRT or SMRT <1-100>            -- For compiling, auto allocate threads or specify in % how many threads you want to allocate."
        echo "${RESET}"
        echo
        ;;
    uninstall)
         CLEANUP_ENABLED=1
         chard_uninstall
        ;;
    root)
        CLEANUP_ENABLED=1
        chard_volume > /dev/null 2>&1 &
        sudo rm -f /run/chrome/pipewire-0.lock /run/chrome/pipewire-0-manager.lock 2>/dev/null
        sudo rm -f /run/chrome/pulse/native /run/chrome/pulse/* 2>/dev/null
        killall -9 pipewire 2>/dev/null
        killall -9 pipewire-pulse 2>/dev/null
        killall -9 pulseaudio 2>/dev/null
        killall -9 steam 2>/dev/null
        
        sudo chown root:root "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null
        sudo chmod u+s "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null
        sudo chown root:root "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null
        sudo chmod u+s "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null
        
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/chrome" || sudo mount --bind /run/chrome "$CHARD_ROOT/run/chrome" 2>/dev/null
            sudo mountpoint -q "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" || sudo mount --bind "/home/chronos/user/MyFiles/Downloads" "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null
            sudo mount -o remount,rw,bind "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null
            $CHARD_ROOT/bin/chard_mount 2>/dev/null
        else
            sudo mountpoint -q "$CHARD_ROOT/run/user/1000" || sudo mount --bind /run/user/1000 "$CHARD_ROOT/run/user/1000" 2>/dev/null
        fi
        
        sudo mountpoint -q "$CHARD_ROOT/run/dbus"   || sudo mount --bind /run/dbus "$CHARD_ROOT/run/dbus" 2>/dev/null
        sudo mountpoint -q "$CHARD_ROOT/run/udev"   || sudo mount --bind /run/udev "$CHARD_ROOT/run/udev" 2>/dev/null
        sudo mountpoint -q "$CHARD_ROOT/dev/dri"    || sudo mount --bind /dev/dri "$CHARD_ROOT/dev/dri" 2>/dev/null
        sudo mountpoint -q "$CHARD_ROOT/dev/input"  || sudo mount --bind /dev/input "$CHARD_ROOT/dev/input" 2>/dev/null
        
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/cras "$CHARD_ROOT/run/cras" 2>/dev/null
        else
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/user/1000/pulse "$CHARD_ROOT/run/cras" 2>/dev/null
        fi
        
        sudo chroot "$CHARD_ROOT" /bin/bash -c '
        
            mountpoint -q /proc       || mount -t proc proc /proc 2>/dev/null
            mountpoint -q /sys        || mount -t sysfs sys /sys 2>/dev/null
            mountpoint -q /dev        || mount -t devtmpfs devtmpfs /dev 2>/dev/null
            mountpoint -q /dev/shm    || mount -t tmpfs tmpfs /dev/shm 2>/dev/null
            mountpoint -q /dev/pts    || mount -t devpts devpts /dev/pts 2>/dev/null
            mountpoint -q /etc/ssl    || mount --bind /etc/ssl /etc/ssl 2>/dev/null
            mountpoint -q /run/dbus   || mount --bind /run/dbus /run/dbus 2>/dev/null
            mountpoint -q /run/udev   || mount --bind /run/udev /run/udev 2>/dev/null
            mountpoint -q /run/chrome || mount --bind /run/chrome /run/chrome 2>/dev/null
        
            if [ -e /dev/zram0 ]; then
                mount --rbind /dev/zram0 /dev/zram0 2>/dev/null
                mount --make-rslave /dev/zram0 2>/dev/null
            fi
        
            chmod 1777 /tmp /var/tmp
        
            [ -e /dev/null    ] || mknod -m 666 /dev/null c 1 3
            [ -e /dev/tty     ] || mknod -m 666 /dev/tty c 5 0
            [ -e /dev/random  ] || mknod -m 666 /dev/random c 1 8
            [ -e /dev/urandom ] || mknod -m 666 /dev/urandom c 1 9
        
            CHARD_HOME=$(cat /.chard_home)
            HOME=$CHARD_HOME
            CHARD_USER=$(cat /.chard_user)
            USER=$CHARD_USER
            GROUP_ID=1000
            USER_ID=1000
        
            sudo -u "$USER" bash -c "
                cleanup() {
                    echo \"Logging out $USER\"
                    if [ -n \"\$PULSEAUDIO_PID\" ]; then
                        kill -9 \"\$PULSEAUDIO_PID\" 2>/dev/null
                    fi
                }
                trap cleanup EXIT INT TERM
                sudo rm -f /run/chrome/pipewire-0.lock /run/chrome/pipewire-0-manager.lock 2>/dev/null
                sudo rm -f /run/chrome/pulse/native /run/chrome/pulse/* 2>/dev/null
                killall -9 pipewire 2>/dev/null
                killall -9 pipewire-pulse 2>/dev/null
                killall -9 pulseaudio 2>/dev/null
                sudo chown -R 1000:audio /dev/snd
                sudo chown -R 1000:1000 /dev/snd/by-path
                sudo mkdir -p /run/chrome/pulse
                sudo chown 1000:1000 /run/chrome/pulse 2>/dev/null
                sudo chown -R 1000:1000 /run/chrome/dconf 2>/dev/null
                sudo chmod 770 /run/chrome/pulse
                sudo setfacl -Rm u:1000:rwx /root 2>/dev/null
                [ -f \"\$HOME/.bashrc\" ] && source \"\$HOME/.bashrc\" 2>/dev/null
                [ -f \"\$HOME/.smrt_env.sh\" ] && source \"\$HOME/.smrt_env.sh\"
                xfce4-terminal 2>/dev/null &
                exec chard_sommelier
            "
            setfacl -Rb /run/chrome/pulse 2>/dev/null
            setfacl -Rb /run/chrome 2>/dev/null
            killall -9 pipewire 2>/dev/null
            killall -9 pipewire-pulse 2>/dev/null
            killall -9 pulseaudio 2>/dev/null
            killall -9 chardwire 2>/dev/null
            
            sudo chown -R root:audio /dev/snd 2>/dev/null
            sudo chown -R root:root /dev/snd/by-path 2>/dev/null
            setfacl -Rb /root 2>/dev/null
            umount -l /dev/zram0   2>/dev/null || true
            umount -l /run/chrome  2>/dev/null || true
            umount -l /run/udev    2>/dev/null || true
            umount -l /run/dbus    2>/dev/null || true
            umount -l /etc/ssl     2>/dev/null || true
            umount -l /dev/pts     2>/dev/null || true
            umount -l /dev/shm     2>/dev/null || true
            umount -l /dev         2>/dev/null || true
            umount -l /sys         2>/dev/null || true
            umount -l /proc        2>/dev/null || true
        '
        killall -9 chard_volume 2>/dev/null
        chard_unmount
        sudo rm -f /run/chrome/pulse/native
        sudo rm -f /run/chrome/pulse/*
        sudo mkdir -p /run/chrome/pulse
        sudo chown chronos:chronos /run/chrome/pulse
        sudo chmod 770 /run/chrome/pulse
        killall -9 cras_test_client 2>/dev/null
        killall -9 pipewire 2>/dev/null
        killall -9 pipewire-pulse 2>/dev/null
        killall -9 pulseaudio 2>/dev/null
        killall -9 steam 2>/dev/null
        sudo pkill -f xfce4-session 2>/dev/null
        sudo pkill -f xfwm4 2>/dev/null
        sudo pkill -f xfce4-panel 2>/dev/null
        sudo pkill -f xfdesktop 2>/dev/null
        sudo pkill -f xfce4-terminal 2>/dev/null
        sudo pkill -f xfce4-* 2>/dev/null
        sudo pkill -f Xorg 2>/dev/null
        ;;
    chariot)
        CLEANUP_ENABLED=1
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/chrome" || sudo mount --bind /run/chrome "$CHARD_ROOT/run/chrome" 2>/dev/null
        else
            sudo mountpoint -q "$CHARD_ROOT/run/user/1000" || sudo mount --bind /run/user/1000 "$CHARD_ROOT/run/user/1000" 2>/dev/null
        fi
        
        sudo mountpoint -q "$CHARD_ROOT/run/dbus"   || sudo mount --bind /run/dbus "$CHARD_ROOT/run/dbus" 2>/dev/null
        sudo mountpoint -q "$CHARD_ROOT/run/udev"   || sudo mount --bind /run/udev "$CHARD_ROOT/run/udev" 2>/dev/null
        sudo mountpoint -q "$CHARD_ROOT/dev/dri"    || sudo mount --bind /dev/dri "$CHARD_ROOT/dev/dri" 2>/dev/null
        sudo mountpoint -q "$CHARD_ROOT/dev/input"  || sudo mount --bind /dev/input "$CHARD_ROOT/dev/input" 2>/dev/null
        
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/cras "$CHARD_ROOT/run/cras" 2>/dev/null
        else
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/user/1000/pulse "$CHARD_ROOT/run/cras" 2>/dev/null
        fi
        
       sudo chroot "$CHARD_ROOT" /bin/bash -c "
            mountpoint -q /proc       || mount -t proc proc /proc 2>/dev/null
            mountpoint -q /sys        || mount -t sysfs sys /sys 2>/dev/null
            mountpoint -q /dev        || mount -t devtmpfs devtmpfs /dev 2>/dev/null
            mountpoint -q /dev/shm    || mount -t tmpfs tmpfs /dev/shm 2>/dev/null
            mountpoint -q /dev/pts    || mount -t devpts devpts /dev/pts 2>/dev/null
            mountpoint -q /etc/ssl    || mount --bind /etc/ssl /etc/ssl 2>/dev/null
            mountpoint -q /run/dbus   || mount --bind /run/dbus /run/dbus 2>/dev/null
            mountpoint -q /run/udev   || mount --bind /run/udev /run/udev 2>/dev/null
            mountpoint -q /run/chrome || mount --bind /run/chrome /run/chrome 2>/dev/null
        
            if [ -e /dev/zram0 ]; then
                mount --rbind /dev/zram0 /dev/zram0 2>/dev/null
                mount --make-rslave /dev/zram0 2>/dev/null
            fi
        
            chmod 1777 /tmp /var/tmp
        
            [ -e /dev/ptmx    ] || mknod -m 666 /dev/ptmx c 5 2
            [ -e /dev/null    ] || mknod -m 666 /dev/null c 1 3
            [ -e /dev/tty     ] || mknod -m 666 /dev/tty c 5 0
            [ -e /dev/random  ] || mknod -m 666 /dev/random c 1 8
            [ -e /dev/urandom ] || mknod -m 666 /dev/urandom c 1 9
        
            CHARD_HOME=\$(cat /.chard_home)
            HOME=\$CHARD_HOME
            CHARD_USER=\$(cat /.chard_user)
            USER=\$CHARD_USER
            GROUP_ID=1000
            USER_ID=1000
        
            source \$HOME/.bashrc 2>/dev/null
        
            while true; do
                read -p 'What CPU usage do you want to allocate for building chard? (0-100)? ' CPU_ALLOC
                if [[ \$CPU_ALLOC =~ ^[0-9]+$ ]] && [ \$CPU_ALLOC -ge 0 ] && [ \$CPU_ALLOC -le 100 ]; then
                    echo \"Using \$CPU_ALLOC% CPU for SMRT\"
                    break
                else
                    echo 'Invalid input, enter a number from 0 to 100.'
                fi
            done
        
            SMRT \$CPU_ALLOC
        
            source \$HOME/.smrt_env.sh
            
            env-update
        
            /bin/chariot
        
            umount -l /dev/zram0   2>/dev/null || true
            umount -l /run/chrome  2>/dev/null || true
            umount -l /run/udev    2>/dev/null || true
            umount -l /run/dbus    2>/dev/null || true
            umount -l /etc/ssl     2>/dev/null || true
            umount -l /dev/pts     2>/dev/null || true
            umount -l /dev/shm     2>/dev/null || true
            umount -l /dev         2>/dev/null || true
            umount -l /sys         2>/dev/null || true
            umount -l /proc        2>/dev/null || true
        "
        chard_unmount
        ;;
    safe)
        CLEANUP_ENABLED=1
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/chrome" || sudo mount --bind /run/chrome "$CHARD_ROOT/run/chrome" 2>/dev/null
            sudo mountpoint -q "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" || sudo mount --bind "/home/chronos/user/MyFiles/Downloads" "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null
            sudo mount -o remount,rw,bind "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads"

        else
            sudo mountpoint -q "$CHARD_ROOT/run/user/1000" || sudo mount --bind /run/user/1000 "$CHARD_ROOT/run/user/1000" 2>/dev/null
        fi
        
        sudo mountpoint -q "$CHARD_ROOT/run/dbus"   || sudo mount --bind /run/dbus "$CHARD_ROOT/run/dbus" 2>/dev/null
        sudo mountpoint -q "$CHARD_ROOT/run/udev"   || sudo mount --bind /run/udev "$CHARD_ROOT/run/udev" 2>/dev/null
        sudo mountpoint -q "$CHARD_ROOT/dev/dri"    || sudo mount --bind /dev/dri "$CHARD_ROOT/dev/dri" 2>/dev/null
        sudo mountpoint -q "$CHARD_ROOT/dev/input"  || sudo mount --bind /dev/input "$CHARD_ROOT/dev/input" 2>/dev/null
        
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/cras "$CHARD_ROOT/run/cras" 2>/dev/null
        else
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/user/1000/pulse "$CHARD_ROOT/run/cras" 2>/dev/null
        fi
        
        sudo chroot "$CHARD_ROOT" /bin/bash -c "

            mountpoint -q /proc       || mount -t proc proc /proc 2>/dev/null
            mountpoint -q /sys        || mount -t sysfs sys /sys 2>/dev/null
            mountpoint -q /dev        || mount -t devtmpfs devtmpfs /dev 2>/dev/null
            mountpoint -q /dev/shm    || mount -t tmpfs tmpfs /dev/shm 2>/dev/null
            mountpoint -q /dev/pts    || mount -t devpts devpts /dev/pts 2>/dev/null
            mountpoint -q /etc/ssl    || mount --bind /etc/ssl /etc/ssl 2>/dev/null
            mountpoint -q /run/dbus   || mount --bind /run/dbus /run/dbus 2>/dev/null
            mountpoint -q /run/udev   || mount --bind /run/udev /run/udev 2>/dev/null
            mountpoint -q /run/chrome || mount --bind /run/chrome /run/chrome 2>/dev/null
        
            if [ -e /dev/zram0 ]; then
                mount --rbind /dev/zram0 /dev/zram0 2>/dev/null
                mount --make-rslave /dev/zram0 2>/dev/null
            fi
        
            chmod 1777 /tmp /var/tmp
        
            [ -e /dev/null    ] || mknod -m 666 /dev/null c 1 3
            [ -e /dev/tty     ] || mknod -m 666 /dev/tty c 5 0
            [ -e /dev/random  ] || mknod -m 666 /dev/random c 1 8
            [ -e /dev/urandom ] || mknod -m 666 /dev/urandom c 1 9
            
            CHARD_HOME=\$(cat /.chard_home)
            HOME=\$CHARD_HOME
            CHARD_USER=\$(cat /.chard_user)
            USER=\$CHARD_USER
            GROUP_ID=1000
            USER_ID=1000
            su \$USER
            source \$HOME/.bashrc 2>/dev/null
            source \$HOME/.smrt_env.sh
        
            /bin/bash
            
            umount -l /dev/zram0   2>/dev/null || true
            umount -l /run/chrome  2>/dev/null || true
            umount -l /run/udev    2>/dev/null || true
            umount -l /run/dbus    2>/dev/null || true
            umount -l /etc/ssl     2>/dev/null || true
            umount -l /dev/pts     2>/dev/null || true
            umount -l /dev/shm     2>/dev/null || true
            umount -l /dev         2>/dev/null || true
            umount -l /sys         2>/dev/null || true
            umount -l /proc        2>/dev/null || true
        "
        
        chard_unmount
        ;;
    categories|cat)
        CLEANUP_ENABLED=0
        PORTAGE_DIR="$CHARD_ROOT/usr/portage"
        if [ ! -d "$PORTAGE_DIR" ]; then
            echo "ERROR: Portage tree not found at $PORTAGE_DIR"
            exit 1
        fi
        echo "${GREEN}[*] Available Portage categories in $CHARD_ROOT/usr/portage:${RESET}"
        for cat in "$PORTAGE_DIR"/*/; do
            [ -d "$cat" ] || continue
            basename "$cat"
        done | sort
        ;;
        # Denny's version checker
    version)
        CLEANUP_ENABLED=0
        if [[ -f "$CHARD_ROOT/bin/chard_version" ]]; then
            CURRENT_VER=$(cat "$CHARD_ROOT/bin/chard_version")
            CURRENT_CLEAN=$(echo "$CURRENT_VER" | sed -E 's/.*VERSION="?([0-9]+\.[0-9]+)"?/\1/')
            LATEST_VER=$(curl -Ls "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_version")
            LATEST_CLEAN=$(echo "$LATEST_VER" | sed -E 's/.*VERSION="?([0-9]+\.[0-9]+)"?/\1/')
            CURRENT_VER_NO=$(echo "$CURRENT_CLEAN" | awk -F. '{ printf("%d%02d\n", $1, $2) }')
            LATEST_VER_NO=$(echo "$LATEST_CLEAN" | awk -F. '{ printf("%d%02d\n", $1, $2) }')
        
            if [[ "$CURRENT_VER_NO" =~ ^[0-9]+$ && "$LATEST_VER_NO" =~ ^[0-9]+$ ]]; then
                if (( 10#$CURRENT_VER_NO < 10#$LATEST_VER_NO )); then
                    echo "${CYAN}You're using $CURRENT_VER which is NOT the latest version.${RESET}"
                    read -rp "Would you like to 'reinstall' to get $LATEST_VER ? (Y/n): " choice
                    if [[ "$choice" =~ ^[Yy]$ || -z "$choice" ]]; then
                        echo "${CYAN}Reinstalling!${RESET}"
                        bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/Reinstall_Chard.sh?$(date +%s)")
                    else
                        echo "${YELLOW}Skipping reinstall.${RESET}"
                    fi
                else
                    echo "${GREEN}You're using $CURRENT_VER which is up-to-date, so you're good.${RESET}"
                fi
            else
                echo "${RED}Version check failed. One of the version numbers is invalid.${RESET}"
            fi
        else
            echo "${RED}Version file not found.${RESET}"
            exit 1
        fi
        ;;
    unmount)
        CLEANUP_ENABLED=1
        chard_unmount
        ;;
    *)
        chard_run "$cmd" "$@"
        ;;
esac
