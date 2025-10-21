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

export HOME=/home/chronos/user
export CHARD_RC="/.chardrc"
export PORTDIR="/usr/portage"
export DISTDIR="/var/cache/distfiles"
export PKGDIR="/var/cache/packages"
export PORTAGE_TMPDIR="/var/tmp"
export SANDBOX="/usr/bin/sandbox"
export GIT_EXEC_PATH="/usr/libexec/git-core"
export XDG_RUNTIME_DIR="/run/user/0"
export PYTHONMULTIPROCESS_START_METHOD=fork

PERL_BASES=("/usr/lib64/perl5" "/usr/local/lib64/perl5" "/usr/lib/perl5" "/usr/lib64/perl5")
all_perl_versions=()

for base in "${PERL_BASES[@]}"; do
    [[ -d "$base" ]] || continue
    for dir in "$base"/*; do
        [[ -d "$dir" ]] || continue
        ver=$(basename "$dir")
        [[ $ver =~ ^[0-9]+\.[0-9]+$ ]] && all_perl_versions+=("$ver")
    done
done

mapfile -t all_perl_versions < <(printf '%s\n' "${all_perl_versions[@]}" | sort -V | uniq)

if (( ${#all_perl_versions[@]} >= 2 )); then
    second_latest_perl="${all_perl_versions[-2]}"
elif (( ${#all_perl_versions[@]} == 1 )); then
    second_latest_perl="${all_perl_versions[0]}"
else
    echo "No Perl versions found"
    second_latest_perl=""
fi

PERL5LIB=""
if [[ -n "$second_latest_perl" ]]; then
    for base in "${PERL_BASES[@]}"; do
        for lib_sub in "" "vendor_perl" "$CHOST" "vendor_perl/$CHOST"; do
            dir="$base/$second_latest_perl/$lib_sub"
            [[ -d "$dir" ]] && PERL5LIB="$dir${PERL5LIB:+:$PERL5LIB}"
        done
    done
fi

PERL_BIN_DIRS=()
[[ -d "/usr/bin" ]] && PERL_BIN_DIRS+=("/usr/bin")
[[ -d "/usr/bin" ]] && PERL_BIN_DIRS+=("/usr/bin")

export PERL5LIB="$PERL5LIB"
export PATH="$(IFS=:; echo "${PERL_BIN_DIRS[*]}"):$PATH"

perl_versions=($(eselect perl list | awk '/\*/{next} {print $2}' | sort -V))
if (( ${#perl_versions[@]} >= 2 )); then
    second_latest_perl="${perl_versions[-2]}"
elif (( ${#perl_versions[@]} == 1 )); then
    second_latest_perl="${perl_versions[-1]}"
else
    second_latest_perl=""
fi
[[ -n "$second_latest_perl" ]] && eselect perl set "$second_latest_perl" 2>/dev/null


gcc_version=$(gcc -dumpversion 2>/dev/null | cut -d. -f1)
if [[ -n "$gcc_version" && -n "$CHOST" ]]; then
    gcc_bin_path="/usr/$CHOST/gcc-bin/${gcc_version}"
    gcc_lib_path="/usr/lib/gcc/$CHOST/$gcc_version"

    if [[ -d "$gcc_bin_path" ]]; then
        export PATH="$PYEXEC_DIR:$PATH:/usr/bin:/bin:$gcc_bin_path"
    else
        export PATH="$PYEXEC_DIR:$PATH:/usr/bin:/bin:/usr/$CHOST/gcc-bin/14"
    fi

    if [[ -d "$gcc_lib_path" ]]; then
        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:/usr/lib:/lib:$gcc_lib_path:$gcc_bin_path"
    else
        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:/usr/lib:/lib:/usr/lib/gcc/$CHOST/14:/usr/$CHOST/gcc-bin/14"
    fi
else
    export PATH="$PYEXEC_DIR:$PATH:/usr/bin:/bin:/usr/$CHOST/gcc-bin/14"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:/usr/lib:/lib:/usr/lib/gcc/$CHOST/14:/usr/$CHOST/gcc-bin/14"
fi

gcc_versions=($(eselect gcc list | awk '{print $2}' | sort -V))
if (( ${#gcc_versions[@]} >= 2 )); then
    second_latest_gcc="${gcc_versions[-2]}"
else
    second_latest_gcc="${gcc_versions[-1]}"
fi

[[ -n "$second_latest_gcc" ]] && eselect gcc set "$second_latest_gcc" 2>/dev/null

export PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig"
export MAGIC="/usr/share/misc/magic.mgc"
export PKG_CONFIG="/usr/bin/pkg-config"
export GIT_TEMPLATE_DIR="/usr/share/git-core/templates"
export CPPFLAGS="-I/usr/include"

# --- Python ---
export PYEXEC_BASE="/usr/lib/python-exec"
export PYTHON_EXEC_PREFIX="/usr"
export PYTHON_EXECUTABLES="$PYEXEC_BASE"

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

python_site_second="/usr/lib/python${second_dot}/site-packages"
python_site_latest="/usr/lib/python${latest_dot}/site-packages"

if [[ -d "$python_site_second" && -d "$python_site_latest" ]]; then
    export PYTHONPATH="${python_site_second}:${python_site_latest}${PYTHONPATH:+:$(realpath -m $PYTHONPATH)}"
elif [[ -d "$python_site_latest" ]]; then
    export PYTHONPATH="${python_site_latest}${PYTHONPATH:+:$(realpath -m $PYTHONPATH)}"
else
    export PYTHONPATH="${PYTHONPATH:+$(realpath -m $PYTHONPATH)}"
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

[[ -d /usr/include ]] && CFLAGS+="-I/usr/include "
[[ -d /include ]] && CFLAGS+="-I/include "
export CFLAGS

[[ -d /usr/include ]] && CXXFLAGS+="-I/usr/include "
[[ -d /include ]] && CXXFLAGS+="-I/include "
export CXXFLAGS

[[ -d /usr/lib ]] && LDFLAGS+="-L/usr/lib "
[[ -d /lib ]] && LDFLAGS+="-L/lib "
[[ -d /usr/local/lib ]] && LDFLAGS+="-L/usr/local/lib "
export LDFLAGS

export LD="/usr/bin/ld"
export ACLOCAL_PATH="/usr/share/aclocal:$ACLOCAL_PATH"
export M4PATH="/usr/share/m4:$M4PATH"
export MANPATH="/usr/share/man:/usr/local/share/man:$MANPATH"
export DISPLAY=":0"
export GDK_BACKEND="x11"
export CLUTTER_BACKEND="x11"
export PYTHONMULTIPROCESSING_START_METHOD=fork
export EPYTHON="python${second_dot}"
export PYTHON="python${second_dot}"
export PORTAGE_PYTHON="python${second_dot}"

MAKECONF="/etc/portage/make.conf"
if [[ -w "$MAKECONF" ]]; then
    sed -i "/^PYTHON_TARGETS=/d" "$MAKECONF"
    sed -i "/^PYTHON_SINGLE_TARGET=/d" "$MAKECONF"
    echo "PYTHON_TARGETS=\"python${second_underscore}\"" >> "$MAKECONF"
    echo "PYTHON_SINGLE_TARGET=\"python${second_underscore}\"" >> "$MAKECONF"
fi

eselect python set "python${second_dot}" 2>/dev/null || true
eselect python set --python3 "python${second_dot}" 2>/dev/null || true

if [[ -d "/usr/lib/python${latest_dot}" && "$latest_dot" != "$second_dot" ]]; then
    echo "${YELLOW}[chard] Detected new Python slot ($latest_dot). Rebuilding portage and deps...${RESET}"
fi

LLVM_BASE="/usr/lib/llvm"

if [[ -d "$LLVM_BASE" ]]; then
    mapfile -t all_llvm_versions < <(ls -1 "$LLVM_BASE" 2>/dev/null | grep -E '^[0-9]+(\.[0-9]+)*$' | sort -V)
else
    all_llvm_versions=()
fi

latest_llvm=""
second_latest_llvm=""

if (( ${#all_llvm_versions[@]} > 0 )); then
    latest_llvm="${all_llvm_versions[-1]}"
fi

if (( ${#all_llvm_versions[@]} > 1 )); then
    second_latest_llvm="${all_llvm_versions[-2]}"
else
    second_latest_llvm="$latest_llvm"
fi

if [[ -n "$second_latest_llvm" ]]; then
    export LLVM_DIR="$LLVM_BASE/$second_latest_llvm"
    export LLVM_VERSION="$second_latest_llvm"

    [[ -d "$LLVM_DIR/bin" ]] && export PATH="$LLVM_DIR/bin:$PATH"
    [[ -d "$LLVM_DIR/lib" ]] && export LD_LIBRARY_PATH="$LLVM_DIR/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    [[ -d "$LLVM_DIR/lib/pkgconfig" ]] && export PKG_CONFIG_PATH="$LLVM_DIR/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
fi

llvm_versions=($(eselect llvm list | awk '{print $2}' | sort -V))
if (( ${#llvm_versions[@]} >= 2 )); then
    second_latest_llvm="${llvm_versions[-2]}"
else
    second_latest_llvm="${llvm_versions[-1]}"
fi

[[ -n "$second_latest_llvm" ]] && eselect llvm set "$second_latest_llvm" 2>/dev/null

alias smrt='SMRT'

if [[ -f /bin/.smrt_env.sh ]]; then
    source /bin/.smrt_env.sh
fi

dbus-daemon --system --fork 2>/dev/null

# <<< END CHARD .BASHRC >>>
