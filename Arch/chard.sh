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

cleanup_chroot() {
    sudo umount -l "$CHARD_ROOT/run/cras"   2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/run/chrome" 2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/run/dbus"   2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/etc/ssl"    2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev/pts"    2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev/shm"    2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev"        2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/sys"        2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/proc"       2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/tmp/usb_mount" 2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/run/user/1000" 2>/dev/null || true
    sleep 0.2
    sudo umount -l -f "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null || true
    sleep 0.2
    sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"               2>/dev/null || true
    sleep 0.2
    sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT" 2>/dev/null || true
    sleep 0.2
    sudo setfacl -Rb /run/chrome 2>/dev/null
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
    x86_64)
        CHOST="x86_64-pc-linux-gnu"
        ;;
    aarch64|arm64)
        CHOST="aarch64-unknown-linux-gnu"
        ;;
    *)
        echo "[!] Unsupported architecture: $ARCH"
        ;;
esac

chard_run() {
    if [ $# -lt 1 ]; then
        echo "${GREEN}chard ${RESET}${RED}binary${YELLOW} --args${RESET}"
        return 1
    fi

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        CHOST="x86_64-pc-linux-gnu"
        ;;
    aarch64|arm64)
        CHOST="aarch64-unknown-linux-gnu"
        ;;
    *)
        echo "[!] Unsupported architecture: $ARCH"
        ;;
esac

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

