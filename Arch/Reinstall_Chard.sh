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
    sudo umount -l "$CHARD_ROOT/etc/hosts"   2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/etc/resolv.conv"   2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/cras"   2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/chrome" 2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/udev"    2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/dbus"   2>/dev/null || true
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
    sudo umount -l "$CHARD_ROOT/tmp/usb_mount" 2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/tmp/" 2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/user/1000" 2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/" 2>/dev/null || true
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
    sudo umount -l "$CHARD_ROOT/run/cras"   2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/chrome" 2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/udev"    2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/dbus"   2>/dev/null || true
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
    $CHARD_ROOT/bin/chard_mtp_unmount 2>/dev/null
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/tmp/" 2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/user/1000" 2>/dev/null || true
    sleep 0.05
    sudo umount -l "$CHARD_ROOT/run/" 2>/dev/null || true
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

    GPU_TYPE="unknown"
}

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

                if [[ -z "$CHARD_ROOT" || "$CHARD_ROOT" == "/" ]]; then
                    echo "${RED}${BOLD}ERROR: CHARD_ROOT variable is empty.${RESET}"
                    sleep 4
                    exit 1
                fi

    chard_unmount() {    
        sudo umount -l "$CHARD_ROOT/etc/hosts"   2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/etc/resolv.conv"   2>/dev/null || true
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
        $CHARD_ROOT/bin/chard_mtp_unmount 2>/dev/null
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/tmp/" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/user/1000" 2>/dev/null || true
        sleep 0.05
        sudo umount -l "$CHARD_ROOT/run/" 2>/dev/null || true
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
        echo
        echo "${RESET}${GREEN}Chard safely unmounted${RESET}"
        echo
}
chard unmount
sudo rm $CHARD_ROOT/bin/Reinstall_Chard.sh 2>/dev/null
echo "${CYAN}[*] Downloading Chard components...${RESET}"
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/.chardrc"           -o "$CHARD_ROOT/.chardrc" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/.chard.env"         -o "$CHARD_ROOT/.chard.env" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/Uninstall_Chard.sh"  -o "$CHARD_ROOT/bin/Uninstall_Chard.sh" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/chard.sh"           -o "$CHARD_ROOT/bin/chard" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/.bashrc"            -o "$CHARD_ROOT/$CHARD_HOME/.bashrc" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_version"       -o "$CHARD_ROOT/bin/chard_version" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/LICENSE"                 -o "$CHARD_ROOT/$CHARD_HOME/CHARD_LICENSE" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/.rootrc"            -o "$CHARD_ROOT/bin/.rootrc" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/chariot.sh"         -o "$CHARD_ROOT/bin/chariot" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_debug.sh"      -o "$CHARD_ROOT/bin/chard_debug" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/chard_sommelier.sh" -o "$CHARD_ROOT/bin/chard_sommelier" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_scale.sh"      -o "$CHARD_ROOT/bin/chard_scale" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/wx"                  -o "$CHARD_ROOT/bin/wx" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/SMRT.sh"            -o "$CHARD_ROOT/bin/SMRT" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_mount"         -o "$CHARD_ROOT/bin/chard_mount" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_unmount"       -o "$CHARD_ROOT/bin/chard_unmount" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/chardsetup.sh"      -o "$CHARD_ROOT/bin/chardsetup" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/root.sh"            -o "$CHARD_ROOT/bin/root" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_volume.sh"            -o "$CHARD_ROOT/bin/chard_volume" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chardwire.sh"            -o "$CHARD_ROOT/bin/chardwire" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/.chard.preload"            -o "$CHARD_ROOT/.chard.preload" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/chard_ucm.sh"            -o "$CHARD_ROOT/bin/chard_ucm" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_preload.sh"            -o "$CHARD_ROOT/bin/chard_preload" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/rainbow.sh"            -o "$CHARD_ROOT/bin/rainbow" 2>/dev/null
#sleep 0.05
#sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_garcon.sh"            -o "$CHARD_ROOT/bin/chard_garcon" 2>/dev/null
#sleep 0.05
#sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard.conf"            -o /etc/init/chard.conf 2>/dev/null
#sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/rainbow.sh"            -o "$CHARD_ROOT/bin/rainbow" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/error_color.sh"            -o "$CHARD_ROOT/bin/error_color" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/color_reset.sh"            -o "$CHARD_ROOT/bin/color_reset" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_stage3_preload.sh"         -o "$CHARD_ROOT/bin/chard_stage3_preload"
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/autoclicker"            -o "$CHARD_ROOT/bin/autoclicker" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_mtp_mount.sh"            -o "$CHARD_ROOT/bin/chard_mtp_mount" 2>/dev/null
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_mtp_unmount.sh"            -o "$CHARD_ROOT/bin/chard_mtp_unmount" 2>/dev/null
sleep 0.05
sudo mkdir -p "$CHARD_ROOT/run/udev"
sudo chmod +x "$CHARD_ROOT/bin/chard"
sudo chmod +x "$CHARD_ROOT/bin/chariot"
sudo chmod +x "$CHARD_ROOT/bin/.rootrc"
sudo chmod +x "$CHARD_ROOT/bin/chard_debug"
sudo chmod +x "$CHARD_ROOT/bin/Uninstall_Chard.sh"
sudo chmod +x "$CHARD_ROOT/bin/chard_sommelier"
sudo chmod +x "$CHARD_ROOT/bin/chard_scale"
sudo chmod +x "$CHARD_ROOT/bin/wx"
sudo chmod +x "$CHARD_ROOT/bin/SMRT"
sudo chmod +x "$CHARD_ROOT/bin/chard_mount"
sudo chmod +x "$CHARD_ROOT/bin/chard_unmount"
sudo chmod +x "$CHARD_ROOT/bin/chardsetup"
sudo chmod +x "$CHARD_ROOT/bin/root"
sudo chmod +x "$CHARD_ROOT/bin/chard_volume"
sudo chmod +x "$CHARD_ROOT/bin/chardwire"
sudo chmod +x "$CHARD_ROOT/.chard.preload"
sudo chmod +x "$CHARD_ROOT/bin/chard_ucm"
sudo chmod +x "$CHARD_ROOT/bin/chard_preload"
sudo chmod +x "$CHARD_ROOT/bin/rainbow"
sudo chmod +x "$CHARD_ROOT/bin/color_reset"
sudo chmod +x "$CHARD_ROOT/bin/error_color"
sudo chmod +x "$CHARD_ROOT/bin/chard_stage3_preload"
sudo chmod +x "$CHARD_ROOT/bin/autoclicker"
sudo chmod +x "$CHARD_ROOT/bin/chard_mtp_mount"
sudo chmod +x "$CHARD_ROOT/bin/chard_mtp_unmount"

