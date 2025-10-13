# CHARD .BASHRC

ARCH=$(uname -m)
case "$ARCH" in
    x86_64) CHOST=x86_64-pc-linux-gnu ;;
    aarch64) CHOST=aarch64-unknown-linux-gnu ;;
    *) echo "Unknown architecture: $ARCH"; exit 1 ;;
esac

DEFAULT_FEATURES="assume-digests binpkg-docompress binpkg-dostrip binpkg-logs config-protect-if-modified distlocks ebuild-locks fixlafiles ipc-sandbox merge-sync multilib-strict network-sandbox news parallel-fetch pid-sandbox preserve-libs protect-owned strict unknown-features-warn unmerge-logs unmerge-orphans userfetch userpriv usersync xattr"
export FEATURES="${FEATURES:-$DEFAULT_FEATURES}"
DEFAULT_USE="X a52 aac acl acpi alsa bindist branding bzip2 cairo cdda cdr cet crypt cups dbus dri dts dvd dvdr elogind encode exif flac gdbm gif gpm gtk iconv icu ipv6 jpeg lcms libnotify libtirpc mad mng mp3 mp4 mpeg multilib ncurses nls ogg opengl openmp pam pango pcre pdf png policykit ppds qml qt5 qt6 readline sdl seccomp sound spell ssl startup-notification svg test-rust truetype udev udisks unicode upower usb vorbis vulkan wayland wxwidgets x264 xattr xcb xft xml xv xvid zlib x11"
export USE="${USE:-$DEFAULT_USE}"

export ROOT="/"
export CHARD_RC="/.chardrc"
export PORTDIR="/usr/portage"
export DISTDIR="/var/cache/distfiles"
export PKGDIR="/var/cache/packages"
export PORTAGE_TMPDIR="/var/tmp"
export SANDBOX="/usr/bin/sandbox"
export GIT_EXEC_PATH="/usr/libexec/git-core"
export PERL5LIB="/lib/perl5/5.40.0:$PERL5LIB"
export PATH="$PATH:/usr/bin:/bin:/usr/$CHOST/gcc-bin/14"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:/usr/lib:/lib:/usr/lib/gcc/$CHOST/14:/usr/$CHOST/gcc-bin/14"
export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig
export MAGIC="/usr/share/misc/magic.mgc"
export PKG_CONFIG=/usr/bin/pkg-config
export GIT_TEMPLATE_DIR=/usr/share/git-core/templates
export CPPFLAGS="-I/usr/include"
export PYTHON_TARGETS="python3_13"
export PYTHON_SINGLE_TARGET="python3_13"
export PYTHONPATH="/usr/lib/python3.13/site-packages"

export CC="/usr/bin/gcc"
export CXX="/usr/bin/g++"
export AR="/usr/bin/ar"
export NM="/usr/bin/gcc-nm"
export RANLIB="/usr/bin/gcc-ranlib"
export STRIP="/usr/bin/strip"
export XDG_DATA_DIRS="/usr/share:/usr/share"

export EMERGE_DEFAULT_OPTS="--quiet-build=y --jobs=$(nproc)"

export CFLAGS="-O2 -pipe -I/usr/include -I/include $CFLAGS"
export CXXFLAGS="-O2 -pipe -I/usr/include -I/include $CXXFLAGS"
export LDFLAGS="-L/usr/lib -L/lib $LDFLAGS"
export ACLOCAL_PATH="/usr/share/aclocal:$ACLOCAL_PATH"
export M4PATH="/usr/share/m4:$M4PATH"
export MANPATH="/usr/share/man:$MANPATH"
export DISPLAY=":0"
export GDK_BACKEND="x11"
export CLUTTER_BACKEND="x11"
export ACCEPT_KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~aarch64"

MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_GB=$(( (MEM_KB + 1024*1024 - 1) / 1024 / 1024 ))
THREADS=$((MEM_GB / 2))
((THREADS < 1)) && THREADS=1

mapfile -t CORES < <(lscpu -e=CPU,MAXMHZ 2>/dev/null | awk 'NR>1 && $2 ~ /^[0-9.]+$/ {print $1 ":" $2}' | sort -t: -k2,2n)

if (( ${#CORES[@]} )); then
    CORE_LIST=$(printf '%s\n' "${CORES[@]}" | head -n "$THREADS" | cut -d: -f1 | paste -sd, -)
else
    CORE_LIST=$(seq 0 $((THREADS-1)) | paste -sd, -)
fi

export MAKEOPTS="-j$THREADS"
export TASKSET="taskset -c $CORE_LIST"

parallel_tools=(make emerge ninja scons meson cmake)
for tool in "${parallel_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        alias "$tool"="$TASKSET $tool $MAKEOPTS"
    fi
done

serial_tools=(cargo go rustc gcc g++ clang clang++ ccache waf python pip install npm yarn node gyp bazel b2 bjam dune dune-build)
for tool in "${serial_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        alias "$tool"="$TASKSET $tool"
    fi
done


# <<< END CHARD .BASHRC >>>