chard_unmount() {        
    sudo umount -l "$CHARD_ROOT/run/cras"   2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/run/dbus"   2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/run/chrome" 2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/etc/ssl"    2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev/pts"    2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev/shm"    2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev"        2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/sys"        2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/proc"       2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/tmp/usb_mount" 2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/run/user/1000" 2>/dev/null || true
    sleep 0.2
    sudo umount -l -f "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null || true
    sleep 0.2
    sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"               2>/dev/null || true
    sleep 0.2
    sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT" 2>/dev/null || true
    sleep 0.2
    sudo setfacl -Rb /run/chrome 2>/dev/null
    echo
    echo "${RESET}${YELLOW}Chard safely unmounted${RESET}"
    echo
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
            sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/arch/Uninstall_Chard.sh"  -o "$CHARD_ROOT/bin/Uninstall_Chard.sh"
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
        echo "${RESET}"
        echo
        ;;
    uninstall)
         chard_uninstall
        ;;
    root)
        sudo rm -f /run/chrome/pipewire-0.lock /run/chrome/pipewire-0-manager.lock
        sudo rm -f /run/chrome/pulse/native /run/chrome/pulse/*
        killall -9 pipewire 2>/dev/null
        killall -9 pipewire-pulse 2>/dev/null
        killall -9 pulseaudio 2>/dev/null
        killall -9 wireplumber 2>/dev/null
        sudo mount --bind "$CHARD_ROOT" "$CHARD_ROOT"
        sudo mount --make-rslave "$CHARD_ROOT"
        sudo mount --bind "$CHARD_ROOT/$CHARD_HOME/bwrap" "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null
        sudo chown root:root "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null
        sudo chmod u+s "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null
        sudo chown root:root "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null
        sudo chmod u+s "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null
        
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/chrome" || sudo mount --bind /run/chrome "$CHARD_ROOT/run/chrome" 2>/dev/null
            sudo mountpoint -q "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" || sudo mount --bind "/home/chronos/user/MyFiles/Downloads" "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null
            sudo mount -o remount,rw,bind "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null
        else
            sudo mountpoint -q "$CHARD_ROOT/run/user/1000" || sudo mount --bind /run/user/1000 "$CHARD_ROOT/run/user/1000" 2>/dev/null
        fi
        
        sudo mountpoint -q "$CHARD_ROOT/run/dbus"   || sudo mount --bind /run/dbus "$CHARD_ROOT/run/dbus" 2>/dev/null
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
                sudo rm -f /run/chrome/pipewire-0.lock /run/chrome/pipewire-0-manager.lock
                sudo rm -f /run/chrome/pulse/native /run/chrome/pulse/*
                killall -9 pipewire 2>/dev/null
                killall -9 pipewire-pulse 2>/dev/null
                killall -9 pulseaudio 2>/dev/null
                killall -9 wireplumber 2>/dev/null
                sudo setfacl -Rm u:1000:rwx /root 2>/dev/null
                sudo setfacl -R -m u:1000:rw /dev/snd
                sudo setfacl -R -d -m u:1000:rw /dev/snd
                sudo mkdir -p /run/chrome/pulse
                sudo chown 1000:1000 /run/chrome/pulse
                sudo chmod 770 /run/chrome/pulse
                [ -f \"\$HOME/.bashrc\" ] && source \"\$HOME/.bashrc\" 2>/dev/null
                cd ~/
                xfce4-terminal 2>/dev/null &
                exec chard_sommelier
            "
            setfacl -Rb /run/chrome/pulse 2>/dev/null
            setfacl -Rb /run/chrome 2>/dev/null
            setfacl -Rb /root 2>/dev/null
            killall -9 pipewire 2>/dev/null
            killall -9 pipewire-pulse 2>/dev/null
            killall -9 pulseaudio 2>/dev/null
            killall -9 wireplumber 2>/dev/null
            umount -l /tmp/usb_mount 2>/dev/null || true
            umount -l /dev/zram0   2>/dev/null || true
            umount -l /run/chrome  2>/dev/null || true
            umount -l /run/dbus    2>/dev/null || true
            umount -l /etc/ssl     2>/dev/null || true
            umount -l /dev/pts     2>/dev/null || true
            umount -l /dev/shm     2>/dev/null || true
            umount -l /dev         2>/dev/null || true
            umount -l /sys         2>/dev/null || true
            umount -l /proc        2>/dev/null || true
        '
        
        chard_unmount
        sudo rm -f /run/chrome/pulse/native
        sudo rm -f /run/chrome/pulse/*
        sudo mkdir -p /run/chrome/pulse
        sudo chown chronos:chronos /run/chrome/pulse
        sudo chmod 770 /run/chrome/pulse
        killall -9 pipewire 2>/dev/null
        killall -9 pipewire-pulse 2>/dev/null
        killall -9 pulseaudio 2>/dev/null
        killall -9 wireplumber 2>/dev/null
        sudo pkill -f xfce4-session
        sudo pkill -f xfwm4
        sudo pkill -f xfce4-panel
        sudo pkill -f xfdesktop
        sudo pkill -f xfce4-terminal
        sudo pkill -f xfce4-*
        sudo pkill -f Xorg
        ;;
    chariot)
        sudo mount --bind "$CHARD_ROOT" "$CHARD_ROOT"
        sudo mount --make-rslave "$CHARD_ROOT"
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/chrome" || sudo mount --bind /run/chrome "$CHARD_ROOT/run/chrome" 2>/dev/null
            sudo mountpoint -q "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" || sudo mount --bind "/home/chronos/user/MyFiles/Downloads" "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null
            sudo mount -o remount,rw,bind "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null
        
        else
            sudo mountpoint -q "$CHARD_ROOT/run/user/1000" || sudo mount --bind /run/user/1000 "$CHARD_ROOT/run/user/1000" 2>/dev/null
        fi
                
        sudo mountpoint -q "$CHARD_ROOT/run/dbus"   || sudo mount --bind /run/dbus "$CHARD_ROOT/run/dbus" 2>/dev/null
        sudo mountpoint -q "$CHARD_ROOT/dev/dri"    || sudo mount --bind /dev/dri "$CHARD_ROOT/dev/dri" 2>/dev/null
        sudo mountpoint -q "$CHARD_ROOT/dev/input"  || sudo mount --bind /dev/input "$CHARD_ROOT/dev/input" 2>/dev/null
                
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/cras "$CHARD_ROOT/run/cras" 2>/dev/null
        else
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/user/1000/pulse "$CHARD_ROOT/run/cras" 2>/dev/null
        fi
        
        sudo mount --bind "$CHARD_ROOT" "$CHARD_ROOT"
        sudo mount --make-rslave "$CHARD_ROOT"
        
        sudo chroot "$CHARD_ROOT" /bin/bash -c '
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
        
            CHARD_HOME=$(cat /.chard_home)
            HOME=$CHARD_HOME
            CHARD_USER=$(cat /.chard_user)
            USER=$CHARD_USER
            GROUP_ID=1000
            USER_ID=1000
        
            sudo -u "$USER" bash -c "
                cleanup() {
                    echo \"Logging out $USER\"
                }
                trap cleanup EXIT INT TERM
                source \$HOME/.bashrc 2>/dev/null
                sudo chown -R 1000:1000 $HOME
                cd \$HOME
                /bin/chariot
            "
        
            umount -l /dev/zram0   2>/dev/null || true
            umount -l /run/chrome  2>/dev/null || true
            umount -l /run/dbus    2>/dev/null || true
            umount -l /etc/ssl     2>/dev/null || true
            umount -l /dev/pts     2>/dev/null || true
            umount -l /dev/shm     2>/dev/null || true
            umount -l /dev         2>/dev/null || true
            umount -l /sys         2>/dev/null || true
            umount -l /proc        2>/dev/null || true
        '
        
        chard_unmount
        ;;
    safe)
        sudo mount --bind "$CHARD_ROOT" "$CHARD_ROOT"
        sudo mount --make-rslave "$CHARD_ROOT"
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/chrome" || sudo mount --bind /run/chrome "$CHARD_ROOT/run/chrome" 2>/dev/null
            sudo mountpoint -q "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" || sudo mount --bind "/home/chronos/user/MyFiles/Downloads" "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null
            sudo mount -o remount,rw,bind "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null
        else
            sudo mountpoint -q "$CHARD_ROOT/run/user/1000" || sudo mount --bind /run/user/1000 "$CHARD_ROOT/run/user/1000" 2>/dev/null
        fi
        
        sudo mountpoint -q "$CHARD_ROOT/run/dbus"   || sudo mount --bind /run/dbus "$CHARD_ROOT/run/dbus" 2>/dev/null
        sudo mountpoint -q "$CHARD_ROOT/dev/dri"    || sudo mount --bind /dev/dri "$CHARD_ROOT/dev/dri" 2>/dev/null
        sudo mountpoint -q "$CHARD_ROOT/dev/input"  || sudo mount --bind /dev/input "$CHARD_ROOT/dev/input" 2>/dev/null
        
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/cras "$CHARD_ROOT/run/cras" 2>/dev/null
        else
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/user/1000/pulse "$CHARD_ROOT/run/cras" 2>/dev/null
        fi
                
        sudo mountpoint -q "$CHARD_ROOT/run/dbus"   || sudo mount --bind /run/dbus "$CHARD_ROOT/run/dbus" 2>/dev/null
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
        
        chard_unmount
        ;;
        # Denny's version checker
    version)
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
                        "$CHARD_ROOT/bin/Reinstall_Chard.sh"
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
        chard_unmount
        ;;
    *)
        chard_run "$cmd" "$@"
        ;;
esac
