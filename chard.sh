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

export CHARD_RC="$CHARD_ROOT/.chardrc"
export PORTDIR="$CHARD_ROOT/usr/portage"
export DISTDIR="$CHARD_ROOT/var/cache/distfiles"
export PKGDIR="$CHARD_ROOT/var/cache/packages"
export PORTAGE_TMPDIR="$CHARD_ROOT/var/tmp"
export SANDBOX="$CHARD_ROOT/usr/bin/sandbox"
export GIT_EXEC_PATH="$CHARD_ROOT/usr/libexec/git-core"
export PYTHONMULTIPROCESSING_START_METHOD=fork

ARCH=$(uname -m)
case "$ARCH" in
    x86_64) CHOST=x86_64-pc-linux-gnu ;;
    aarch64) CHOST=aarch64-unknown-linux-gnu ;;
    *) echo "Unknown architecture: $ARCH"; exit 1 ;;
esac

PERL_BASE="$CHARD_ROOT/usr/lib/perl5"
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

    BIN_DIR="$CHARD_ROOT/usr/bin"
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
    gcc_bin_path="$CHARD_ROOT/usr/$CHOST/gcc-bin/${gcc_version}"
    gcc_lib_path="$CHARD_ROOT/usr/lib/gcc/$CHOST/$gcc_version"

    if [[ -d "$gcc_bin_path" ]]; then
        export PATH="$PYEXEC_DIR:$PATH:$CHARD_ROOT/usr/bin:$CHARD_ROOT/bin:$gcc_bin_path"
    else
        export PATH="$PYEXEC_DIR:$PATH:$CHARD_ROOT/usr/bin:$CHARD_ROOT/bin:$CHARD_ROOT/usr/$CHOST/gcc-bin/14"
    fi

    if [[ -d "$gcc_lib_path" ]]; then
        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:$CHARD_ROOT/usr/lib:$CHARD_ROOT/lib:$gcc_lib_path:$gcc_bin_path"
    else
        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:$CHARD_ROOT/usr/lib:$CHARD_ROOT/lib:$CHARD_ROOT/usr/lib/gcc/$CHOST/14:$CHARD_ROOT/usr/$CHOST/gcc-bin/14"
    fi
else
    export PATH="$PYEXEC_DIR:$PATH:$CHARD_ROOT/usr/bin:$CHARD_ROOT/bin:$CHARD_ROOT/usr/$CHOST/gcc-bin/14"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:$CHARD_ROOT/usr/lib:$CHARD_ROOT/lib:$CHARD_ROOT/usr/lib/gcc/$CHOST/14:$CHARD_ROOT/usr/$CHOST/gcc-bin/14"
fi

export PKG_CONFIG_PATH="$CHARD_ROOT/usr/lib/pkgconfig:$CHARD_ROOT/usr/lib64/pkgconfig:$CHARD_ROOT/usr/lib/pkgconfig:$CHARD_ROOT/usr/local/lib/pkgconfig:$CHARD_ROOT/usr/local/share/pkgconfig"
export MAGIC="$CHARD_ROOT/usr/share/misc/magic.mgc"
export PKG_CONFIG="$CHARD_ROOT/usr/bin/pkg-config"
export GIT_TEMPLATE_DIR="$CHARD_ROOT/usr/share/git-core/templates"
export CPPFLAGS="-I${CHARD_ROOT}usr/include"
PYEXEC_BASE="$CHARD_ROOT/usr/lib/python-exec"
PYTHON_EXEC_PREFIX="$CHARD_ROOT/usr"
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

python_site_second="$CHARD_ROOT/usr/lib/python${second_dot}/site-packages"
python_site_latest="$CHARD_ROOT/usr/lib/python${latest_dot}/site-packages"

if [[ -n "$PYTHONPATH" ]]; then
    export PYTHONPATH="${python_site_second}:${python_site_latest}:$(realpath -m $PYTHONPATH)"
else
    export PYTHONPATH="${python_site_second}:${python_site_latest}"
fi

export PYEXEC_DIR="${PYEXEC_BASE}/${latest_python}"

export CC="$CHARD_ROOT/usr/bin/gcc"
export CXX="$CHARD_ROOT/usr/bin/g++"
export AR="$CHARD_ROOT/usr/bin/ar"
export NM="$CHARD_ROOT/usr/bin/gcc-nm"
export RANLIB="$CHARD_ROOT/usr/bin/gcc-ranlib"
export STRIP="$CHARD_ROOT/usr/bin/strip"
export XDG_DATA_DIRS="$CHARD_ROOT/usr/share:$CHARD_ROOT/usr/share"
export EMERGE_DEFAULT_OPTS="--quiet-build=y --jobs=$(nproc)"
export CFLAGS="-O2 -pipe -I${CHARD_ROOT}usr/include -I${CHARD_ROOT}include $CFLAGS"
export CXXFLAGS="-O2 -pipe -I${CHARD_ROOT}usr/include -I${CHARD_ROOT}include $CXXFLAGS"

LDFLAGS=""

[[ -d "$CHARD_ROOT/usr/lib" ]]        && LDFLAGS+="-L$CHARD_ROOT/usr/lib "
[[ -d "$CHARD_ROOT/lib" ]]            && LDFLAGS+="-L$CHARD_ROOT/lib "
[[ -d "$CHARD_ROOT/usr/local/lib" ]]  && LDFLAGS+="-L$CHARD_ROOT/usr/local/lib "


