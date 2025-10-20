# CHARD .BASHRC

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

DEFAULT_FEATURES="assume-digests binpkg-docompress binpkg-dostrip binpkg-logs config-protect-if-modified distlocks ebuild-locks fixlafiles merge-sync multilib-strict news parallel-fetch parallel-install pid-sandbox preserve-libs protect-owned strict unknown-features-warn unmerge-logs unmerge-orphans userfetch usersync xattr -sandbox -usersandbox"
DEFAULT_USE="X a52 aac acl acpi alsa bindist -bluetooth branding bzip2 cairo cdda cdr cet crypt dbus dri dts dvd dvdr encode exif flac gdbm gif gpm gtk gtk3 gui iconv icu introspection ipv6 jpeg lcms libnotify libtirpc mad mng mp3 mp4 mpeg multilib ncurses nls ogg opengl openmp pam pango pcre pdf png ppds qml qt5 qt6 readline sdl seccomp sound spell ssl startup-notification svg tiff truetype udev udisks unicode upower usb vorbis vulkan wayland wxwidgets x264 xattr xcb xft xml xv xvid zlib python_targets_python3_13 -systemd -elogind"
export FEATURES="${FEATURES:-$DEFAULT_FEATURES}"
export USE="${USE:-$DEFAULT_USE}"
export HOME=/home/chronos/user

if [[ "$ROOT" != "/" ]]; then
    ROOT="${ROOT%/}"
fi

export CHARD_RC="$ROOT/.chardrc"
export PORTDIR="$ROOT/usr/portage"
export DISTDIR="$ROOT/var/cache/distfiles"
export PKGDIR="$ROOT/var/cache/packages"
export PORTAGE_TMPDIR="$ROOT/var/tmp"
export SANDBOX="$ROOT/usr/bin/sandbox"
export GIT_EXEC_PATH="$ROOT/usr/libexec/git-core"
export PYTHONMULTIPROCESSING_START_METHOD=fork

PERL_BASE="$ROOT/usr/lib/perl5"
PERL_LIB_DIRS=()
PERL_BIN_DIRS=()
PERL_LIBS=()

if [[ -d "$PERL_BASE" ]]; then
    mapfile -t all_perl_versions < <(ls -1 "$PERL_BASE" 2>/dev/null | grep -E '^[0-9]+\.[0-9]+$' | sort -V)
else
    all_perl_versions=()
fi