#sudo chmod +x "$CHARD_ROOT/bin/chard_garcon"
#sudo chmod +x /etc/init/chard.conf

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

    sudo tee /bin/chard_flatpak >/dev/null <<'EOF'
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
/usr/bin/flatpak "$@"
EOF
sudo chmod +x "$CHARD_ROOT/bin/chard_flatpak"

sudo tee "$CHARD_ROOT/bin/chard_steam" >/dev/null <<'EOF'
#!/bin/bash
export PATH=/usr/local/bubblepatch/bin:$PATH
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export QT_QPA_PLATFORM=xcb
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
xhost +SI:localuser:$USER
source ~/.bashrc
sudo -u $CHARD_USER /usr/bin/firefox
EOF
sudo chmod +x "$CHARD_ROOT/bin/chard_firefox"

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
sudo mkdir -p $CHARD_ROOT/$CHARD_HOME/external 2>/dev/null
sudo mkdir -p $CHARD_ROOT/$CHARD_HOME/mtp_devices 2>/dev/null
sudo chown -R chronos:chronos-access $CHARD_ROOT/$CHARD_HOME/external 2>/dev/null
sudo chown -R chronos:chronos-access $CHARD_ROOT/$CHARD_HOME/mtp_devices 2>/dev/null
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

sudo tee $CHARD_ROOT/etc/pulse/default.pa.d/10-cras.pa > /dev/null << 'EOF'
load-module module-alsa-sink device=default sink_name=cras_sink control=none
load-module module-softvol-sink sink_name=linear_sink master=cras_sink
set-default-sink linear_sink
load-module module-suspend-on-idle
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
sudo mkdir -p $CHARD_ROOT/media

                if [ -f "/home/chronos/user/.bashrc" ]; then
                    sudo mountpoint -q "$CHARD_ROOT/run/chrome" || sudo mount --bind /run/chrome "$CHARD_ROOT/run/chrome" 2>/dev/null
                    sudo mountpoint -q "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" || sudo mount --bind "/home/chronos/user/MyFiles/Downloads" "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null
                    sudo mount -o remount,rw,bind "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads"
                
                else
                    sudo mountpoint -q "$CHARD_ROOT/run/user/1000" || sudo mount --bind /run/user/1000 "$CHARD_ROOT/run/user/1000" 2>/dev/null
                fi

                sudo mountpoint -q "$CHARD_ROOT/run/dbus"   || sudo mount --bind /run/dbus "$CHARD_ROOT/run/dbus" 2>/dev/null
                sudo mountpoint -q "$CHARD_ROOT/run/udev"   || sudo mount --bind /run/udev "$CHARD_ROOT/run/udev" 2>/dev/null
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
                        sudo chown -R 1000:1000 \$HOME 2>/dev/null
                        cd \$HOME
                        sudo rm /etc/pipewire/pipewire.conf.d/crostini-audio.conf 2>/dev/null
                        sudo mv /usr/share/libalpm/hooks/90-packagekit-refresh.hook /usr/share/libalpm/hooks/90-packagekit-refresh.hook.disabled 2>/dev/null
                        gpg --batch --pinentry-mode loopback --passphrase '' --quick-gen-key \"dummy-kde-wallet\" default default never 2>/dev/null
                    "
  
                    killall -9 pipewire 2>/dev/null
                    killall -9 pulseaudio 2>/dev/null
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

                CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
                if [ -f "$CHROMEOS_BASHRC" ]; then
                    CHROME_MILESTONE=$(grep '^CHROMEOS_RELEASE_CHROME_MILESTONE=' /etc/lsb-release | cut -d'=' -f2)
                    echo "$CHROME_MILESTONE" | sudo tee "$CHARD_ROOT/.chard_chrome" > /dev/null
                    sudo ln -sf /usr/local/chard/usr/bin/xkbcomp /usr/bin/xkbcomp 2>/dev/null
                fi
                # Remove .chard.preload
                # sudo rm $CHARD_ROOT/.chard.preload 2>/dev/null
                
                if [ -x "/usr/local/bin/powercontrol" ]; then
                    sudo -E curl -fsSL "https://raw.githubusercontent.com/shadowed1/ChromeOS_PowerControl/main/gui.py" -o "$CHARD_ROOT/bin/powercontrol-gui" 2>/dev/null
                    sudo chmod +x "$CHARD_ROOT/bin/powercontrol-gui" 2>/dev/null
                fi
                
                echo "${MAGENTA}[*] Quick Reinstall complete.${RESET}"
                echo
                source $CHARD_ROOT/.chardrc
                ;;
            2)
                echo "${RESET}${YELLOW}[*] Performing full reinstall..."
                bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_download?$(date +%s)")
                ;;
            q|Q|*)
                echo "${RESET}${RED}[*] Reinstall cancelled.${RESET}"
                ;;
         esac