export LDFLAGS
export LD="$CHARD_ROOT/usr/bin/ld"
export ACLOCAL_PATH="$CHARD_ROOT/usr/share/aclocal:$ACLOCAL_PATH"
export M4PATH="$CHARD_ROOT/usr/share/m4:$M4PATH"
export MANPATH="$CHARD_ROOT/usr/share/man:$CHARD_ROOT/usr/local/share/man:$MANPATH"
export DISPLAY=":0"
export GDK_BACKEND="x11"
export CLUTTER_BACKEND="x11"
export PYTHONMULTIPROCESSING_START_METHOD=fork

    echo "[*] Running '$*' inside Chard environment..."
    env \
        ROOT="$ROOT" \
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
        HOME="$CHARD_HOME" \
        "$@"
}

chard_reinstall() {
    if [ -z "$CHARD_ROOT" ]; then
        echo "Error: CHARD_ROOT not found."
        exit 1
    fi

    local script="$CHARD_ROOT/Reinstall_Chard.sh"

    if [ -d "$CHARD_ROOT" ]; then
        if [ -x "$script" ]; then
            echo "Reinstalling Chard..."
            sudo bash "$script"
        else
            sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Reinstall_Chard.sh"  -o "$CHARD_ROOT/bin/Reinstall_Chard.sh"
            sudo chmod +x "$CHARD_ROOT/bin/Reinstall_Chard.sh"
            $CHARD_ROOT/bin/Reinstall_Chard.sh
        fi
    else
        echo "${RED}Installation directory not found: $CHARD_ROOT ${RESET}"
        exit 1
    fi
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
            sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Uninstall_Chard.sh"  -o "$CHARD_ROOT/bin/Uninstall_Chard.sh"
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
        echo "${GREEN}Chard command examples:"
        echo "  python, gcc, Et al....   - Run all available binaries from the Chard environment!"
        echo "  reinstall                - Reinstall or update Chard"
        echo "  uninstall                - Remove Chard environment and entries"
        echo "  categories | cat         - List available Portage categories"
        echo "  help                     - Show this help message"
        echo
        echo "Examples:"
        echo "  chard emerge app-misc/foo"
        echo "  chard cat"
        echo "  chard python"
        echo "${RESET}"
        ;;
    reinstall)
        chard_reinstall
        ;;
    uninstall)
         chard_uninstall
        ;;
    root)

        sudo cp -a "$CHARD_ROOT/usr/bin/bwrap" "$CHARD_ROOT/$CHARD_HOME/"
        sudo mount --bind "$CHARD_ROOT/$CHARD_HOME/bwrap" "$CHARD_ROOT/usr/bin/bwrap"
        sudo chown root:root "$CHARD_ROOT/usr/bin/bwrap"
        sudo chmod u+s "$CHARD_ROOT/usr/bin/bwrap"
        
        sudo mountpoint -q "$CHARD_ROOT/run/chrome" || sudo mount --bind /run/chrome "$CHARD_ROOT/run/chrome"
        sudo mountpoint -q "$CHARD_ROOT/run/dbus"   || sudo mount --bind /run/dbus "$CHARD_ROOT/run/dbus"
        sudo mountpoint -q "$CHARD_ROOT/dev/dri"    || sudo mount --bind /dev/dri "$CHARD_ROOT/dev/dri"
        sudo mountpoint -q "$CHARD_ROOT/dev/input"  || sudo mount --bind /dev/input "$CHARD_ROOT/dev/input"
        sudo mountpoint -q "$CHARD_ROOT/run/cras"   || sudo mount --bind /run/cras "$CHARD_ROOT/run/cras"
        sudo chroot "$CHARD_ROOT" /bin/bash -c "


            mountpoint -q /proc       || mount -t proc proc /proc 2>/dev/null
            mountpoint -q /sys        || mount -t sysfs sys /sys 2>/dev/null
            mountpoint -q /dev        || mount -t devtmpfs devtmpfs /dev 2>/dev/null
            mountpoint -q /dev/shm    || mount -t tmpfs tmpfs /dev/shm 2>/dev/null
            mountpoint -q /dev/pts    || mount -t devpts devpts /dev/pts 2>/dev/null
            mountpoint -q /etc/ssl    || mount --bind /etc/ssl /etc/ssl 2>/dev/null
            mountpoint -q /run/dbus   || mount --bind /run/dbus /run/dbus 2>/dev/null
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
            source \$HOME/.bashrc 2>/dev/null
            source \$HOME/.smrt_env.sh
            su \$USER
            source \$HOME/.bashrc 2>/dev/null
            source \$HOME/.smrt_env.sh
        
            dbus-daemon --system --fork 2>/dev/null
        
            /bin/bash
        
            umount -l /dev/zram0   2>/dev/null || true
            umount -l /run/chrome  2>/dev/null || true
            umount -l /run/dbus    2>/dev/null || true
            umount -l /etc/ssl     2>/dev/null || true
            umount -l /dev/pts     2>/dev/null || true
            umount -l /dev/shm     2>/dev/null || true
            umount -l /dev         2>/dev/null || true
            umount -l /sys         2>/dev/null || true
            umount -l /proc        2>/dev/null || true
        "
        sudo umount -l "$CHARD_ROOT/run/cras"   2>/dev/null || true
        sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
        sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
        sudo umount -l "$CHARD_ROOT/run/dbus"   2>/dev/null || true
        sudo umount -l "$CHARD_ROOT/run/chrome" 2>/dev/null || true
        sudo umount -l "$CHARD_ROOT/$CHARD_HOME/bwrap" 2>/dev/null || true
        ;;
    categories|cat)
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
    *)
        chard_run "$cmd" "$@"
        ;;
esac