for ver in "${all_perl_versions[@]}"; do
    archlib="$PERL_BASE/$ver/$CHOST"
    sitelib="$PERL_BASE/$ver/site_perl"
    vendorlib="$PERL_BASE/$ver/vendor_perl"

    PERL5LIB_PARTS=()
    [[ -d "$archlib" ]] && PERL5LIB_PARTS+=("$archlib")
    [[ -d "$sitelib" ]] && PERL5LIB_PARTS+=("$sitelib")
    [[ -d "$vendorlib" ]] && PERL5LIB_PARTS+=("$vendorlib")
    if [[ ${#PERL5LIB_PARTS[@]} -gt 0 ]]; then
        PERL5LIB="$(IFS=:; echo "${PERL5LIB_PARTS[*]}")${PERL5LIB:+:$PERL5LIB}"
    fi

    CORE_LIB="$PERL_BASE/$ver/$CHOST/CORE"
    [[ -d "$CORE_LIB" ]] && PERL_LIBS+=("$CORE_LIB")

    BIN_DIR="$ROOT/usr/bin"
    [[ -d "$BIN_DIR" ]] && PERL_BIN_DIRS+=("$BIN_DIR")
done

export PERL5LIB="$PERL5LIB"
export PERL6LIB="$PERL6LIB"

if [[ ${#PERL_LIBS[@]} -gt 0 ]]; then
    LD_LIBRARY_PATH="$(IFS=:; echo "${PERL_LIBS[*]}")${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi

if [[ ${#PERL_BIN_DIRS[@]} -gt 0 ]]; then
    PATH="$(IFS=:; echo "${PERL_BIN_DIRS[*]}"):$PATH"
fi

gcc_version=$(gcc -dumpversion 2>/dev/null | cut -d. -f1)
if [[ -n "$gcc_version" && -n "$CHOST" ]]; then
    gcc_bin_path="$ROOT/usr/$CHOST/gcc-bin/${gcc_version}"
    gcc_lib_path="$ROOT/usr/lib/gcc/$CHOST/$gcc_version"

    if [[ -d "$gcc_bin_path" ]]; then
        export PATH="$PYEXEC_DIR:$PATH:$ROOT/usr/bin:$ROOT/bin:$gcc_bin_path"
    else
        export PATH="$PYEXEC_DIR:$PATH:$ROOT/usr/bin:$ROOT/bin:$ROOT/usr/$CHOST/gcc-bin/14"
    fi

    if [[ -d "$gcc_lib_path" ]]; then
        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:$ROOT/usr/lib:$ROOT/lib:$gcc_lib_path:$gcc_bin_path"
    else
        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:$ROOT/usr/lib:$ROOT/lib:$ROOT/usr/lib/gcc/$CHOST/14:$ROOT/usr/$CHOST/gcc-bin/14"
    fi
else
    export PATH="$PYEXEC_DIR:$PATH:$ROOT/usr/bin:$ROOT/bin:$ROOT/usr/$CHOST/gcc-bin/14"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:$ROOT/usr/lib:$ROOT/lib:$ROOT/usr/lib/gcc/$CHOST/14:$ROOT/usr/$CHOST/gcc-bin/14"
fi

export PKG_CONFIG_PATH="$ROOT/usr/lib/pkgconfig:$ROOT/usr/lib64/pkgconfig:$ROOT/usr/lib/pkgconfig:$ROOT/usr/local/lib/pkgconfig:$ROOT/usr/local/share/pkgconfig"
export MAGIC="$ROOT/usr/share/misc/magic.mgc"
export PKG_CONFIG="$ROOT/usr/bin/pkg-config"
export GIT_TEMPLATE_DIR="$ROOT/usr/share/git-core/templates"
export CPPFLAGS="-I/usr/include"
PYEXEC_BASE="$ROOT/usr/lib/python-exec"
PYTHON_EXEC_PREFIX="$ROOT/usr"
PYTHON_EXECUTABLES="$PYEXEC_BASE"

all_python_dirs=($(ls -1 "$PYEXEC_BASE" 2>/dev/null | grep -E '^python[0-9]+\.[0-9]+$' | sort -V))

latest_python="${all_python_dirs[-1]}"

if [[ ${#all_python_dirs[@]} -lt 2 ]]; then
    second_latest_python="${all_python_dirs[-1]}"
else
    second_latest_python="${all_python_dirs[-2]}"
fi

if [[ -z "$second_latest_python" ]]; then
    second_latest_python="$latest_python"
fi

latest_underscore="${latest_python#python}"
latest_underscore="${latest_underscore//./_}"
latest_dot="${latest_python#python}"

second_underscore="${second_latest_python#python}"
second_underscore="${second_underscore//./_}"
second_dot="${second_latest_python#python}"

export PYTHON_TARGETS="python${second_underscore}"
export PYTHON_SINGLE_TARGET="python${second_underscore}"

python_site_second="$ROOT/usr/lib/python${second_dot}/site-packages"
python_site_latest="$ROOT/usr/lib/python${latest_dot}/site-packages"

if [[ -n "$PYTHONPATH" ]]; then
    export PYTHONPATH="${python_site_second}:${python_site_latest}:$(realpath -m $PYTHONPATH)"
else
    export PYTHONPATH="${python_site_second}:${python_site_latest}"
fi

export PYEXEC_DIR="${PYEXEC_BASE}/${latest_python}"
export CC="$ROOT/usr/bin/gcc"
export CXX="$ROOT/usr/bin/g++"
export AR="$ROOT/usr/bin/ar"
export NM="$ROOT/usr/bin/gcc-nm"
export RANLIB="$ROOT/usr/bin/gcc-ranlib"
export STRIP="$ROOT/usr/bin/strip"
export XDG_DATA_DIRS="$ROOT/usr/share:$ROOT/usr/share"
export EMERGE_DEFAULT_OPTS="--quiet-build=y --jobs=$(nproc)"

CFLAGS="-O2 -pipe "
[[ -d /usr/include ]] && CFLAGS+="-I/usr/include "
[[ -d /include ]] && CFLAGS+="-I/include "
export CFLAGS

CXXFLAGS="-O2 -pipe "
[[ -d /usr/include ]] && CXXFLAGS+="-I/usr/include "
[[ -d /include ]] && CXXFLAGS+="-I/include "
export CXXFLAGS

LDFLAGS=""
[[ -d /usr/lib ]] && LDFLAGS+="-L/usr/lib "
[[ -d /lib ]] && LDFLAGS+="-L/lib "
[[ -d /usr/local/lib ]] && LDFLAGS+="-L/usr/local/lib "
export LDFLAGS

export LD="$ROOT/usr/bin/ld"
export ACLOCAL_PATH="$ROOT/usr/share/aclocal:$ACLOCAL_PATH"
export M4PATH="$ROOT/usr/share/m4:$M4PATH"
export MANPATH="$ROOT/usr/share/man:$ROOT/usr/local/share/man:$MANPATH"
export DISPLAY=":0"
export GDK_BACKEND="x11"
export CLUTTER_BACKEND="x11"
export PYTHONMULTIPROCESSING_START_METHOD=fork
export EPYTHON="python${second_dot}"
export PYTHON="python${second_dot}"
export PORTAGE_PYTHON="python${second_dot}"

MAKECONF="$ROOT/etc/portage/make.conf"
if [[ -w "$MAKECONF" ]]; then
    sed -i "/^PYTHON_TARGETS=/d" "$MAKECONF"
    sed -i "/^PYTHON_SINGLE_TARGET=/d" "$MAKECONF"
    echo "PYTHON_TARGETS=\"python${second_underscore}\"" >> "$MAKECONF"
    echo "PYTHON_SINGLE_TARGET=\"python${second_underscore}\"" >> "$MAKECONF"
fi

alias smrt='SMRT'

if [[ -f /bin/.smrt_env.sh ]]; then
    source /bin/.smrt_env.sh
fi

dbus-daemon --system --fork 2>/dev/null

# <<< END CHARD .BASHRC >>>
