
#!/bin/bash
# Chard Reinstaller
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

 echo "${RESET}${GREEN}"
        echo "[1] Quick Reinstall (Update Chard)"
        echo "${RESET}${YELLOW}[2] Full Reinstall (Run Chard Installer)"
        echo "${RESET}${RED}[q] Cancel"
        echo "${RESET}${GREEN}"
        read -p "Choose an option [1/2/q]: " choice
        
        case "$choice" in
            1)
                echo
                echo "${RESET}${GREEN}[*] Performing Quick Reinstall!"

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


echo "${CYAN}[*] Downloading Chard components...${RESET}"
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/.chardrc"           -o "$CHARD_ROOT/.chardrc" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/.chard.env"         -o "$CHARD_ROOT/.chard.env" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/Reinstall_Chard.sh" -o "$CHARD_ROOT/bin/Reinstall_Chard.sh" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/Uninstall_Chard.sh"  -o "$CHARD_ROOT/bin/Uninstall_Chard.sh" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/chard.sh"           -o "$CHARD_ROOT/bin/chard" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/.bashrc"            -o "$CHARD_ROOT/$CHARD_HOME/.bashrc" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_version"       -o "$CHARD_ROOT/bin/chard_version" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/LICENSE"                 -o "$CHARD_ROOT/$CHARD_HOME/CHARD_LICENSE" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/.rootrc"            -o "$CHARD_ROOT/bin/.rootrc" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/chariot.sh"         -o "$CHARD_ROOT/bin/chariot" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_debug.sh"      -o "$CHARD_ROOT/bin/chard_debug" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/chard_sommelier.sh" -o "$CHARD_ROOT/bin/chard_sommelier" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_scale.sh"      -o "$CHARD_ROOT/bin/chard_scale" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/wx"                  -o "$CHARD_ROOT/bin/wx" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/SMRT.sh"            -o "$CHARD_ROOT/bin/SMRT" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_mount"         -o "$CHARD_ROOT/bin/chard_mount" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_unmount"       -o "$CHARD_ROOT/bin/chard_unmount" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/chardsetup.sh"      -o "$CHARD_ROOT/bin/chardsetup" 2>/dev/null
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/root.sh"            -o "$CHARD_ROOT/bin/root" 2>/dev/null
sleep 0.2

sudo chmod +x "$CHARD_ROOT/bin/chard"
sudo chmod +x "$CHARD_ROOT/bin/chariot"
sudo chmod +x "$CHARD_ROOT/bin/.rootrc"
sudo chmod +x "$CHARD_ROOT/bin/chard_debug"
sudo chmod +x "$CHARD_ROOT/bin/Reinstall_Chard.sh"
sudo chmod +x "$CHARD_ROOT/bin/Uninstall_Chard.sh"
sudo chmod +x "$CHARD_ROOT/bin/chard_sommelier"
sudo chmod +x "$CHARD_ROOT/bin/chard_scale"
sudo chmod +x "$CHARD_ROOT/bin/wx"
sudo chmod +x "$CHARD_ROOT/bin/SMRT"
sudo chmod +x "$CHARD_ROOT/bin/chard_mount"
sudo chmod +x "$CHARD_ROOT/bin/chard_unmount"
sudo chmod +x "$CHARD_ROOT/bin/chardsetup"
sudo chmod +x "$CHARD_ROOT/bin/root"

for file in \
    "$CHARD_ROOT/.chardrc" \
    "$CHARD_ROOT/.chard.env" \
    "$CHARD_ROOT/$CHARD_HOME/.bashrc" \
    "$CHARD_ROOT/bin/.rootrc" \
    "$CHARD_ROOT/bin/chariot" \
    "$CHARD_ROOT/bin/chard_debug" \
    "$CHARD_ROOT/bin/SMRT" \
    "$CHARD_ROOT/bin/chardsetup" \
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
        echo "${RED}[!] Missing: $file ${RESET}"
    fi
done

sudo mv "$CHARD_ROOT/bin/.rootrc" "$CHARD_ROOT/.bashrc"

CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
DEFAULT_BASHRC="$HOME/.bashrc"
TARGET_FILE=""
        
