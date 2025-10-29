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
        echo "${RESET}${GREEN}"
        echo "[1] Quick Reinstall (Update Chard)"
        echo "${RESET}${YELLOW}[2] Full Reinstall (Run Chard Installer)"
        echo "${RESET}${RED}[q] Cancel"
        echo "${RESET}${GREEN}"
        read -p "Choose an option [1/2/q]: " choice
        
        case "$choice" in
            1)
                echo "${RESET}${GREEN}[*] Performing quick reinstall..."
                CURRENT_SHELL=$(basename "$SHELL")
                CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
                DEFAULT_BASHRC="$HOME/.bashrc"
                TARGET_FILE=""
                if [ -f "$CHROMEOS_BASHRC" ]; then
                    TARGET_FILE="$CHROMEOS_BASHRC"
                else
                    TARGET_FILE="$DEFAULT_BASHRC"
                    [ -f "$TARGET_FILE" ] || touch "$TARGET_FILE"
                fi
                
                sed -i '/^# <<< CHARD ENV MARKER <<</,/^# <<< END CHARD ENV MARKER <<</d' "$TARGET_FILE"
                
                if ! grep -Fxq "# <<< CHARD ENV MARKER <<<" "$TARGET_FILE"; then
                    {
                        echo "# <<< CHARD ENV MARKER <<<"
                        echo "source \"$CHARD_RC\""
                        echo "# <<< END CHARD ENV MARKER <<<"
                    } >> "$TARGET_FILE"
                fi

                sudo chroot "$CHARD_ROOT" /bin/bash -c "
                CHARD_USER=\$(cat /.chard_user)
                CHARD_HOME=\$(cat /.chard_home)
                USER=\$CHARD_USER
                HOME=\$CHARD_HOME
                
                getent group 1000 >/dev/null   || groupadd -g 1000 chronos
                getent group 601 >/dev/null    || groupadd -g 601 wayland
                getent group 602 >/dev/null    || groupadd -g 602 arc-bridge
                getent group 20205 >/dev/null  || groupadd -g 20205 arc-keymintd
                getent group 604 >/dev/null    || groupadd -g 604 arc-sensor
                getent group 665357 >/dev/null || groupadd -g 665357 android-everybody
                getent group 18 >/dev/null     || groupadd -g 18 audio
                getent group 222 >/dev/null    || groupadd -g 222 input
                getent group 7 >/dev/null      || groupadd -g 7 lp
                getent group 27 >/dev/null     || groupadd -g 27 video
                getent group 423 >/dev/null    || groupadd -g 423 bluetooth-audio
                getent group 600 >/dev/null    || groupadd -g 600 cras
                getent group 85 >/dev/null     || groupadd -g 85 usb
                getent group 20162 >/dev/null  || groupadd -g 20162 traced-producer
                getent group 20164 >/dev/null  || groupadd -g 20164 traced-consumer
                getent group 1001 >/dev/null   || groupadd -g 1001 chronos-access
                getent group 240 >/dev/null    || groupadd -g 240 brltty
                getent group 20150 >/dev/null  || groupadd -g 20150 arcvm-boot-notification-server
                getent group 20189 >/dev/null  || groupadd -g 20189 arc-mojo-proxy
                getent group 20152 >/dev/null  || groupadd -g 20152 arc-host-clock
                getent group 608 >/dev/null    || groupadd -g 608 midis
                getent group 415 >/dev/null    || groupadd -g 415 suzy-q
                getent group 612 >/dev/null    || groupadd -g 612 ml-core
                getent group 311 >/dev/null    || groupadd -g 311 fuse-archivemount
                getent group 20137 >/dev/null  || groupadd -g 20137 crash
                getent group 419 >/dev/null    || groupadd -g 419 crash-access
                getent group 420 >/dev/null    || groupadd -g 420 crash-user-access
                getent group 304 >/dev/null    || groupadd -g 304 fuse-drivefs
                getent group 20215 >/dev/null  || groupadd -g 20215 regmond_senders
                getent group 603 >/dev/null    || groupadd -g 603 arc-camera
                getent group 20042 >/dev/null  || groupadd -g 20042 camera
                getent group 208 >/dev/null    || groupadd -g 208 pkcs11
                getent group 303 >/dev/null    || groupadd -g 303 policy-readers
                getent group 20132 >/dev/null  || groupadd -g 20132 arc-keymasterd
                getent group 605 >/dev/null    || groupadd -g 605 debugfs-access
                
                if ! id \"\$CHARD_USER\" &>/dev/null; then
                    useradd -u 1000 -g 1000 -d \"/\$CHARD_HOME\" -M -s /bin/bash \"\$CHARD_USER\"
                fi
                
                usermod -aG chronos,wayland,arc-bridge,arc-keymintd,arc-sensor,android-everybody,audio,input,lp,video,bluetooth-audio,cras,usb,traced-producer,traced-consumer,chronos-access,brltty,arcvm-boot-notification-server,arc-mojo-proxy,arc-host-clock,midis,suzy-q,ml-core,fuse-archivemount,crash,crash-access,crash-user-access,fuse-drivefs,regmond_senders,arc-camera,camera,pkcs11,policy-readers,arc-keymasterd,debugfs-access \$CHARD_USER
                
                mkdir -p \"/\$CHARD_HOME\"
                chown 1000:1000 \"/\$CHARD_HOME\"
                
                mkdir -p /etc/sudoers.d
                chown root:root /etc/sudoers.d
                chmod 755 /etc/sudoers.d
                chown root:root /etc/sudoers.d/\$USER
                chmod 440 /etc/sudoers.d/\$USER
                chown root:root /usr/bin/sudo
                chmod 4755 /usr/bin/sudo
                echo \"\$CHARD_USER ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/\$CHARD_USER
                echo \"Passwordless sudo configured for \$CHARD_USER\"
                "
                echo "$CHARD_USER ALL=(ALL) NOPASSWD: ALL" | sudo tee $CHARD_ROOT/etc/sudoers.d/$CHARD_USER > /dev/null
                echo "${RESET}${RED}Detected .bashrc: ${BOLD}${TARGET_FILE}${RESET}${RED}"
                CHARD_HOME="$(dirname "$TARGET_FILE")"
                CHARD_HOME="${CHARD_HOME#/}"
                
                if [[ "$CHARD_HOME" == home/* ]]; then
                    CHARD_HOME="${CHARD_HOME%%/user*}"
                
                    CHARD_USER="${CHARD_HOME#*/}"
                fi
                
                echo "CHARD_HOME: $CHARD_ROOT/$CHARD_HOME"
                echo "CHARD_USER: $CHARD_USER"
                sudo mkdir -p "$CHARD_ROOT/$CHARD_HOME"
                
                sudo mkdir -p "$CHARD_ROOT/etc/portage" \
                              "$CHARD_ROOT/etc/sandbox.d" \
                              "$CHARD_ROOT/etc/ssl" \
                              "$CHARD_ROOT/usr/bin" \
                              "$CHARD_ROOT/usr/lib" \
                              "$CHARD_ROOT/usr/lib64" \
                              "$CHARD_ROOT/usr/include" \
                              "$CHARD_ROOT/usr/share" \
                              "$CHARD_ROOT/usr/local/bin" \
                              "$CHARD_ROOT/usr/local/lib" \
                              "$CHARD_ROOT/usr/local/include" \
                              "$CHARD_ROOT/var/tmp/build" \
                              "$CHARD_ROOT/var/cache/distfiles" \
                              "$CHARD_ROOT/var/cache/packages" \
                              "$CHARD_ROOT/var/log" \
                              "$CHARD_ROOT/var/run" \
                              "$CHARD_ROOT/dev/shm" \
                              "$CHARD_ROOT/dev/pts" \
                              "$CHARD_ROOT/proc" \
                              "$CHARD_ROOT/sys" \
                              "$CHARD_ROOT/tmp" \
                              "$CHARD_ROOT/run" \
                              "$CHARD_ROOT/$CHARD_HOME/.cargo" \
                              "$CHARD_ROOT/$CHARD_HOME/.rustup" \
                              "$CHARD_ROOT/$CHARD_HOME/.local/share" \
                              "$CHARD_ROOT/$CHARD_HOME/Desktop" \
                              "$CHARD_ROOT/mnt"
                
                sudo mkdir -p "$(dirname "$LOG_FILE")"
                sudo mkdir -p "$CHARD_ROOT/etc/portage/repos.conf"
                sudo mkdir -p "$CHARD_ROOT/bin" "$CHARD_ROOT/usr/bin" "$CHARD_ROOT/usr/lib" "$CHARD_ROOT/usr/lib64"
                echo "${BLUE}[*] Downloading Chard components...${RESET}"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/.chardrc"            -o "$CHARD_ROOT/.chardrc"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/.chard.env"          -o "$CHARD_ROOT/.chard.env"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/.chard.logic"        -o "$CHARD_ROOT/.chard.logic"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/SMRT.sh"             -o "$CHARD_ROOT/bin/SMRT"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/chard.sh"            -o "$CHARD_ROOT/bin/chard"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/.bashrc"             -o "$CHARD_ROOT/$CHARD_HOME/.bashrc"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/.rootrc"             -o "$CHARD_ROOT/bin/.rootrc"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/chariot.sh"          -o "$CHARD_ROOT/bin/chariot"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/chard_debug.sh"      -o "$CHARD_ROOT/bin/chard_debug"
                sudo chmod +x "$CHARD_ROOT/bin/chariot"
                sudo chmod +x "$CHARD_ROOT/bin/.rootrc"
                sudo chmod +x "$CHARD_ROOT/bin/chard_debug"
                for file in \
                    "$CHARD_ROOT/.chardrc" \
                    "$CHARD_ROOT/.chard.env" \
                    "$CHARD_ROOT/.chard.logic" \
                    "$CHARD_ROOT/bin/SMRT" \
                    "$CHARD_ROOT/$CHARD_HOME/.bashrc" \
                    "$CHARD_ROOT/bin/.rootrc" \
                    "$CHARD_ROOT/bin/chariot" \
                    "$CHARD_ROOT/bin/chard_debug" \
                    "$CHARD_ROOT/bin/chard"; do
                
                    if [ -f "$file" ]; then
                        if sudo grep -q '^# <<< CHARD_ROOT_MARKER >>>' "$file"; then
                            sudo sed -i -E "/^# <<< CHARD_ROOT_MARKER >>>/,/^# <<< END_CHARD_ROOT_MARKER >>>/c\
                # <<< CHARD_ROOT_MARKER >>>\n\
                CHARD_ROOT=\"$CHARD_ROOT\"\n\
                CHARD_HOME=\"$CHARD_HOME\"\n\
                CHARD_USER=\"$CHARD_USER\"\n\
                # <<< END_CHARD_ROOT_MARKER >>>" "$file"
                        else
                            sudo sed -i "1i # <<< CHARD_ROOT_MARKER >>>\n\
                CHARD_ROOT=\"$CHARD_ROOT\"\n\
                CHARD_HOME=\"$CHARD_HOME\"\n\
                CHARD_USER=\"$CHARD_USER\"\n\
                # <<< END_CHARD_ROOT_MARKER >>>\n" "$file"
                        fi
                
                        sudo chmod +x "$file"
                    else
                        echo "${RED}[!] Missing: $file — download failed?${RESET}"
                    fi
                done
                
                sudo mv "$CHARD_ROOT/bin/.rootrc" "$CHARD_ROOT/.bashrc"
                
                CURRENT_SHELL=$(basename "$SHELL")
                CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
                DEFAULT_BASHRC="$HOME/.bashrc"
                TARGET_FILE=""
                
                if [ -f "$CHROMEOS_BASHRC" ]; then
                    TARGET_FILE="$CHROMEOS_BASHRC"
                else
                    TARGET_FILE="$DEFAULT_BASHRC"
                    [ -f "$TARGET_FILE" ] || touch "$TARGET_FILE"
                fi
                
                add_chard_marker() {
                    local FILE="$1"
                
                    sed -i '/^# <<< CHARD ENV MARKER <<</,/^# <<< END CHARD ENV MARKER <<</d' "$FILE"
                
                    if ! grep -Fxq "# <<< CHARD ENV MARKER <<<" "$FILE"; then
                        {
                            echo "# <<< CHARD ENV MARKER <<<"
                            echo "source \"$CHARD_RC\""
                            echo "# <<< END CHARD ENV MARKER <<<"
                        } >> "$FILE"
                        echo "${BLUE}[+] Chard sourced to $FILE"
                    else
                        echo "${YELLOW}[!] Chard already sourced in $FILE"
                    fi
                }
                
                add_chard_marker "$TARGET_FILE"

                if [[ -f /etc/lsb-release ]]; then
                    BOARD_NAME=$(grep '^CHROMEOS_RELEASE_BOARD=' /etc/lsb-release 2>/dev/null | cut -d= -f2)
                    BOARD_NAME=${BOARD_NAME:-$(crossystem board 2>/dev/null || crossystem hwid 2>/dev/null || echo "root")}
                else
                    BOARD_NAME=$(hostnamectl 2>/dev/null | awk -F: '/Chassis/ {print $2}' | xargs)
                    BOARD_NAME=${BOARD_NAME:-$(uname -n)}
                fi
                
                BOARD_NAME=${BOARD_NAME%%-*}

                sudo tee "$CHARD_ROOT/usr/.chard_prompt.sh" >/dev/null <<EOF
#!/bin/bash
BOLD='\\[\\e[1m\\]'
RED='\\[\\e[31m\\]'
YELLOW='\\[\\e[33m\\]'
GREEN='\\[\\e[32m\\]'
RESET='\\[\\e[0m\\]'
PS1="\${BOLD}\${RED}chard\${BOLD}\${YELLOW}@\${BOLD}\${GREEN}$BOARD_NAME\${RESET} \\w # "
export PS1
EOF

                sudo chmod +x "$CHARD_ROOT/usr/.chard_prompt.sh"
                if ! grep -q '/usr/.chard_prompt.sh' "$CHARD_ROOT/$CHARD_HOME/.bashrc" 2>/dev/null; then
                    sudo tee -a "$CHARD_ROOT/$CHARD_HOME/.bashrc" > /dev/null <<'EOF'
source /usr/.chard_prompt.sh
EOF
                fi

                sudo chroot "$CHARD_ROOT" /bin/bash -c "
                mountpoint -q /dev        || mount -t devtmpfs devtmpfs /dev 2>/dev/null
                mountpoint -q /proc    || mount -t proc proc /proc
                mountpoint -q /sys     || mount -t sysfs sys /sys
                mountpoint -q /dev/pts || mount -t devpts devpts /dev/pts
                mountpoint -q /dev/shm || mount -t tmpfs tmpfs /dev/shm
                mountpoint -q /etc/ssl || mount --bind /etc/ssl /etc/ssl
            
                if [ -e /dev/zram0 ]; then
                    mount --rbind /dev/zram0 /dev/zram0 2>/dev/null
                    mount --make-rslave /dev/zram0 2>/dev/null
                fi
            
                chmod 1777 /tmp /var/tmp
            
                [ -e /dev/null    ] || mknod -m 666 /dev/null c 1 3
                [ -e /dev/tty     ] || mknod -m 666 /dev/tty c 5 0
                [ -e /dev/random  ] || mknod -m 666 /dev/random c 1 8
                [ -e /dev/urandom ] || mknod -m 666 /dev/urandom c 1 9

                mkdir -p /var/db/pkg /var/lib/portage
                CHARD_HOME=\$(cat /.chard_home)
                CHARD_USER=\$(cat /.chard_user)
                HOME=\$CHARD_HOME
                USER=\$CHARD_USER
                source \$HOME/.bashrc 2>/dev/null
                chown -R portage:portage /var/db/pkg /var/lib/portage
                chmod -R 755 /var/db/pkg
                chmod 644 /var/lib/portage/world
                /bin/SMRT
                source \$HOME/.smrt_env.sh
                chown 1000:1000 \$HOME/.smrt_env.sh
                emerge app-misc/resolve-march-native && \
                MARCH_FLAGS=\$(resolve-march-native) && \
                BASHRC=\"\$HOME/.bashrc\" && \
                awk -v march=\"\$MARCH_FLAGS\" '\
                /^# <<< CHARD_MARCH_NATIVE >>>$/ {inblock=1; print; next} \
                /^# <<< END CHARD_MARCH_NATIVE >>>$/ {inblock=0; print; next} \
                inblock { \
                    if (\$0 ~ /CFLAGS=.*-march=/) sub(/-march=[^ ]+/, march); \
                    if (\$0 ~ /COMMON_FLAGS=.*-march=/) sub(/-march=[^ ]+/, march); \
                    print; next \
                } \
                {print}' \"\$BASHRC\" > \"\$BASHRC.tmp\" && mv \"\$BASHRC.tmp\" \"\$BASHRC\" \
            
                umount -l /dev/zram0  2>/dev/null || true
                umount -l /etc/ssl    2>/dev/null || true
                umount -l /dev/shm    2>/dev/null || true
                umount -l /dev/pts    2>/dev/null || true
                umount -l /sys        2>/dev/null || true
                umount -l /proc       2>/dev/null || true
                umount -l /dev        2>/dev/null || true
            "
                sudo umount -l "$CHARD_ROOT/run/cras"   2>/dev/null || true
                sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
                sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
                sudo umount -l "$CHARD_ROOT/run/dbus"   2>/dev/null || true
                sudo umount -l "$CHARD_ROOT/run/chrome" 2>/dev/null || true
    
                if [[ -f /etc/lsb-release ]]; then
                    BOARD_NAME=$(grep '^CHROMEOS_RELEASE_BOARD=' /etc/lsb-release 2>/dev/null | cut -d= -f2)
                    BOARD_NAME=${BOARD_NAME:-$(crossystem board 2>/dev/null || crossystem hwid 2>/dev/null || echo "root")}
                else
                    BOARD_NAME=$(hostnamectl 2>/dev/null | awk -F: '/Chassis/ {print $2}' | xargs)
                    BOARD_NAME=${BOARD_NAME:-$(uname -n)}
                fi
                
                BOARD_NAME=${BOARD_NAME%%-*}
                
                if grep -q "CHROMEOS_RELEASE" /etc/lsb-release 2>/dev/null; then
                    XDG_RUNTIME_VALUE='export XDG_RUNTIME_DIR="$ROOT/run/chrome"'
                else
                    XDG_RUNTIME_VALUE='export XDG_RUNTIME_DIR="$ROOT/run/user/1000"'
                fi
                
                sudo sed -i "/# <<< CHARD_XDG_RUNTIME_DIR >>>/,/# <<< END CHARD_XDG_RUNTIME_DIR >>>/c\
                # <<< CHARD_XDG_RUNTIME_DIR >>>\n${XDG_RUNTIME_VALUE}\n# <<< END CHARD_XDG_RUNTIME_DIR >>>" \
                "$CHARD_ROOT/$CHARD_HOME/.bashrc"
                            
                echo "${GREEN}[*] Quick reinstall complete.${RESET}"
                ;;
            2)
                echo "${RESET}${YELLOW}[*] Performing full reinstall..."
                bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/Chard_Installer.sh?$(date +%s)")
                ;;
            q|Q|*)
                echo "${RESET}${RED}[*] Reinstall cancelled.${RESET}"
                ;;
         esac
        ;;
    uninstall)
        read -r -p "${RED}${BOLD}Are you sure you want to remove $CHARD_ROOT and chard entries from ~/.bashrc? [y/N] ${RESET}" ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            echo "${RESET}${MAGENTA}[*] Unmounting active bind mounts...${RESET}"
            sudo umount -l "$CHARD_ROOT/etc/ssl"      2>/dev/null || true
            sudo umount -l "$CHARD_ROOT/dev/pts"      2>/dev/null || true
            sudo umount -l "$CHARD_ROOT/dev/shm"      2>/dev/null || true
            sudo umount -l "$CHARD_ROOT/dev"          2>/dev/null || true
            sudo umount -l "$CHARD_ROOT/sys"          2>/dev/null || true
            sudo umount -l "$CHARD_ROOT/proc"         2>/dev/null || true
            sudo umount -l "$CHARD_ROOT/run/cras"     2>/dev/null || true
            sudo umount -l "$CHARD_ROOT/dev/input"    2>/dev/null || true
            sudo umount -l "$CHARD_ROOT/dev/dri"      2>/dev/null || true
            sudo umount -l "$CHARD_ROOT/dev"          2>/dev/null || true
            sudo umount -l "$CHARD_ROOT/run/dbus"     2>/dev/null || true
            sudo umount -l "$CHARD_ROOT/run/chrome"   2>/dev/null || true
            echo "${BLUE}[*] Removing $CHARD_ROOT${RESET}"
            sudo rm -rf "$CHARD_ROOT"   
            sed -i '/^# <<< CHARD ENV MARKER <<</,/^# <<< END CHARD ENV MARKER <<</d' "$FILE" 2>/dev/null || true
            {
                echo "# <<< CHARD ENV MARKER <<<"
                echo "source \"$CHARD_RC\""
                echo "# <<< END CHARD ENV MARKER <<<"
            } >> "$FILE"
            unset LD_PRELOAD
            echo "${CYAN}[+] Uninstalled ${RESET}"
        else
            echo "${RED}[*] Cancelled.${RESET}"
        fi
        ;;
    root)
        sudo mountpoint -q "$CHARD_ROOT/run/chrome" || sudo mount --bind /run/chrome "$CHARD_ROOT/run/chrome"
        sudo mountpoint -q "$CHARD_ROOT/run/dbus"   || sudo mount --bind /run/dbus "$CHARD_ROOT/run/dbus"
        sudo mountpoint -q "$CHARD_ROOT/dev/dri"    || sudo mount --bind /dev/dri "$CHARD_ROOT/dev/dri"
        sudo mountpoint -q "$CHARD_ROOT/dev/input"  || sudo mount --bind /dev/input "$CHARD_ROOT/dev/input"
        sudo mountpoint -q "$CHARD_ROOT/run/cras"   || sudo mount --bind /run/cras "$CHARD_ROOT/run/cras"
        sudo chroot "$CHARD_ROOT" /bin/bash -c "
            mountpoint -q /dev        || mount -t devtmpfs devtmpfs /dev 2>/dev/null
            mountpoint -q /proc    || mount -t proc proc /proc
            mountpoint -q /sys     || mount -t sysfs sys /sys
            mountpoint -q /dev/pts || mount -t devpts devpts /dev/pts
            mountpoint -q /dev/shm || mount -t tmpfs tmpfs /dev/shm
            mountpoint -q /etc/ssl || mount --bind /etc/ssl /etc/ssl
        
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
        
            dbus-daemon --system --fork 2>/dev/null
        
            /bin/bash
        
            umount -l /dev/zram0  2>/dev/null || true
            umount -l /etc/ssl    2>/dev/null || true
            umount -l /dev/shm    2>/dev/null || true
            umount -l /dev/pts    2>/dev/null || true
            umount -l /sys        2>/dev/null || true
            umount -l /proc       2>/dev/null || true
            umount -l /dev        2>/dev/null || true
        "
        sudo umount -l "$CHARD_ROOT/run/cras"   2>/dev/null || true
        sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
        sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
        sudo umount -l "$CHARD_ROOT/run/dbus"   2>/dev/null || true
        sudo umount -l "$CHARD_ROOT/run/chrome" 2>/dev/null || true
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
