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

DEFAULT_USE="X a52 aac acl acpi alsa bluetooth bindist branding bzip2 cairo cdda cdr cet crypt cups dbus dri dts dvd dvdr -elogind encode exif flac gdbm gif gpm gtk gui iconv icu ipv6 jpeg lcms libnotify libtirpc mad mng mp3 mp4 mpeg multilib ncurses nls ogg opengl openmp pam pango pcre pdf png policykit ppds qml qt5 qt6 readline sdl seccomp sound spell ssl startup-notification svg test-rust truetype udev udisks unicode upower usb vorbis vulkan wayland wxwidgets x264 xattr xcb xft xml xv xvid zlib x11"
export USE="${USE:-$DEFAULT_USE}"

ROOT="${ROOT%/}"
export CHARD_RC="$ROOT/.chardrc"
export PORTDIR="$ROOT/usr/portage"
export DISTDIR="$ROOT/var/cache/distfiles"
export PKGDIR="$ROOT/var/cache/packages"
export PORTAGE_TMPDIR="$ROOT/var/tmp"
export SANDBOX="$ROOT/usr/bin/sandbox"
export GIT_EXEC_PATH="$ROOT/usr/libexec/git-core"

# Determine architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) CHOST=x86_64-pc-linux-gnu ;;
    aarch64) CHOST=aarch64-unknown-linux-gnu ;;
    *) echo "Unknown architecture: $ARCH"; exit 1 ;;
esac

ROOT="${ROOT%/}"
export CHARD_RC="$ROOT/.chardrc"

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

    # Optional: track perl binary dirs
    BIN_DIR="$ROOT/usr/bin"
    [[ -d "$BIN_DIR" ]] && PERL_BIN_DIRS+=("$BIN_DIR")
done

export PERL5LIB="$PERL5LIB"
export PERL6LIB="$PERL6LIB"

if [[ ${#PERL_LIBS[@]} -gt 0 ]]; then
    LD_LIBRARY_PATH="$(IFS=:; echo "${PERL_LIBS[*]}")${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi
export LD_LIBRARY_PATH

if [[ ${#PERL_BIN_DIRS[@]} -gt 0 ]]; then
    PATH="$(IFS=:; echo "${PERL_BIN_DIRS[*]}"):$PATH"
fi
export PATH


gcc_version=$(gcc -dumpversion 2>/dev/null | cut -d. -f1)
if [[ -n "$gcc_version" && -n "$CHOST" ]]; then
    gcc_bin_path="$ROOT/usr/$CHOST/gcc-bin/${gcc_version}"
    gcc_lib_path="$ROOT/usr/lib/gcc/$CHOST/$gcc_version"

    if [[ -d "$gcc_bin_path" ]]; then
        export PATH="$PATH:$ROOT/usr/bin:$ROOT/bin:$gcc_bin_path"
    else
        export PATH="$PATH:$ROOT/usr/bin:$ROOT/bin:$ROOT/usr/$CHOST/gcc-bin/14"
    fi

    if [[ -d "$gcc_lib_path" ]]; then
        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:$ROOT/usr/lib:$ROOT/lib:$gcc_lib_path:$gcc_bin_path"
    else
        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:$ROOT/usr/lib:$ROOT/lib:$ROOT/usr/lib/gcc/$CHOST/14:$ROOT/usr/$CHOST/gcc-bin/14"
    fi
else
    export PATH="$PATH:$ROOT/usr/bin:$ROOT/bin:$ROOT/usr/$CHOST/gcc-bin/14"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:$ROOT/usr/lib:$ROOT/lib:$ROOT/usr/lib/gcc/$CHOST/14:$ROOT/usr/$CHOST/gcc-bin/14"
fi

export PKG_CONFIG_PATH="$ROOT/usr/lib/pkgconfig:$ROOT/usr/lib64/pkgconfig:$ROOT/usr/lib/pkgconfig:$ROOT/usr/local/lib/pkgconfig:$ROOT/usr/local/share/pkgconfig"
export MAGIC="$ROOT/usr/share/misc/magic.mgc"
export PKG_CONFIG="$ROOT/usr/bin/pkg-config"
export GIT_TEMPLATE_DIR="$ROOT/usr/share/git-core/templates"
export CPPFLAGS="-I${ROOT}usr/include"
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

latest_underscore="${latest_python#python}"
latest_underscore="${latest_underscore//./_}"
latest_dot="${latest_python#python}"

second_underscore="${second_latest_python#python}"
second_underscore="${second_underscore//./_}"
second_dot="${second_latest_python#python}"

export PYTHON_TARGETS="python${second_underscore} python${latest_underscore}"
export PYTHON_SINGLE_TARGET="python${latest_underscore}"

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
export CFLAGS="-O2 -pipe -I${ROOT}usr/include -I${ROOT}include $CFLAGS"
export CXXFLAGS="-O2 -pipe -I${ROOT}usr/include -I${ROOT}include $CXXFLAGS"
export LDFLAGS="-L${ROOT}usr/lib -L${ROOT}lib -L${ROOT}usr/local/lib $LDFLAGS"
export LD="$ROOT/usr/bin/ld"
export ACLOCAL_PATH="$ROOT/usr/share/aclocal:$ACLOCAL_PATH"
export M4PATH="$ROOT/usr/share/m4:$M4PATH"
export MANPATH="$ROOT/usr/share/man:$ROOT/usr/local/share/man:$MANPATH"
export DISPLAY=":0"
export GDK_BACKEND="x11"
export CLUTTER_BACKEND="x11"
export ACCEPT_KEYWORDS="~amd64 ~x86 ~arm ~arm64"

if command -v lscpu >/dev/null 2>&1 && lscpu -e=CPU,MAXMHZ >/dev/null 2>&1; then
    mapfile -t CORES < <(lscpu -e=CPU,MAXMHZ 2>/dev/null | \
        awk 'NR>1 && $2 ~ /^[0-9.]+$/ {print $1 ":" $2}' | sort -t: -k2,2n)
else
    mapfile -t CORES < <(awk -v c=-1 '
        /^processor/ {c=$3}
        /cpu MHz/ && c>=0 {print c ":" $4; c=-1}
    ' /proc/cpuinfo | sort -t: -k2,2n)
fi

if (( ${#CORES[@]} == 0 )); then
    total=$(nproc)
    half=$(( total / 1 ))
    WEAK_CORES=$half
else
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

    if [[ -z "$WEAK_CORES" || "$WEAK_CORES" == "$(seq -s, 0 $(( $(nproc)-1 )))" ]]; then
        total=$(nproc)
        half=$(( total / 1 ))
        WEAK_CORES=$half
    fi
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
    echo "${GREEN}Parallelized threads:         ${BOLD}$MAKEOPTS ${RESET}"
    echo "${CYAN}Taskset:                      ${BOLD}$TASKSET ${RESET}"
    echo "${BLUE}────────────────────────────────────────────────────────${RESET}"
fi

# <<< END CHARD .BASHRC >>>
