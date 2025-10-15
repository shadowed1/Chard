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

perl_version=$(perl -V:version | cut -d"'" -f2)
perl_archlib=$(perl -V:archlib | cut -d"'" -f2)
perl_sitelib=$(perl -V:sitelib | cut -d"'" -f2)
perl_vendorlib=$(perl -V:vendorlib | cut -d"'" -f2)

export PERL5LIB="${perl_archlib}:${perl_sitelib}:${perl_vendorlib}:${PERL5LIB}"

gcc_version=$(gcc -dumpversion 2>/dev/null | cut -d. -f1)
if [[ -n "$gcc_version" && -n "$CHOST" ]]; then
    gcc_bin_path="/usr/$CHOST/gcc-bin/${gcc_version}"
    gcc_lib_path="/usr/lib/gcc/$CHOST/$gcc_version"

    if [[ -d "$gcc_bin_path" ]]; then
        export PATH="$PATH:/usr/bin:/bin:$gcc_bin_path"
    else
        export PATH="$PATH:/usr/bin:/bin"
    fi

    if [[ -d "$gcc_lib_path" ]]; then
        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:/usr/lib:/lib:$gcc_lib_path:$gcc_bin_path"
    else
        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:/usr/lib:/lib"
    fi
else
    export PATH="$PATH:/usr/bin:/bin"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:/usr/lib:/lib"
fi


export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig
export MAGIC="/usr/share/misc/magic.mgc"
export PKG_CONFIG=/usr/bin/pkg-config
export GIT_TEMPLATE_DIR=/usr/share/git-core/templates
export CPPFLAGS="-I/usr/include"
python_ver=$(python3 -c "import sys; print(f'{sys.version_info.major}_{sys.version_info.minor}')")
python_dot=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
export PYTHON_TARGETS="python${python_ver}"
export PYTHON_SINGLE_TARGET="python${python_ver}"
export PYTHONPATH="/usr/lib/python${python_dot}/site-packages:$PYTHONPATH"


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
export ACCEPT_KEYWORDS="~amd64 ~x86 ~arm ~arm64"

if ! lscpu -e=CPU,MAXMHZ >/dev/null 2>&1; then
    echo "Error: lscpu -e=CPU,MAXMHZ not supported on this system."
    return 0
fi

mapfile -t CORES < <(lscpu -e=CPU,MAXMHZ 2>/dev/null | \
    awk 'NR>1 && $2 ~ /^[0-9.]+$/ {print $1 ":" $2}' | sort -t: -k2,2n)