if [ -f "$CHROMEOS_BASHRC" ]; then
    TARGET_FILE="$CHROMEOS_BASHRC"
    CHROME_MILESTONE=$(grep '^CHROMEOS_RELEASE_CHROME_MILESTONE=' /etc/lsb-release | cut -d'=' -f2)
    echo "$CHROME_MILESTONE" | sudo tee "$CHARD_ROOT/.chard_chrome" > /dev/null
elif [ -f "$DEFAULT_BASHRC" ]; then
    TARGET_FILE="$DEFAULT_BASHRC"
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
        echo
    else
        echo "${YELLOW}[!] Chard already sourced in $FILE"
        echo
    fi
}

add_chard_marker "$TARGET_FILE"

if grep -q "CHROMEOS_RELEASE" /etc/lsb-release 2>/dev/null; then
    XDG_RUNTIME_VALUE='export XDG_RUNTIME_DIR="$ROOT/run/chrome"'
else
    XDG_RUNTIME_VALUE='export XDG_RUNTIME_DIR="$ROOT/run/user/1000"'
fi

sudo sed -i "/# <<< CHARD_XDG_RUNTIME_DIR >>>/,/# <<< END CHARD_XDG_RUNTIME_DIR >>>/c\
# <<< CHARD_XDG_RUNTIME_DIR >>>\n${XDG_RUNTIME_VALUE}\n# <<< END CHARD_XDG_RUNTIME_DIR >>>" \
"$CHARD_ROOT/$CHARD_HOME/.bashrc"

sudo sed -i "/# <<< CHARD_XDG_RUNTIME_DIR >>>/,/# <<< END CHARD_XDG_RUNTIME_DIR >>>/c\
# <<< CHARD_XDG_RUNTIME_DIR >>>\n${XDG_RUNTIME_VALUE}\n# <<< END CHARD_XDG_RUNTIME_DIR >>>" \
"$CHARD_ROOT/bin/chard_sommelier"

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
PS1="\${BOLD}\${RED}\\u\${BOLD}\${YELLOW}@\${BOLD}\${GREEN}$BOARD_NAME\${RESET} \\w # "
export PS1
EOF

sudo chmod +x "$CHARD_ROOT/usr/.chard_prompt.sh"
if ! grep -q '/usr/.chard_prompt.sh' "$CHARD_ROOT/$CHARD_HOME/.bashrc" 2>/dev/null; then
    sudo tee -a "$CHARD_ROOT/$CHARD_HOME/.bashrc" > /dev/null <<'EOF'
source /usr/.chard_prompt.sh
EOF
fi

sudo chown 1000:1000 "$CHARD_ROOT/usr/.chard_prompt.sh" 
sudo chown 1000:1000 $CHARD_ROOT/$CHARD_HOME/.bashrc   

sudo tee "$CHARD_ROOT/bin/chard_flatpak" >/dev/null <<'EOF'
#!/bin/bash
export PATH=/usr/local/bubblepatch/bin:$PATH
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
USER_ID=1000
GROUP_ID=1000
export STEAM_USER_HOME="$HOME/.local/share/Steam"
source ~/.bashrc
xhost +SI:localuser:root
sudo setfacl -Rm u:root:rwx /run/chrome 2>/dev/null
sudo setfacl -Rm u:1000:rwx /run/chrome 2>/dev/null
sudo -i /usr/bin/env bash -c 'exec /usr/bin/flatpak "$@"' _ "$@"
sudo setfacl -Rb /run/chrome 2>/dev/null
EOF
sudo chmod +x "$CHARD_ROOT/bin/chard_flatpak"

sudo tee "$CHARD_ROOT/bin/chard_steam" >/dev/null <<'EOF'
#!/bin/bash
export PATH=/usr/local/bubblepatch/bin:$PATH
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
STEAM_USER_HOME=$CHARD_HOME/.local/share/Steam
xhost +SI:localuser:$USER
sudo setfacl -Rm u:$USER:rwx /run/chrome 2>/dev/null
sudo setfacl -Rm u:root:rwx /run/chrome 2>/dev/null
/usr/bin/steam
sudo setfacl -Rb /run/chrome 2>/dev/null
EOF
sudo chmod +x "$CHARD_ROOT/bin/chard_steam"

