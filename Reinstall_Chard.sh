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
    sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/run/chrome" 2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/run/dbus"   2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/etc/ssl"    2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/dev/pts"    2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/dev/shm"    2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/dev"        2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/sys"        2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/proc"       2>/dev/null || true
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
                        
                        getent group 1000 >/dev/null   || groupadd -g 1000 chronos 2>/dev/null
                        getent group 601  >/dev/null   || groupadd -g 601 wayland 2>/dev/null
                        getent group 602  >/dev/null   || groupadd -g 602 arc-bridge 2>/dev/null
                        getent group 20205 >/dev/null  || groupadd -g 20205 arc-keymintd 2>/dev/null
                        getent group 604  >/dev/null   || groupadd -g 604 arc-sensor 2>/dev/null
                        getent group 665357 >/dev/null || groupadd -g 665357 android-everybody 2>/dev/null
                        getent group 18   >/dev/null   || groupadd -g 18 audio 2>/dev/null
                        getent group 222  >/dev/null   || groupadd -g 222 input 2>/dev/null
                        getent group 7    >/dev/null   || groupadd -g 7 lp 2>/dev/null
                        getent group 27   >/dev/null   || groupadd -g 27 video 2>/dev/null
                        getent group 423  >/dev/null   || groupadd -g 423 bluetooth-audio 2>/dev/null
                        getent group 600  >/dev/null   || groupadd -g 600 cras 2>/dev/null
                        getent group 85   >/dev/null   || groupadd -g 85 usb 2>/dev/null
                        getent group 20162 >/dev/null  || groupadd -g 20162 traced-producer 2>/dev/null
                        getent group 20164 >/dev/null  || groupadd -g 20164 traced-consumer 2>/dev/null
                        getent group 1001 >/dev/null   || groupadd -g 1001 chronos-access 2>/dev/null
                        getent group 240  >/dev/null   || groupadd -g 240 brltty 2>/dev/null
                        getent group 20150 >/dev/null  || groupadd -g 20150 arcvm-boot-notification-server 2>/dev/null
                        getent group 20189 >/dev/null  || groupadd -g 20189 arc-mojo-proxy 2>/dev/null
                        getent group 20152 >/dev/null  || groupadd -g 20152 arc-host-clock 2>/dev/null
                        getent group 608  >/dev/null   || groupadd -g 608 midis 2>/dev/null
                        getent group 415  >/dev/null   || groupadd -g 415 suzy-q 2>/dev/null
                        getent group 612  >/dev/null   || groupadd -g 612 ml-core 2>/dev/null
                        getent group 311  >/dev/null   || groupadd -g 311 fuse-archivemount 2>/dev/null
                        getent group 20137 >/dev/null  || groupadd -g 20137 crash 2>/dev/null
                        getent group 419  >/dev/null   || groupadd -g 419 crash-access 2>/dev/null
                        getent group 420  >/dev/null   || groupadd -g 420 crash-user-access 2>/dev/null
                        getent group 304  >/dev/null   || groupadd -g 304 fuse-drivefs 2>/dev/null
                        getent group 20215 >/dev/null  || groupadd -g 20215 regmond_senders 2>/dev/null
                        getent group 603  >/dev/null   || groupadd -g 603 arc-camera 2>/dev/null
                        getent group 20042 >/dev/null  || groupadd -g 20042 camera 2>/dev/null
                        getent group 208  >/dev/null   || groupadd -g 208 pkcs11 2>/dev/null
                        getent group 303  >/dev/null   || groupadd -g 303 policy-readers 2>/dev/null
                        getent group 20132 >/dev/null  || groupadd -g 20132 arc-keymasterd 2>/dev/null
                        getent group 605  >/dev/null   || groupadd -g 605 debugfs-access 2>/dev/null
                        
                                                
                        if ! id \"\$CHARD_USER\" &>/dev/null; then
                            useradd -u 1000 -g 1000 -d \"/\$CHARD_HOME\" -M -s /bin/bash \"\$CHARD_USER\"
                        fi
                        
                        usermod -aG chronos,wayland,arc-bridge,arc-keymintd,arc-sensor,android-everybody,audio,input,lp,video,bluetooth-audio,cras,usb,traced-producer,traced-consumer,chronos-access,brltty,arcvm-boot-notification-server,arc-mojo-proxy,arc-host-clock,midis,suzy-q,ml-core,fuse-archivemount,crash,crash-access,crash-user-access,fuse-drivefs,regmond_senders,arc-camera,camera,pkcs11,policy-readers,arc-keymasterd,debugfs-access \$CHARD_USER
                        
                        mkdir -p \"/\$CHARD_HOME\"
                        chown 1000:1000 \"/\$CHARD_HOME\"
        
                        emerge --noreplace app-admin/sudo
        
                        mkdir -p /etc/sudoers.d
                        chown root:root /etc/sudoers.d
                        chmod 755 /etc/sudoers.d
                        chown root:root /etc/sudoers.d/\$USER
                        chmod 440 /etc/sudoers.d/\$USER
                        chown root:root /usr/bin/sudo
                        chmod 4755 /usr/bin/sudo
                        echo \"Passwordless sudo configured for \$CHARD_USER\"
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
                sudo mkdir -p "$CHARD_ROOT/tmp/.X11-unix"
                sudo chmod 1777 "$CHARD_ROOT/tmp/.X11-unix"
                
                echo "${BLUE}[*] Downloading Chard components...${RESET}"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/.chardrc"            -o "$CHARD_ROOT/.chardrc"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/.chard.env"          -o "$CHARD_ROOT/.chard.env"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/.chard.logic"        -o "$CHARD_ROOT/.chard.logic"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/.chard.preload"      -o "$CHARD_ROOT/.chard.preload"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/SMRT.sh"             -o "$CHARD_ROOT/bin/SMRT"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/chard.sh"            -o "$CHARD_ROOT/bin/chard"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/.bashrc"             -o "$CHARD_ROOT/$CHARD_HOME/.bashrc"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/.rootrc"             -o "$CHARD_ROOT/bin/.rootrc"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/chariot.sh"          -o "$CHARD_ROOT/bin/chariot"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/chard_debug.sh"      -o "$CHARD_ROOT/bin/chard_debug"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Reinstall_Chard.sh"  -o "$CHARD_ROOT/bin/Reinstall_Chard.sh"
                sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Uninstall_Chard.sh"  -o "$CHARD_ROOT/bin/Uninstall_Chard.sh"
                
                sudo chmod +x "$CHARD_ROOT/bin/SMRT"
                sudo chmod +x "$CHARD_ROOT/bin/chard"
                sudo chmod +x "$CHARD_ROOT/bin/chariot"
                sudo chmod +x "$CHARD_ROOT/bin/.rootrc"
                sudo chmod +x "$CHARD_ROOT/bin/chard_debug"
                sudo chmod +x "$CHARD_ROOT/bin/Reinstall_Chard.sh"
                sudo chmod +x "$CHARD_ROOT/bin/Uninstall_Chard.sh"
                
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
                    chown -R portage:portage /var/db/pkg /var/lib/portage
                    chmod -R 755 /var/db/pkg
                    chmod 644 /var/lib/portage/world
                    /bin/SMRT
                    source \$HOME/.smrt_env.sh
                    chown 1000:1000 \$HOME/ -R
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
                    ABI_X86="64 32"
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
            
            MAKECONF_ABI_LINE=""
            if [ -n "${ABI_X86:-}" ]; then
                MAKECONF_ABI_LINE="ABI_X86=\"${ABI_X86}\""
            fi
            
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
                    VIDEO_CARDS="mediatek"
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
USE="X a52 aac acl acpi alsa bindist -bluetooth branding bzip2 cairo cdda cdr cet crypt cube dbus dri dri3 dts encode exif egl flac gdbm gif gpm gtk gtk3 gui iconv icu introspection ipv6 jpeg jit kms lcms libnotify libtirpc llvm mad minizip mng mp3 mp4 mpeg multilib ncurses nls ogg opengl openmp opus pam pango pcre pdf png ppds proprietary-codecs pulseaudio qml qt5 qt6 readline sdl seccomp sound spell spirv ssl startup-notification svg tiff truetype udev -udisks unicode -upower usb -utils vorbis vulkan wayland wxwidgets x264 x265 xattr xcb xft xml xv xvid zlib python_targets_python3_13 systemd vpx vaapi vdpau zstd -elogind"
PYTHON_TARGETS="python3_13"
ACCEPT_KEYWORDS="$ACCEPT_KEYWORDS"
VIDEO_CARDS="$VIDEO_CARDS"
$MAKECONF_ABI_LINE
PKG_CONFIG_PATH="/usr/lib/pkgconfig:/lib/pkgconfig:/usr/share/pkgconfig:/share/pkgconfig:\$PKG_CONFIG_PATH"
PKG_CONFIG="/usr/bin/pkg-config"
PORTAGE_PROFILE_DIR="/usr/local/etc/portage/make.profile"
MESON_NATIVE_FILE="/meson-cross.ini"
PYTHONMULTIPROCESSING_START_METHOD=fork
EOF

                echo "${RESET}${BLUE}make.conf generated successfully for $GPU_TYPE + $ARCH -> $MAKECONF_FILE ${RESET}"
    
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