if (( ${#CORES[@]} == 0 )); then
    echo "No CPU frequency data found."
    return 0
fi

mhz_values=($(printf '%s\n' "${CORES[@]}" | cut -d: -f2 | sort -n))
count=${#mhz_values[@]}
mid=$((count / 2))
if (( count % 2 == 0 )); then
    threshold=$(awk "BEGIN {print (${mhz_values[mid-1]} + ${mhz_values[mid]}) / 2}")
else
    threshold="${mhz_values[mid]}"
fi

WEAK_CORES=$(printf '%s\n' "${CORES[@]}" | \
    awk -v t="$threshold" -F: '{if ($2 <= t) print $1}' | paste -sd, -)

if [[ -z "$WEAK_CORES" ]]; then
    echo "Warning: Could not determine weak cores, defaulting to all cores."
    WEAK_CORES=$(seq 0 $(( $(nproc) - 1 )) | paste -sd, -)
fi

export TASKSET="taskset -c $WEAK_CORES"

MEM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
MEM_GB=$(( (MEM_KB + 1024*1024 - 1) / 1024 / 1024 ))
THREADS=$((MEM_GB / 2))
((THREADS < 1)) && THREADS=1

TOTAL_CORES=$(nproc)
ECORE_COUNT=$(echo "$WEAK_CORES" | tr ',' '\n' | wc -l)
ECORE_RATIO=$(awk "BEGIN {print $ECORE_COUNT / $TOTAL_CORES}")

if (( $(awk "BEGIN {print ($ECORE_RATIO >= 0.65)}") )); then
    THREADS=$(awk -v t="$THREADS" 'BEGIN {printf("%d", t * 3.0)}')
fi

export MAKEOPTS="-j$THREADS"

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

if [[ -t 1 ]]; then
    echo "${BLUE}────────────────────────────────────────────────────────${RESET}"
    echo "${CYAN}Chard Root CPU Profile:${RESET}"
    echo "${GREEN}Cores assigned:               ${BOLD}$WEAK_CORES ${RESET}"
    echo "${CYAN}E-core ratio:                 ${BOLD}$(awk "BEGIN {print $ECORE_RATIO*100}")% ${RESET}"
    echo "${GREEN}Parallelized threads:         ${BOLD}$MAKEOPTS ${RESET}"
    echo "${CYAN}Taskset:                      ${BOLD}$TASKSET ${RESET}"
    echo "${BLUE}────────────────────────────────────────────────────────${RESET}"
fi

FIRST_TIME_SETUP() {
    local MARKER_FILE="/.chard_setup_done"
    if [[ ! -f "$MARKER_FILE" ]]; then
        echo ""
        echo "${BOLD}${MAGENTA}──────────────────────────────────────────────────────────────────────────${RESET}"
        echo "${BOLD}${GREEN}Chard: Performing first-time setup. Be patient and keep this shell open.${RESET}"
        echo "${BOLD}${MAGENTA}──────────────────────────────────────────────────────────────────────────${RESET}"
        echo ""

        local LOGFILE="/var/log/chard-setup.log"
        mkdir -p /var/log
        echo "$(date) - Starting Chard first-time setup" > "$LOGFILE"

        COMMANDS=(
            emerge dev-build/make
            emerge dev-build/cmake
            emerge sys-devel/gcc
            emerge dev-libs/gmp
            emerge dev-libs/mpfr
            emerge sys-devel/binutils
            emerge sys-apps/diffutils
            emerge dev-libs/openssl
            emerge net-misc/curl
            emerge dev-vcs/git
            emerge sys-apps/coreutils
            emerge app-misc/fastfetch
            emerge -1 dev-lang/perl
            emerge virtual/perl-Digest
            emerge virtual/perl-CPAN
            emerge virtual/perl-CPAN-Meta
            emerge virtual/perl-Data-Dumper
            emerge virtual/perl-Math-BigInt
            emerge virtual/perl-Scalar-List-Utils
            emerge -1av $(perl-cleaner --reallyall)
            emerge dev-perl/Capture-Tiny
            emerge dev-perl/Try-Tiny
            emerge dev-perl/Config-AutoConf
            emerge dev-perl/Test-Fatal
            emerge sys-apps/findutils
            emerge dev-lang/python
            emerge dev-build/meson
            emerge dev-libs/glib
            emerge dev-lang/ruby
            emerge dev-ruby/pkg-config
            emerge dev-cpp/gtest
            emerge dev-util/gtest-parallel
            emerge dev-util/re2c
            emerge dev-build/ninja
            emerge licenses/docbook
            emerge app-text/docbook2X
            emerge docbook
            emerge app-text/build-docbook-catalog
            emerge dev-util/gtk-doc
            emerge sys-libs/zlib
            emerge dev-libs/libunistring
            emerge sys-apps/file
            emerge kde-frameworks/extra-cmake-modules
            emerge dev-perl/File-LibMagic
            emerge net-libs/libpsl
            emerge dev-libs/expat
            emerge dev-lang/duktape
            emerge app-arch/brotli
            mv /usr/lib/libcrypt.so /usr/lib/libcrypt.so.bak
            emerge dev-lang/rust
            emerge sys-auth/polkit
            emerge sys-apps/bubblewrap
            emerge app-portage/gentoolkit
            emerge x11-base/xorg-drivers
            emerge x11-base/xorg-server
            emerge x11-base/xorg-apps
            emerge x11-libs/libX11
            emerge x11-libs/libXft
            emerge x11-libs/libXrender
            emerge x11-libs/libXrandr
            emerge x11-libs/libXcursor
            emerge x11-libs/libXi
            emerge x11-libs/libXinerama
            emerge dev-libs/wayland
            emerge dev-libs/wayland-protocols
            emerge x11-base/xwayland
            emerge x11-libs/libxkbcommon
            emerge gui-libs/gtk
            emerge xfce-base/libxfce4util
            emerge xfce-base/xfconf
            emerge sys-apps/xdg-desktop-portal
            emerge gui-libs/xdg-desktop-portal-wlr
            emerge media-libs/mesa
            emerge x11-apps/mesa-progs
            emerge media-sound/pulseaudio-daemon
            emerge media-sound/pulseaudio-ctl
            emerge dev-qt/qtbase
            emerge dev-qt/qttools
            emerge media-libs/pulseaudio-qt
            emerge media-sound/alsa-utils
            emerge sys-apps/dbus
            emerge app-accessibility/at-spi2-core
            emerge app-accessibility/at-spi2-atk
            emerge media-libs/fontconfig
            emerge media-fonts/dejavu
            emerge media-libs/freetype
            emerge x11-themes/gtk-engines
            emerge x11-themes/gtk-engines-murrine
            emerge sys-fs/udisks
            emerge sys-power/upower
            emerge x11-libs/libnotify
            emerge dev-libs/libdbusmenu
            emerge x11-libs/libSM
            emerge x11-libs/libICE
            emerge x11-libs/libwnck
            emerge app-admin/exo
            emerge app-arch/tar
            emerge app-arch/xz-utils
            emerge net-libs/gnutls
            emerge net-libs/glib-networking
            emerge sys-libs/libseccomp
            emerge app-eselect/eselect-repository
            emerge dev-libs/appstream-glib
            emerge app-crypt/gpgme
            emerge dev-libs/json-glib
            emerge dev-util/ostree
            emerge sys-apps/xdg-dbus-proxy
            emerge x11-libs/gdk-pixbuf
            emerge sys-fs/fuse
            emerge dev-python/pygobject
            emerge gnome-base/dconf
            emerge x11-misc/xdg-utils
            emerge x11-apps/xinit
            emerge x11-terms/xterm
            emerge x11-wm/twm
            emerge xfce-extra/xfce4-screensaver
            emerge xfce-base/xfce4-meta
            emerge www-client/firefox
            emerge sys-apps/flatpak
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        )

        for cmd in "${COMMANDS[@]}"; do
            echo "${YELLOW}>>> Running: ${RESET}$cmd"
            $cmd
            if [[ $? -ne 0 ]]; then
                echo "${RED}!!! Command failed: ${cmd}${RESET}"
                echo "Check log at $LOGFILE"
            fi
        done

        touch "$MARKER_FILE"

        echo ""
        echo "${BOLD}${GREEN}──────────────────────────────────────────────────────${RESET}"
        echo "${BOLD}${YELLOW}Chard setup completed (check log for any failed commands)${RESET}"
        echo "${BOLD}${GREEN}──────────────────────────────────────────────────────${RESET}"
        echo "Log saved to ${YELLOW}$LOGFILE${RESET}"
        echo ""
    fi
}

FIRST_TIME_SETUP


# <<< END CHARD .BASHRC >>>