sudo tee "$CHARD_ROOT/bin/chard_prismlauncher" >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
HOME=/$CHARD_HOME
USER=$CHARD_USER
source ~/.bashrc
export QT_QPA_PLATFORM=xcb
export ALSOFT_DRIVERS=alsa
/usr/bin/prismlauncher "$@" &
EOF
sudo chmod +x "$CHARD_ROOT/bin/chard_prismlauncher"

sudo tee "$CHARD_ROOT/bin/chard_firefox" >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
HOME=/$CHARD_HOME
USER=$CHARD_USER
PATH=/usr/local/bubblepatch/bin:$PATH
xhost +SI:localuser:root
source ~/.bashrc
sudo -u $CHARD_USER /usr/bin/firefox
EOF
sudo chmod +x "$CHARD_ROOT/bin/chard_firefox"

ARCH="$(uname -m)"
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    sudo tee "$CHARD_ROOT/etc/asound.conf" 2>/dev/null << 'EOF'
#Route all audio through the CRAS plugin.
pcm.!default {
        type cras
}
ctl.!default {
        type cras
}
EOF
    echo
else
   echo "${BLUE}Setting up Pipewire..."
   echo

sudo tee "$CHARD_ROOT/etc/pipewire/pipewire.conf.d/crostini-audio.conf" 2>/dev/null << 'EOF'
context.objects = [
    { factory = adapter
      args = {
        factory.name           = api.alsa.pcm.sink
        node.name              = "Virtio Soundcard Sink"
        media.class            = "Audio/Sink"
        api.alsa.path          = "hw:0,0"
        audio.channels         = 2
        audio.position         = "FL,FR"
      }
    }
    { factory = adapter
      args = {
        factory.name           = api.alsa.pcm.source
        node.name              = "Virtio Soundcard Source"
        media.class            = "Audio/Source"
        api.alsa.path          = "hw:0,1"
        audio.channels         = 2
        audio.position         = "FL,FR"
      }
    }
]
EOF

sudo tee "$CHARD_ROOT/etc/asound.conf" 2>/dev/null << 'EOF'
pcm.!default {
        type pipewire
}
ctl.!default {
        type pipewire
}
EOF
                if [ -f "/home/chronos/user/.bashrc" ]; then
                    sudo mountpoint -q "$CHARD_ROOT/run/chrome" || sudo mount --bind /run/chrome "$CHARD_ROOT/run/chrome" 2>/dev/null
                    sudo mountpoint -q "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" || sudo mount --bind "/home/chronos/user/MyFiles/Downloads" "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null
                    sudo mount -o remount,rw,bind "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads"
                
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
                        source \$HOME/.bashrc 2>/dev/null
                        sudo chown -R 1000:1000 $HOME
                        cd \$HOME
                        sudo rm /etc/pipewire/pipewire.conf.d/crostini-audio.conf 2>/dev/null
                        sudo -E pacman -R --noconfirm cros-container-guest-tools-git 2>/dev/null
                        sudo -E pacman -R --noconfirm pulseaudio 2>/dev/null
                        rm -rf ~/.config/pulse 2>/dev/null
                        rm -rf ~/.pulse 2>/dev/null
                        rm -rf ~/.cache/pulse 2>/dev/null
                        sudo -E pacman -Syu --noconfirm pipewire-pulse 2>/dev/null
                        sudo rm -f /run/chrome/pipewire-0.lock /run/chrome/pipewire-0-manager.lock
                        sudo rm -f /run/chrome/pulse/native /run/chrome/pulse/*
                    "

                    killall -9 pipewire 2>/dev/null
                    killall -9 pipewire-pulse 2>/dev/null
                    killall -9 pulseaudio 2>/dev/null
                    killall -9 wireplumber 2>/dev/null
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
                sudo rm -f /run/chrome/pipewire-0.lock /run/chrome/pipewire-0-manager.lock
                sudo rm -f /run/chrome/pulse/native /run/chrome/pulse/*
            fi

                echo "${MAGENTA}[*] Quick Reinstall complete.${RESET}"
                echo
                ;;
            2)
                echo "${RESET}${YELLOW}[*] Performing full reinstall..."
                bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_download?$(date +%s)")
                ;;
            q|Q|*)
                echo "${RESET}${RED}[*] Reinstall cancelled.${RESET}"
                ;;
         esac
