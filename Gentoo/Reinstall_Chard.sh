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
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/udev"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/dbus"   2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/chrome" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/etc/ssl"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/pts"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/shm"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev"        2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/sys"        2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/proc"       2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/user/1000" 2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"               2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/cras"   2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/udev"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/dbus"   2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/chrome" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/etc/ssl"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/pts"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev/shm"    2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/dev"        2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/sys"        2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/proc"       2>/dev/null || true
        sleep 0.05
        $CHARD_ROOT/bin/chard_unmount 2>/dev/null
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/user/1000" 2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"               2>/dev/null || true
        sleep 0.05
        sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT" 2>/dev/null || true
        sleep 0.05
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
                chard_unmount() {
                    echo
                    echo "${YELLOW}Chard is unmounting... ${RESET}"
                    sudo umount -l "$CHARD_ROOT/run/cras"   2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/run/dbus"   2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/run/chrome" 2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/etc/ssl"    2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/dev/pts"    2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/dev/shm"    2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/dev"        2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/sys"        2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/proc"       2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/run/user/1000" 2>/dev/null || true
                    sleep 0.05
                    sudo umount -l -f "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null || true
                    sleep 0.05
                    sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"               2>/dev/null || true
                    sleep 0.05
                    sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT" 2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/run/cras"   2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/run/dbus"   2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/run/chrome" 2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/etc/ssl"    2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/dev/pts"    2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/dev/shm"    2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/dev"        2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/sys"        2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/proc"       2>/dev/null || true
                    sleep 0.05
                    $CHARD_ROOT/bin/chard_unmount 2>/dev/null
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT/run/user/1000" 2>/dev/null || true
                    sleep 0.05
                    sudo umount -l -f "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null || true
                    sleep 0.05
                    sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"               2>/dev/null || true
                    sleep 0.05
                    sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null || true
                    sleep 0.05
                    sudo umount -l "$CHARD_ROOT" 2>/dev/null || true
                    sleep 0.05
                    sudo setfacl -Rb /run/chrome 2>/dev/null
                    echo "${RESET}${GREEN}Chard safely unmounted${RESET}"
                    echo
                }
                chard_unmount
                echo "${RESET}${GREEN}[*] Performing quick reinstall..."
                CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
                DEFAULT_BASHRC="$HOME/.bashrc"
                TARGET_FILE=""
                if [ -f "$CHROMEOS_BASHRC" ]; then
                    TARGET_FILE="$CHROMEOS_BASHRC"
                    sudo mkdir -p "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads"
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

                sudo chroot $CHARD_ROOT /bin/bash -c "

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
                        
                        CHARD_USER=\$(cat /.chard_user)
                        CHARD_HOME=\$(cat /.chard_home)
                        USER=\$CHARD_USER
                        HOME=\$CHARD_HOME
                        source \$HOME/.bashrc 2>/dev/null
                        source \$HOME/.smrt_env.sh

                        mkdir -p \"/\$CHARD_HOME\"
                        chown -R \$USER:\$USER \"/\$CHARD_HOME\" 2>/dev/null        
                        mkdir -p /etc/sudoers.d
                        chown root:root /etc/sudoers.d 2>/dev/null
                        chmod 755 /etc/sudoers.d
                        chown root:root /etc/sudoers.d/\$USER 2>/dev/null
                        chmod 440 /etc/sudoers.d/\$USER
                        chown root:root /usr/bin/sudo 2>/dev/null
                        chmod 4755 /usr/bin/sudo
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
                
                echo "$CHARD_USER ALL=(ALL) NOPASSWD: ALL" | sudo tee "$CHARD_ROOT/etc/sudoers.d/$CHARD_USER" > /dev/null
                CHARD_HOME="$(dirname "$TARGET_FILE")"
                CHARD_HOME="${CHARD_HOME#/}"
                
                if [[ "$CHARD_HOME" == home/* ]]; then
                    CHARD_HOME="${CHARD_HOME%%/user*}"
                
                    CHARD_USER="${CHARD_HOME#*/}"
                fi
                
                sudo mkdir -p "$CHARD_ROOT/$CHARD_HOME"
                echo ""
                echo "${BLUE}[*] Downloading Chard components..."
                
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/.chardrc"            -o "$CHARD_ROOT/.chardrc"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/.chard.env"          -o "$CHARD_ROOT/.chard.env"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/.chard.logic"        -o "$CHARD_ROOT/.chard.logic"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/.chard.preload"      -o "$CHARD_ROOT/.chard.preload"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/Uninstall_Chard.sh"  -o "$CHARD_ROOT/bin/Uninstall_Chard.sh"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/SMRT.sh"             -o "$CHARD_ROOT/bin/SMRT"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/chard.sh"            -o "$CHARD_ROOT/bin/chard"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/.bashrc"             -o "$CHARD_ROOT/$CHARD_HOME/.bashrc"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_version"       -o "$CHARD_ROOT/$CHARD_HOME/chard_version"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/LICENSE"             -o "$CHARD_ROOT/$CHARD_HOME/CHARD_LICENSE"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/.rootrc"             -o "$CHARD_ROOT/bin/.rootrc"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/chariot.sh"          -o "$CHARD_ROOT/bin/chariot"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_debug.sh"      -o "$CHARD_ROOT/bin/chard_debug"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/chard_sommelier.sh"  -o "$CHARD_ROOT/bin/chard_sommelier"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_scale.sh"      -o "$CHARD_ROOT/bin/chard_scale"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/wx"                  -o "$CHARD_ROOT/bin/wx"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_mount"         -o "$CHARD_ROOT/bin/chard_mount"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_unmount"         -o "$CHARD_ROOT/bin/chard_unmount"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/chardonnay.sh"         -o "$CHARD_ROOT/bin/chardonnay"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_preload.sh"         -o "$CHARD_ROOT/bin/chard_preload"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chardwire.sh"         -o "$CHARD_ROOT/bin/chardwire"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_volume.sh"         -o "$CHARD_ROOT/bin/chard_volume"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_stage3_preload.sh"         -o "$CHARD_ROOT/bin/chard_stage3_preload"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/rainbow.sh"         -o "$CHARD_ROOT/bin/rainbow"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/error_color.sh"         -o "$CHARD_ROOT/bin/error_color"
                sleep 0.05
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/color_reset.sh"         -o "$CHARD_ROOT/bin/color_reset"
                sleep 0.05
                
                sudo chmod +x "$CHARD_ROOT/bin/SMRT"
                sudo chmod +x "$CHARD_ROOT/bin/chard"
                sudo chmod +x "$CHARD_ROOT/bin/chariot"
                sudo chmod +x "$CHARD_ROOT/bin/.rootrc"
                sudo chmod +x "$CHARD_ROOT/bin/chard_debug"
                sudo chmod +x "$CHARD_ROOT/bin/Uninstall_Chard.sh"
                sudo chmod +x "$CHARD_ROOT/bin/chard_sommelier"
                sudo chmod +x "$CHARD_ROOT/bin/chard_scale"
                sudo chmod +x "$CHARD_ROOT/bin/wx"
                sudo chmod +x "$CHARD_ROOT/bin/chard_mount"
                sudo chmod +x "$CHARD_ROOT/bin/chard_unmount"
                sudo chmod +x "$CHARD_ROOT/bin/chardonnay"
                sudo chmod +x "$CHARD_ROOT/bin/chard_preload"
                sudo chmod +x "$CHARD_ROOT/bin/chardwire"
                sudo chmod +x "$CHARD_ROOT/bin/chard_volume"
                sudo chmod +x "$CHARD_ROOT/bin/chard_stage3_preload"
                sudo chmod +x "$CHARD_ROOT/bin/rainbow"
                sudo chmod +x "$CHARD_ROOT/bin/error_color"
                sudo chmod +x "$CHARD_ROOT/bin/color_reset"
                
                for file in \
                "$CHARD_ROOT/.chardrc" \
                "$CHARD_ROOT/.chard.env" \
                "$CHARD_ROOT/.chard.logic" \
                "$CHARD_ROOT/.chard.preload" \
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
                CHARD_RC="$CHARD_ROOT/.chardrc"
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
                        echo
                    else
                        echo "${YELLOW}[!] Chard already sourced in $FILE"
                        echo
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
PS1="\${BOLD}\${RED}\\u\${BOLD}\${YELLOW}@\${BOLD}\${GREEN}$BOARD_NAME\${RESET} \\w # "
export PS1
EOF

                sudo chmod +x "$CHARD_ROOT/usr/.chard_prompt.sh"
                if ! grep -q '/usr/.chard_prompt.sh' "$CHARD_ROOT/$CHARD_HOME/.bashrc" 2>/dev/null; then
                    sudo tee -a "$CHARD_ROOT/$CHARD_HOME/.bashrc" > /dev/null <<'EOF'
source /usr/.chard_prompt.sh
EOF
                fi

                sudo chown 1000:1000 "$CHARD_ROOT/usr/.chard_prompt.sh" 2>/dev/null

                sudo chroot $CHARD_ROOT /bin/bash -c "

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
                
                    mkdir -p /var/db/pkg /var/lib/portage
                    CHARD_HOME=\$(cat /.chard_home)
                    CHARD_USER=\$(cat /.chard_user)
                    HOME=\$CHARD_HOME
                    USER=\$CHARD_USER
                    source \$HOME/.bashrc 2>/dev/null
                    chown -R portage:portage /var/db/pkg /var/lib/portage 2>/dev/null
                    chmod -R 755 /var/db/pkg 2>/dev/null
                    chmod 644 /var/lib/portage/world 2>/dev/null
                    /bin/SMRT 2>/dev/null
                    source \$HOME/.smrt_env.sh 2>/dev/null
                    sudo chown -R \$USER:\$USER \$HOME 2>/dev/null
                    emerge --noreplace app-misc/resolve-march-native && \
                    MARCH_FLAGS=\$(resolve-march-native | sed 's/+crc//g; s/+crypto//g') && \
                    BASHRC=\"\$HOME/.bashrc\" && \
                    awk -v march=\"\$MARCH_FLAGS\" '
                        /^# <<< CHARD_MARCH_NATIVE >>>$/ {inblock=1; print; next}
                        /^# <<< END CHARD_MARCH_NATIVE >>>$/ {inblock=0; print; next}
                        inblock {
                            if (\$0 ~ /^CFLAGS=/) { print \"CFLAGS=\\\"\" march \" -O2 -pipe\\\"\"; next }
                            if (\$0 ~ /^COMMON_FLAGS=/) {
                                print \"COMMON_FLAGS=\\\"\" march \" -O2 -pipe\\\"\"
                                print \"FCFLAGS=\\\"\$COMMON_FLAGS\\\"\"
                                print \"FFLAGS=\\\"\$COMMON_FLAGS\\\"\"
                                print \"CXXFLAGS=\\\"\$CFLAGS\\\"\"
                                next
                            }
                            next
                        }
                        {print}
                    ' \"\$BASHRC\" > \"\$BASHRC.tmp\" && mv \"\$BASHRC.tmp\" \"\$BASHRC\"
                
                    umount -l /run/chrome  2>/dev/null || true
                    umount -l /run/dbus    2>/dev/null || true
                    umount -l /etc/ssl     2>/dev/null || true
                    umount -l /dev/pts     2>/dev/null || true
                    umount -l /dev/shm     2>/dev/null || true
                    umount -l /dev         2>/dev/null || true
                    umount -l /sys         2>/dev/null || true
                    umount -l /proc        2>/dev/null || true
                "
                echo "${RESET} ${GREEN}"
                detect_gpu_freq() {
                GPU_FREQ_PATH=""
                GPU_MAX_FREQ=""
                GPU_TYPE="unknown"
            
                if [ -f "/sys/class/drm/card0/gt_max_freq_mhz" ]; then
                    GPU_FREQ_PATH="/sys/class/drm/card0/gt_max_freq_mhz"
                    GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
                    GPU_TYPE="intel"
                    echo "[*] Detected Intel GPU: max freq ${GPU_MAX_FREQ} MHz"
                    return
                fi
            
                if [ -f "/sys/class/drm/card0/device/pp_dpm_sclk" ]; then
                    GPU_TYPE="nvidia"
                    PP_DPM_SCLK="/sys/class/drm/card0/device/pp_dpm_sclk"
                    MAX_MHZ=$(grep -o '[0-9]\+' "$PP_DPM_SCLK" | sort -nr | head -n1)
                    GPU_MAX_FREQ="$MAX_MHZ"
                    GPU_FREQ_PATH="$PP_DPM_SCLK"
                    echo "[*] Detected NVIDIA GPU: max freq ${GPU_MAX_FREQ} MHz"
                    return
                fi
            
                if [ -f "/sys/class/drm/card0/device/pp_od_clk_voltage" ]; then
                    GPU_TYPE="amd"
                    PP_OD_FILE="/sys/class/drm/card0/device/pp_od_clk_voltage"
                    mapfile -t SCLK_LINES < <(grep -i '^sclk' "$PP_OD_FILE")
                    if [[ ${#SCLK_LINES[@]} -gt 0 ]]; then
                        MAX_MHZ=$(printf '%s\n' "${SCLK_LINES[@]}" | sed -n 's/.*\([0-9]\{1,\}\)[Mm][Hh][Zz].*/\1/p' | sort -nr | head -n1)
                        GPU_MAX_FREQ="$MAX_MHZ"
                    fi
                    GPU_FREQ_PATH="$PP_OD_FILE"
                    echo "[*] Detected AMD GPU: max freq ${GPU_MAX_FREQ} MHz"
                    return
                fi
            
                if [[ -d /sys/class/drm ]]; then
                    if grep -qi "mediatek" /sys/class/drm/*/device/uevent 2>/dev/null; then
                        GPU_TYPE="mediatek"
                        echo "[*] Detected MediaTek GPU"
                        return
                    elif grep -qi "vivante" /sys/class/drm/*/device/uevent 2>/dev/null; then
                        GPU_TYPE="vivante"
                        echo "[*] Detected Vivante GPU"
                        return
                    elif grep -qi "asahi" /sys/class/drm/*/device/uevent 2>/dev/null; then
                        GPU_TYPE="asahi"
                        echo "[*] Detected Asahi GPU"
                        return
                    elif grep -qi "panfrost" /sys/class/drm/*/device/uevent 2>/dev/null; then
                        GPU_TYPE="mali"
                        echo "[*] Detected Mali/Panfrost GPU"
                        return
                    fi
                fi
            
                for d in /sys/class/devfreq/*; do
                    if grep -qi 'mali' <<< "$d" || grep -qi 'gpu' <<< "$d"; then
                        if [ -f "$d/max_freq" ]; then
                            GPU_FREQ_PATH="$d/max_freq"
                            GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
                            GPU_TYPE="mali"
                            echo "[*] Detected Mali GPU via devfreq: max freq ${GPU_MAX_FREQ} Hz"
                            return
                        elif [ -f "$d/available_frequencies" ]; then
                            GPU_FREQ_PATH="$d/available_frequencies"
                            GPU_MAX_FREQ=$(tr ' ' '\n' < "$GPU_FREQ_PATH" | sort -nr | head -n1)
                            GPU_TYPE="mali"
                            echo "[*] Detected Mali GPU via devfreq: max freq ${GPU_MAX_FREQ} Hz"
                            return
                        fi
                    fi
                done
            
                if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
                    if [ -f "/sys/class/kgsl/kgsl-3d0/max_gpuclk" ]; then
                        GPU_FREQ_PATH="/sys/class/kgsl/kgsl-3d0/max_gpuclk"
                        GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
                        GPU_TYPE="adreno"
                        echo "[*] Detected Adreno GPU: max freq ${GPU_MAX_FREQ} Hz"
                        return
                    elif [ -f "/sys/class/kgsl/kgsl-3d0/gpuclk" ]; then
                        GPU_FREQ_PATH="/sys/class/kgsl/kgsl-3d0/gpuclk"
                        GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
                        GPU_TYPE="adreno"
                        echo "[*] Detected Adreno GPU: max freq ${GPU_MAX_FREQ} Hz"
                        return
                    fi
                fi
            
                echo "[*] No GPU detected, using unknown"
                GPU_TYPE="unknown"
            }
            
            ARCH=$(uname -m)
            MAKECONF_DIR="$CHARD_ROOT/etc/portage"
            MAKECONF_FILE="$MAKECONF_DIR/make.conf"
            sudo mkdir -p "$MAKECONF_DIR"
            
            case "$ARCH" in
                x86_64)
                    CHOST="x86_64-pc-linux-gnu"
                    ACCEPT_KEYWORDS="~amd64"
                    ;;
                aarch64)
                    CHOST="aarch64-unknown-linux-gnu"
                    ACCEPT_KEYWORDS="~arm64"
                    ;;
                *)
                    echo "Unknown architecture: $ARCH"
                    exit 1
                    ;;
            esac
            
            detect_gpu_freq
            
            case "$GPU_TYPE" in
                intel)
                    VIDEO_CARDS="intel iris"
                    ;;
                amd)
                    VIDEO_CARDS="radeonsi"
                    ;;
                nvidia)
                    VIDEO_CARDS="nouveau nvk"
                    ;;
                mali)
                    VIDEO_CARDS="panfrost lima"
                    ;;
                adreno)
                    VIDEO_CARDS="freedreno"
                    ;;
                mediatek)
                    VIDEO_CARDS="panfrost lima"
                    ;;
                vivante)
                    VIDEO_CARDS="etnaviv"
                    ;;
                asahi)
                    VIDEO_CARDS="asahi"
                    ;;
                *)
                    VIDEO_CARDS="lavapipe virgl"
                    ;;
            esac
            
                USE_FLAGS="X a52 aac acl acpi alsa bindist -bluetooth branding bzip2 cairo cdda cdr cet crypt cube curl dbus dri dri3 dts encode exif egl flac gdbm gif gpm gtk gtk3 gui iconv icu introspection ipv6 jpeg jit kms layers lcms libnotify libtirpc llvm mad minizip mng multilib mp3 mp4 mpeg ncurses nls ogg opengl openmp opus pam pango pcre pdf png postproc ppds proprietary-codecs pulseaudio qml qt5 qt6 readline sdl seccomp sound -sound-server spell spirv ssl startup-notification svg tiff truetype udev -udisks unicode -upower usb -utils vorbis wayland wxwidgets x264 x265 xattr xcb xft xml xv xvid zlib python_targets_python3_13 systemd vpx zstd -elogind"
                
                case "$GPU_TYPE" in
                    amd|nvidia)
                        USE_FLAGS+=" vaapi vdpau vulkan"
                        ;;
                    intel)
                        USE_FLAGS+=" video_cards_intel vulkan"
                        ;;
                    mediatek)
                        USE_FLAGS+=" virgl vulkan"
                esac

sudo tee "$MAKECONF_FILE" > /dev/null <<EOF
# Chard Portage make.conf
# Generated based on detected architecture ($ARCH) and GPU type ($GPU_TYPE)
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="\${COMMON_FLAGS}"
CXXFLAGS="\${COMMON_FLAGS}"
FCFLAGS="\${COMMON_FLAGS}"
FFLAGS="\${COMMON_FLAGS}"
LC_MESSAGES=C.utf8
DISTDIR="/var/cache/distfiles"
PKGDIR="/var/cache/packages"
PORTAGE_TMPDIR="/var/tmp"
PORTDIR="/usr/portage"
SANDBOX="/usr/bin/sandbox"
CHOST="$CHOST"
CC="/usr/bin/gcc"
CXX="/usr/bin/g++"
AR="/usr/bin/gcc-ar"
RANLIB="/usr/bin/gcc-ranlib"
STRIP="/usr/bin/strip"
FEATURES="assume-digests binpkg-docompress binpkg-dostrip binpkg-logs config-protect-if-modified distlocks ebuild-locks fixlafiles merge-sync multilib-strict news parallel-fetch parallel-install pid-sandbox preserve-libs protect-owned strict unknown-features-warn unmerge-logs unmerge-orphans userfetch usersync xattr -sandbox -usersandbox"
USE="$USE_FLAGS"
PYTHON_TARGETS="python3_13"
ACCEPT_KEYWORDS="$ACCEPT_KEYWORDS"
VIDEO_CARDS="$VIDEO_CARDS"
PKG_CONFIG="/usr/bin/pkg-config"
MESON_NATIVE_FILE="/meson-cross.ini"
PYTHONMULTIPROCESSING_START_METHOD=fork
EOF

                echo ""
                echo "${RESET}${BLUE}make.conf generated successfully for $GPU_TYPE + $ARCH -> $MAKECONF_FILE "
                echo ""
    
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

                sudo sed -i "/# <<< CHARD_XDG_RUNTIME_DIR >>>/,/# <<< END CHARD_XDG_RUNTIME_DIR >>>/c\
                # <<< CHARD_XDG_RUNTIME_DIR >>>\n${XDG_RUNTIME_VALUE}\n# <<< END CHARD_XDG_RUNTIME_DIR >>>" \
                "$CHARD_ROOT/bin/chard_sommelier"
            

if [ -f "/home/chronos/user/.bashrc" ]; then
        CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
        BASHRC_PATH="$CHROMEOS_BASHRC"
        IS_CHROMEOS=1
else
    DEFAULT_BASHRC="$HOME/.bashrc"
    BASHRC_PATH="$DEFAULT_BASHRC"
    IS_CHROMEOS=0
fi

if [ "$IS_CHROMEOS" -eq 1 ]; then
    sudo tee "$CHARD_ROOT/etc/asound.conf" 2>/dev/null << 'EOF'
pcm.!default {
        type cras
}
ctl.!default {
        type cras
}
EOF
else
sudo tee "$CHARD_ROOT/etc/asound.conf" 2>/dev/null << 'EOF'
pcm.!default {
        type pipewire
}
ctl.!default {
        type pipewire
}
EOF
echo
fi

sudo mkdir -p $CHARD_ROOT/etc/pulse/default.pa.d/
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/daemon.conf"  -o "$CHARD_ROOT/etc/pulse/daemon.conf"
sudo mkdir -p $CHARD_ROOT/etc/pulse/default.pa.d/
sudo mkdir -p $CHARD_ROOT/etc/pulse/

sudo tee $CHARD_ROOT/etc/pulse/default.pa.d/10-cras.pa > /dev/null << 'EOF'
load-module module-alsa-sink device=default sink_name=cras_sink
set-default-sink cras_sink
EOF

sudo tee $CHARD_ROOT/etc/pulse/default.pa.d/99-disable-hw.pa > /dev/null << 'EOF'
unload-module module-udev-detect
unload-module module-alsa-card
EOF

sudo cp $CHARD_ROOT/etc/pulse/daemon.conf $CHARD_ROOT/etc/pulse/daemon.conf.bak.$(date +%s) 2>/dev/null
sudo sed -i \
    -e 's/^[#[:space:]]*avoid-resampling[[:space:]]*=.*/avoid-resampling = true/' \
    -e 's/^[#[:space:]]*flat-volumes[[:space:]]*=.*/flat-volumes = no/' \
    "$CHARD_ROOT/etc/pulse/daemon.conf"

sudo cp $CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa $CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa.bak.$(date +%s) 2>/dev/null
grep -qxF ".include /etc/pulse/default.pa" "$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa" 2>/dev/null || \
( sed '/^\.fail$/a\.include /etc/pulse/default.pa' "$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa" 2>/dev/null > "$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa.tmp" && \
mv "$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa.tmp" "$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa" )
sudo mkdir -p /media

                
                sudo chown 1000:1000 $CHARD_ROOT/$CHARD_HOME/.bashrc 2>/dev/null
                chard_unmount
                
                CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
                if [ -f "$CHROMEOS_BASHRC" ]; then
                    CHROME_MILESTONE=$(grep '^CHROMEOS_RELEASE_CHROME_MILESTONE=' /etc/lsb-release | cut -d'=' -f2)
                    echo "$CHROME_MILESTONE" | sudo tee "$CHARD_ROOT/.chard_chrome" > /dev/null
                    sudo ln -sf /usr/local/chard/usr/bin/xkbcomp /usr/bin/xkbcomp 2>/dev/null
                    sudo mkdir -p $CHARD_ROOT/$CHARD_HOME/external 2>/dev/null
                    sudo chown -R chronos:chronos-access $CHARD_ROOT/$CHARD_HOME/external 2>/dev/null
                fi
                source "$CHARD_ROOT/.chardrc"
                echo "${GREEN}[*] Quick reinstall complete.${RESET}"
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
