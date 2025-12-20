#!/bin/bash

# <<< CHARD_ROOT_MARKER >>>
CHARD_ROOT=""
CHARD_HOME=""
CHARD_USER=""
# <<< END_CHARD_ROOT_MARKER >>>

# Day's Garcon Implementation
# <<< AUTO-DETECT DBUS KEYS (For Host Communication) >>>
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    CHROME_PID=$(pgrep -u chronos chrome | head -n1)
    if [ -n "$CHROME_PID" ]; then
        export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$CHROME_PID/environ | tr -d '\0' | sed 's/DBUS_SESSION_BUS_ADDRESS=//')
    fi
fi

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
    sudo umount -l "$CHARD_ROOT/etc/hosts"    || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/etc/resolv.conv"    || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/cras"    || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/input"   || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/dri"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/chrome"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/udev"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/dbus"    || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/etc/ssl"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/pts"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/shm"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev"         || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/sys"         || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/proc"        || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/tmp/usb_mount"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/tmp/"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/user/1000"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/"  || true
    sleep 0.05
    sudo umount -l -f "$CHARD_ROOT/usr/bin/bwrap"  || true
    sleep 0.05
    sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"                || true
    sleep 0.05
    sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT"  || true
    sleep 0.05
    sudo setfacl -Rb /run/chrome 
    sudo umount -l "$CHARD_ROOT/run/cras"    || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/input"   || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/dri"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/chrome"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/udev"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/dbus"    || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/etc/ssl"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/pts"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/shm"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev"         || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/sys"         || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/proc"        || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/tmp/usb_mount"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/tmp/"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/user/1000"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/"  || true
    sleep 0.05
    sudo umount -l -f "$CHARD_ROOT/usr/bin/bwrap"  || true
    sleep 0.05
    sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"                || true
    sleep 0.05
    sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT"  || true
    sleep 0.05
    sudo setfacl -Rb /run/chrome 
    echo
    echo "${RESET}${GREEN}Chard safely unmounted! ${RESET}"
    echo

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
    echo
    echo "${RESET}${YELLOW}Unmounting Chard... ${RESET}"
    echo
    sudo umount -l "$CHARD_ROOT/etc/hosts"    || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/etc/resolv.conv"    || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/cras"    || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/input"   || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/dri"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/udev"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/dbus"    || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/chrome"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/etc/ssl"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/pts"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/shm"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev"         || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/sys"         || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/proc"        || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/tmp/usb_mount"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/tmp/"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/user/1000"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/"  || true
    sleep 0.05
    sudo umount -l -f "$CHARD_ROOT/usr/bin/bwrap"  || true
    sleep 0.05
    sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"                || true
    sleep 0.05
    sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT"  || true
    sleep 0.05
    sudo setfacl -Rb /run/chrome 
    sudo chown -R root:audio /dev/snd 
    sudo chown -R root:root /dev/snd/by-path 
    sudo umount -l "$CHARD_ROOT/run/cras"    || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/input"   || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/dri"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/udev"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/dbus"    || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/chrome"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/etc/ssl"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/pts"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/shm"     || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev"         || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/sys"         || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/proc"        || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/tmp/usb_mount"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/tmp/"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/user/1000"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/"  || true
    sleep 0.05
    sudo umount -l -f "$CHARD_ROOT/usr/bin/bwrap"  || true
    sleep 0.05
    sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"                || true
    sleep 0.05
    sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap"  || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT"  || true
    sleep 0.05
    sudo setfacl -Rb /run/chrome 
    sudo chown -R root:audio /dev/snd 
    sudo chown -R root:root /dev/snd/by-path 
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
        echo "${RESET}"
        echo
        ;;
    uninstall)
         chard_uninstall
        ;;
    root|cr)
        CLEANUP_ENABLED=1
        
        # Day's changes
        sudo pkill -f "inotifywait.*MyFiles/chard" 
        sudo pkill -f "chard_garcon" 
        setsid chard_volume > /dev/null 2>&1
        
        sudo rm -f /run/chrome/pipewire-0.lock /run/chrome/pipewire-0-manager.lock 
        sudo rm -f /run/chrome/pulse/native /run/chrome/pulse/* 
        killall -9 pipewire pipewire-pulse pulseaudio steam 
        sudo mount --bind "$CHARD_ROOT" "$CHARD_ROOT"
        sudo mount --make-rslave "$CHARD_ROOT"
        sudo mount --bind "$CHARD_ROOT/$CHARD_HOME/bwrap" "$CHARD_ROOT/usr/bin/bwrap" 
        sudo chown root:root "$CHARD_ROOT/usr/bin/bwrap" 
        sudo chmod u+s "$CHARD_ROOT/usr/bin/bwrap" 
        sudo chown root:root "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 
        sudo chmod u+s "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 
        
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/chrome" || sudo mount --bind /run/chrome "$CHARD_ROOT/run/chrome" 
            sudo mountpoint -q "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" || sudo mount --bind "/home/chronos/user/MyFiles/Downloads" "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 
            sudo mount -o remount,rw,bind "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 
        else
            sudo mountpoint -q "$CHARD_ROOT/run/user/1000" || sudo mount --bind /run/user/1000 "$CHARD_ROOT/run/user/1000" 
        fi

        echo "export DBUS_SESSION_BUS_ADDRESS='$DBUS_SESSION_BUS_ADDRESS'" | sudo tee "$CHARD_ROOT/tmp/chard_dbus_session" >/dev/null
        sudo chmod 644 "$CHARD_ROOT/tmp/chard_dbus_session" 
        sudo nohup chroot "$CHARD_ROOT" /bin/bash -c "export DBUS_SESSION_BUS_ADDRESS='$DBUS_SESSION_BUS_ADDRESS'; /bin/chard_garcon" >/dev/null 2>&1 &
        
        sudo mountpoint -q "$CHARD_ROOT/run/dbus"   || sudo mount --bind /run/dbus "$CHARD_ROOT/run/dbus" 
        sudo mountpoint -q "$CHARD_ROOT/run/udev"   || sudo mount --bind /run/udev "$CHARD_ROOT/run/udev" 
        sudo mountpoint -q "$CHARD_ROOT/dev/dri"    || sudo mount --bind /dev/dri "$CHARD_ROOT/dev/dri" 
        sudo mountpoint -q "$CHARD_ROOT/dev/input"  || sudo mount --bind /dev/input "$CHARD_ROOT/dev/input" 
        
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/cras "$CHARD_ROOT/run/cras" 
        else
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/user/1000/pulse "$CHARD_ROOT/run/cras" 
        fi

        sudo mount --bind /etc/resolv.conf "$CHARD_ROOT/etc/resolv.conf" 
        sudo mount --bind /etc/hosts "$CHARD_ROOT/etc/hosts" 

        # Day's env
        sudo chroot "$CHARD_ROOT" env DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" /bin/bash -c '
            mountpoint -q /proc       || mount -t proc proc /proc 
            mountpoint -q /sys        || mount -t sysfs sys /sys 
            mountpoint -q /dev        || mount -t devtmpfs devtmpfs /dev 
            mountpoint -q /dev/shm    || mount -t tmpfs tmpfs /dev/shm 
            mountpoint -q /dev/pts    || mount -t devpts devpts /dev/pts 
            mountpoint -q /etc/ssl    || mount --bind /etc/ssl /etc/ssl 
            mountpoint -q /run/dbus   || mount --bind /run/dbus /run/dbus 
            mountpoint -q /run/udev   || mount --bind /run/udev /run/udev 
            mountpoint -q /run/chrome || mount --bind /run/chrome /run/chrome 
        
            if [ -e /dev/zram0 ]; then
                mount --rbind /dev/zram0 /dev/zram0 
                mount --make-rslave /dev/zram0 
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

            # Days XDG_RUNTIME_DIR setup (enhancement from v2)
            mkdir -p /tmp/chard_runtime
            chown 1000:1000 /tmp/chard_runtime
            chmod 700 /tmp/chard_runtime
            
            sudo -u "$USER" bash -c "
                sudo rm -f /run/chrome/pipewire-0.lock /run/chrome/pipewire-0-manager.lock 
                sudo rm -f /run/chrome/pulse/native /run/chrome/pulse/* 
                killall -9 pipewire 
                killall -9 pipewire-pulse 
                killall -9 pulseaudio 
                sudo chown -R 1000:audio /dev/snd 
                sudo chown -R 1000:1000 /dev/snd/by-path 
                sudo mkdir -p /run/chrome/pulse 
                sudo chown 1000:1000 /run/chrome/pulse 
                sudo chmod 770 /run/chrome/pulse 
                sudo setfacl -Rm u:1000:rwx /root 
                [ -f \"\$HOME/.bashrc\" ] && source \"\$HOME/.bashrc\" 
                [ -f \"\$HOME/.smrt_env.sh\" ] && source \"\$HOME/.smrt_env.sh\"
                cd ~/
                # Days xfce4-terminal
                QP_QPA_PLATFORM=xcb xfce4-terminal &
                exec chard_sommelier
                "
            
            setfacl -Rb /run/chrome/pulse 
            setfacl -Rb /run/chrome 
            killall -9 pipewire 
            killall -9 pipewire-pulse 
            killall -9 pulseaudio 
            killall -9 chardwire 
            sudo chown -R root:audio /dev/snd 
            sudo chown -R root:root /dev/snd/by-path 
            setfacl -Rb /root 
            umount -l /tmp/usb_mount  || true
            umount -l /dev/zram0    || true
            umount -l /run/chrome   || true
            umount -l /run/udev     || true
            umount -l /run/dbus     || true
            umount -l /etc/ssl      || true
            umount -l /dev/pts      || true
            umount -l /dev/shm      || true
            umount -l /dev          || true
            umount -l /sys          || true
            umount -l /proc         || true
        '
        killall -9 chard_volume 
        chard_unmount
        sudo rm -f /run/chrome/pulse/native
        sudo rm -f /run/chrome/pulse/*
        sudo mkdir -p /run/chrome/pulse
        sudo chown chronos:chronos /run/chrome/pulse
        sudo chmod 770 /run/chrome/pulse
        killall -9 cras_test_client 
        killall -9 pipewire 
        killall -9 pipewire-pulse 
        killall -9 pulseaudio 
        killall -9 steam 
        sudo pkill -f xfce4-session 
        sudo pkill -f xfwm4 
        sudo pkill -f xfce4-panel 
        sudo pkill -f xfdesktop 
        sudo pkill -f xfce4-terminal 
        sudo pkill -f xfce4-* 
        sudo pkill -f Xorg 
        ;;
    chariot)
        CLEANUP_ENABLED=1
        sudo mount --bind "$CHARD_ROOT" "$CHARD_ROOT"
        sudo mount --make-rslave "$CHARD_ROOT"
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/chrome" || sudo mount --bind /run/chrome "$CHARD_ROOT/run/chrome" 
            sudo mountpoint -q "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" || sudo mount --bind "/home/chronos/user/MyFiles/Downloads" "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 
            sudo mount -o remount,rw,bind "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 
        
        else
            sudo mountpoint -q "$CHARD_ROOT/run/user/1000" || sudo mount --bind /run/user/1000 "$CHARD_ROOT/run/user/1000" 
        fi
                
        sudo mountpoint -q "$CHARD_ROOT/run/dbus"   || sudo mount --bind /run/dbus "$CHARD_ROOT/run/dbus" 
        sudo mountpoint -q "$CHARD_ROOT/dev/dri"    || sudo mount --bind /dev/dri "$CHARD_ROOT/dev/dri" 
        sudo mountpoint -q "$CHARD_ROOT/dev/input"  || sudo mount --bind /dev/input "$CHARD_ROOT/dev/input" 
                
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/cras "$CHARD_ROOT/run/cras" 
        else
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/user/1000/pulse "$CHARD_ROOT/run/cras" 
        fi
        
        sudo mount --bind "$CHARD_ROOT" "$CHARD_ROOT"
        sudo mount --make-rslave "$CHARD_ROOT"
        
        sudo chroot "$CHARD_ROOT" /bin/bash -c '
            mountpoint -q /proc       || mount -t proc proc /proc 
            mountpoint -q /sys        || mount -t sysfs sys /sys 
            mountpoint -q /dev        || mount -t devtmpfs devtmpfs /dev 
            mountpoint -q /dev/shm    || mount -t tmpfs tmpfs /dev/shm 
            mountpoint -q /dev/pts    || mount -t devpts devpts /dev/pts 
            mountpoint -q /etc/ssl    || mount --bind /etc/ssl /etc/ssl 
            mountpoint -q /run/dbus   || mount --bind /run/dbus /run/dbus 
            mountpoint -q /run/chrome || mount --bind /run/chrome /run/chrome 
        
            if [ -e /dev/zram0 ]; then
                mount --rbind /dev/zram0 /dev/zram0 
                mount --make-rslave /dev/zram0 
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
                source \$HOME/.bashrc 
                sudo chown -R 1000:1000 $HOME
                cd \$HOME
                /bin/chariot
            "
        
            umount -l /dev/zram0    || true
            umount -l /run/chrome   || true
            umount -l /run/dbus     || true
            umount -l /etc/ssl      || true
            umount -l /dev/pts      || true
            umount -l /dev/shm      || true
            umount -l /dev          || true
            umount -l /sys          || true
            umount -l /proc         || true
        '
        
        chard_unmount
        ;;
    safe)
        CLEANUP_ENABLED=1
        sudo mount --bind "$CHARD_ROOT" "$CHARD_ROOT"
        sudo mount --make-rslave "$CHARD_ROOT"
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/chrome" || sudo mount --bind /run/chrome "$CHARD_ROOT/run/chrome" 
            sudo mountpoint -q "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" || sudo mount --bind "/home/chronos/user/MyFiles/Downloads" "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 
            sudo mount -o remount,rw,bind "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 
        else
            sudo mountpoint -q "$CHARD_ROOT/run/user/1000" || sudo mount --bind /run/user/1000 "$CHARD_ROOT/run/user/1000" 
        fi
        
        sudo mountpoint -q "$CHARD_ROOT/run/dbus"   || sudo mount --bind /run/dbus "$CHARD_ROOT/run/dbus" 
        sudo mountpoint -q "$CHARD_ROOT/dev/dri"    || sudo mount --bind /dev/dri "$CHARD_ROOT/dev/dri" 
        sudo mountpoint -q "$CHARD_ROOT/dev/input"  || sudo mount --bind /dev/input "$CHARD_ROOT/dev/input" 
        
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/cras "$CHARD_ROOT/run/cras" 
        else
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/user/1000/pulse "$CHARD_ROOT/run/cras" 
        fi
                
        sudo mountpoint -q "$CHARD_ROOT/run/dbus"   || sudo mount --bind /run/dbus "$CHARD_ROOT/run/dbus" 
        sudo mountpoint -q "$CHARD_ROOT/dev/dri"    || sudo mount --bind /dev/dri "$CHARD_ROOT/dev/dri" 
        sudo mountpoint -q "$CHARD_ROOT/dev/input"  || sudo mount --bind /dev/input "$CHARD_ROOT/dev/input" 
                
        if [ -f "/home/chronos/user/.bashrc" ]; then
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/cras "$CHARD_ROOT/run/cras" 
        else
            sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/user/1000/pulse "$CHARD_ROOT/run/cras" 
        fi
        
        sudo chroot "$CHARD_ROOT" /bin/bash -c "

            mountpoint -q /proc       || mount -t proc proc /proc 
            mountpoint -q /sys        || mount -t sysfs sys /sys 
            mountpoint -q /dev        || mount -t devtmpfs devtmpfs /dev 
            mountpoint -q /dev/shm    || mount -t tmpfs tmpfs /dev/shm 
            mountpoint -q /dev/pts    || mount -t devpts devpts /dev/pts 
            mountpoint -q /etc/ssl    || mount --bind /etc/ssl /etc/ssl 
            mountpoint -q /run/dbus   || mount --bind /run/dbus /run/dbus 
            mountpoint -q /run/chrome || mount --bind /run/chrome /run/chrome 
        
            if [ -e /dev/zram0 ]; then
                mount --rbind /dev/zram0 /dev/zram0 
                mount --make-rslave /dev/zram0 
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
            source \$HOME/.bashrc         
            /bin/bash
            umount -l /dev/zram0    || true
            umount -l /run/chrome   || true
            umount -l /run/dbus     || true
            umount -l /etc/ssl      || true
            umount -l /dev/pts      || true
            umount -l /dev/shm      || true
            umount -l /dev          || true
            umount -l /sys          || true
            umount -l /proc         || true
        "
        
        chard_unmount
        ;;
    version)
        # Denny's version checker
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
