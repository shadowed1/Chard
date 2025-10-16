
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
DEFAULT_USE="X a52 aac acl acpi alsa bindist branding bzip2 cairo cdda cdr cet crypt cups dbus dri dts dvd dvdr -elogind encode exif flac gdbm gif gpm gtk gui iconv icu ipv6 jpeg lcms libnotify libtirpc mad mng mp3 mp4 mpeg multilib ncurses nls ogg opengl openmp pam pango pcre pdf png policykit ppds qml qt5 qt6 readline sdl seccomp sound spell ssl startup-notification svg test-rust truetype udev udisks unicode upower usb vorbis vulkan wayland wxwidgets x264 xattr xcb xft xml xv xvid zlib x11"
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
PYEXEC_BASE="/usr/lib/python-exec"

all_python_dirs=($(ls -1 "$PYEXEC_BASE" 2>/dev/null | grep -E '^python[0-9]+\.[0-9]+$' | sort -V))

if [[ ${#all_python_dirs[@]} -gt 1 ]]; then
    python_dir="${all_python_dirs[-2]}"
else
    python_dir="${all_python_dirs[-1]}"
fi

python_ver="${python_dir#python}"
python_underscore="${python_ver//./_}"

export PYEXEC_DIR="${PYEXEC_BASE}/${python_dir}"
export PYTHON_SINGLE_TARGET="python${python_underscore}"
export PYTHON_TARGETS="python${python_underscore}"

python_site="/usr/lib/python${python_ver}/site-packages"
if [[ -n "$PYTHONPATH" ]]; then
    export PYTHONPATH="${python_site}:$PYTHONPATH"
else
    export PYTHONPATH="${python_site}"
fi

export PYEXEC_DIR="${PYEXEC_BASE}/${latest_python}"


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
export LD="/usr/bin/ld"
export ACLOCAL_PATH="/usr/share/aclocal:$ACLOCAL_PATH"
export M4PATH="/usr/share/m4:$M4PATH"
export MANPATH="/usr/share/man:$MANPATH"
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
