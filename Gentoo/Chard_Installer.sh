#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

START_TIME=$(date +%s)
MAX_RETRIES=10
RETRY_DELAY=30

cancel_chroot() {
    echo "${RED}Cancelled${RESET}"
    exit 1
}

trap cancel_chroot INT TERM

echo "${RESET}${GREEN}"
echo
echo
echo
echo
echo
echo
echo "                                                             AA"
echo "                                                            A${RESET}${RED}::${RESET}${GREEN}A"
echo "        CCCCCCCCCCCCCHHHHHHHHH     HHHHHHHHH               A${RESET}${RED}::::${RESET}${GREEN}A               RRRRRRRRRRRRRRRRR   DDDDDDDDDDDDD" 
echo "     CCC${RESET}${YELLOW}::::::::::::${RESET}${GREEN}CH${RESET}${YELLOW}:::::::${RESET}${GREEN}H     H${RESET}${YELLOW}:::::::${RESET}${GREEN}H              A${RESET}${RED}::::::${RESET}${GREEN}A              R${RESET}${YELLOW}::::::::::::::::${RESET}${GREEN}R  D${RESET}${YELLOW}::::::::::::${RESET}${GREEN}DDD"  
echo "   CC${RESET}${YELLOW}:::::::::::::::${RESET}${GREEN}CH${RESET}${YELLOW}:::::::${RESET}${GREEN}H     H${RESET}${YELLOW}:::::::${RESET}${GREEN}H             A${RESET}${RED}::::::::${RESET}${GREEN}A             R${RESET}${YELLOW}::::::${RESET}${GREEN}RRRRRR${RESET}${YELLOW}:::::${RESET}${GREEN}R D${RESET}${YELLOW}:::::::::::::::${RESET}${GREEN}DD"  
echo "  C${RESET}${YELLOW}:::::${RESET}${GREEN}CCCCCCCC${RESET}${YELLOW}::::${RESET}${GREEN}CHH${RESET}${YELLOW}::::::${RESET}${GREEN}H     H${RESET}${YELLOW}::::::${RESET}${GREEN}HH            A${RESET}${RED}::::::::::${RESET}${GREEN}A            RR${RESET}${YELLOW}:::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}RDDD${RESET}${YELLOW}:::::${RESET}${GREEN}DDDDD${RESET}${YELLOW}:::::${RESET}${GREEN}D"  
echo " C${RESET}${YELLOW}:::::${RESET}${GREEN}C       CCCCCC  H${RESET}${YELLOW}:::::${RESET}${GREEN}H     H${RESET}${YELLOW}:::::${RESET}${GREEN}H             A${RESET}${RED}::::::::::::${RESET}${GREEN}A             R${RESET}${YELLOW}::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}R  D${RESET}${YELLOW}:::::${RESET}${GREEN}D     D${RESET}${YELLOW}:::::${RESET}${GREEN}D"  
echo "C${RESET}${YELLOW}:::::${RESET}${GREEN}C                H${RESET}${YELLOW}:::::${RESET}${GREEN}H     H${RESET}${YELLOW}:::::${RESET}${GREEN}H            A${RESET}${RED}::::::::::::::${RESET}${GREEN}A            R${RESET}${YELLOW}::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}R  D${RESET}${YELLOW}:::::${RESET}${GREEN}D     D${RESET}${YELLOW}:::::${RESET}${GREEN}D"
echo "C${RESET}${YELLOW}:::::${RESET}${GREEN}C                H${RESET}${YELLOW}::::::${RESET}${GREEN}HHHHH${RESET}${YELLOW}::::::${RESET}${GREEN}H           A${RESET}${RED}::            ::${RESET}${GREEN}A           R${RESET}${YELLOW}::::${RESET}${GREEN}RRRRRR${RESET}${YELLOW}:::::${RESET}${GREEN}R   D${RESET}${YELLOW}:::::${RESET}${GREEN}D     D${RESET}${YELLOW}:::::${RESET}${GREEN}D"  
echo "C${RESET}${YELLOW}:::::${RESET}${GREEN}C                H${RESET}${YELLOW}:::::::::::::::::${RESET}${GREEN}H          A${RESET}${RED}:::            :::${RESET}${GREEN}A          R${RESET}${YELLOW}:::::::::::::${RESET}${GREEN}RR    D${RESET}${YELLOW}:::::${RESET}${GREEN}D     D${RESET}${YELLOW}:::::${RESET}${GREEN}D"
echo "C${RESET}${YELLOW}:::::${RESET}${GREEN}C                H${RESET}${YELLOW}:::::::::::::::::${RESET}${GREEN}H         A${RESET}${RED}::::            ::::${RESET}${GREEN}A         R${RESET}${YELLOW}::::${RESET}${GREEN}RRRRRR${RESET}${YELLOW}:::::${RESET}${GREEN}R   D${RESET}${YELLOW}:::::${RESET}${GREEN}D     D${RESET}${YELLOW}:::::${RESET}${GREEN}D"    
echo "C${RESET}${YELLOW}:::::${RESET}${GREEN}C                H${RESET}${YELLOW}::::::${RESET}${GREEN}HHHHH${RESET}${YELLOW}::::::${RESET}${GREEN}H        A${RESET}${RED}:::::            :::::${RESET}${GREEN}A        R${RESET}${YELLOW}::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}R  D${RESET}${YELLOW}:::::${RESET}${GREEN}D     D${RESET}${YELLOW}:::::${RESET}${GREEN}D"    
echo "C${RESET}${YELLOW}:::::${RESET}${GREEN}C                H${RESET}${YELLOW}:::::${RESET}${GREEN}H     H${RESET}${YELLOW}:::::${RESET}${GREEN}H       A${RESET}${RED}::::::            ::::::${RESET}${GREEN}A       R${RESET}${YELLOW}::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}R  D${RESET}${YELLOW}:::::${RESET}${GREEN}D     D${RESET}${YELLOW}:::::${RESET}${GREEN}D"   
echo " C${RESET}${YELLOW}:::::${RESET}${GREEN}C       CCCCCC  H${RESET}${YELLOW}:::::${RESET}${GREEN}H     H${RESET}${YELLOW}:::::${RESET}${GREEN}H      A${RESET}${RED}:::::                :::::${RESET}${GREEN}A      R${RESET}${YELLOW}::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}R  D${RESET}${YELLOW}:::::${RESET}${GREEN}D     D${RESET}${YELLOW}:::::${RESET}${GREEN}D"  
echo "  C${RESET}${YELLOW}:::::${RESET}${GREEN}CCCCCCCC${RESET}${YELLOW}::::${RESET}${GREEN}CHH${RESET}${YELLOW}::::::${RESET}${GREEN}H     H${RESET}${YELLOW}::::::${RESET}${GREEN}HH   A${RESET}${RED}:::::::::          :::::::::${RESET}${GREEN}A   RR${RESET}${YELLOW}:::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}RDDD${RESET}${YELLOW}:::::${RESET}${GREEN}DDDDD${RESET}${YELLOW}:::::${RESET}${GREEN}D" 
echo "   CC${RESET}${YELLOW}:::::::::::::::${RESET}${GREEN}CH${RESET}${YELLOW}:::::::${RESET}${GREEN}H     H${RESET}${YELLOW}:::::::${RESET}${GREEN}H  A${RESET}${RED}:::::::::            :::::::::${RESET}${GREEN}A  R${RESET}${YELLOW}::::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}RD${RESET}${YELLOW}:::::::::::::::${RESET}${GREEN}DD"  
echo "     CCC${RESET}${YELLOW}::::::::::::${RESET}${GREEN}CH${RESET}${YELLOW}:::::::${RESET}${GREEN}H     H${RESET}${YELLOW}:::::::${RESET}${GREEN}H A${RESET}${RED}::::::::                ::::::::${RESET}${GREEN}A R${RESET}${YELLOW}::::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}RD${RESET}${YELLOW}::::::::::::${RESET}${GREEN}DDD"  
echo "        CCCCCCCCCCCCCHHHHHHHHH     HHHHHHHHHA${BOLD}======                      ======${RESET}${GREEN}ARRRRRRRR     RRRRRRRDDDDDDDDDDDDD"   
echo "                                           ${BOLD}A====                            ====A"
echo "                                          A====                              ====A"
echo "${RESET}"
echo               
echo "${RESET}"
echo "${RED}- Chard Gentoo can take ${BOLD}2 to 24 hours${RESET}${RED} depending on your CPU and storage speed. Requires ~10 GB of space. Supports ${BOLD}x86_64${RESET}${RED} and ${BOLD}ARM64${RESET}${RED}! ${RESET}"
echo "${RED}- Chard install location can be customized and will not affect ChromeOS system commands.${RESET}"
echo
echo "${YELLOW}- It is ${BOLD}semi-sandboxed within itself${RESET}${YELLOW}, but can rely on Host libraries.${RESET}"
echo "${YELLOW}- Chard has ${BOLD}not${RESET}${YELLOW} been tested with Brunch Toolchain or Chromebrew - this project uses a standalone implementation. It does ${BOLD}NOT${RESET}${YELLOW} require dev_install.${RESET}"
echo
echo "${GREEN}- Does not require altering current state of /usr/local/ during Install and Uninstall.${RESET}"
echo "${GREEN}- Chard is currently in early development. ${BOLD}Bugs will exist${RESET}${GREEN}, so please have a ${BOLD}USB backup${RESET}${GREEN} in case of serious mistakes.${RESET}"
echo
echo "${CYAN}${BOLD}- Chard README: ${RESET}"
echo "${BLUE}- https://github.com/shadowed1/Chard/blob/main/README.md ${RESET}"
echo "${MAGENTA}${BOLD}"
echo "- Requires Developer Mode for ChromeOS users."
echo "${RESET}"


format_time() {
    local total_seconds=$1
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))
    
    if [ $hours -gt 0 ]; then
        printf "%dh %dm %ds" $hours $minutes $seconds
    elif [ $minutes -gt 0 ]; then
        printf "%dm %ds" $minutes $seconds
    else
        printf "%ds" $seconds
    fi
}

show_progress() {
    local current_time=$(date +%s)
    local elapsed=$((current_time - START_TIME))
    local formatted_time=$(format_time $elapsed)
    echo "${CYAN}[Runtime: $formatted_time]${RESET} $1"
}

read -rp "${GREEN}${BOLD}Install Chard?${RESET} (Y/n):" response
response=${response:-Y}

case "$response" in
    y|Y|yes|YES|Yes)
        echo
        echo
        ;;
    *)
        echo -e "${RED}[EXIT]${RESET}"
        exit 1
        ;;
esac

DEFAULT_CHARD_ROOT="/usr/local/chard"

if [ -f "$DEFAULT_CHARD_ROOT/.install_path" ]; then
    CHARD_ROOT=$(sudo cat "$DEFAULT_CHARD_ROOT/.install_path")
    echo -e "${CYAN}Found existing Install Path: ${BOLD}$CHARD_ROOT${RESET}"
else
    CHARD_ROOT="$DEFAULT_CHARD_ROOT"
fi

    read -rp "${GREEN}Enter desired Install Path - ${RESET}${GREEN}${BOLD}leave blank for default: $CHARD_ROOT: ${RESET}" choice
    if [ -n "$choice" ]; then
        CHARD_ROOT="${choice}"
    fi
    CHARD_ROOT="${CHARD_ROOT%/}"
    echo -e "\n${CYAN}You entered: ${BOLD}$CHARD_ROOT${RESET}"
    echo
    read -rp "${BLUE}${BOLD}Confirm this install path? Enter key counts as yes! ${RESET}${BOLD} (Y/n): ${RESET}" confirm
    echo ""
        
    case "$confirm" in
        [Yy]* | "")
            sudo mkdir -p "$CHARD_ROOT"
            ;;
        [Nn]*)
            echo -e "${BLUE}Cancelled.${RESET}\n"
            exit 1
            ;;
        *)
            echo -e "${RED}Please answer Y/n.${RESET}"
            exit 1
            ;;
    esac
    
unset LD_PRELOAD

echo "$CHARD_ROOT" | sudo tee "$CHARD_ROOT/.install_path" >/dev/null
    
CHARD_ROOT="${CHARD_ROOT%/}"
CHARD_RC="$CHARD_ROOT/.chardrc"
BUILD_DIR="$CHARD_ROOT/var/tmp/build"
LOG_FILE="$CHARD_ROOT/chardbuild.log"

echo
echo "${RED}Chard Installs to ${CHARD_ROOT}${RESET}${YELLOW} - Install will eventually chroot into chard. ${BOLD}This means / will be $CHARD_ROOT/ in reality.${RESET}"
echo
echo "${GREEN}[+] Creating ${RESET}${RED}Chard Root${RESET}"

cleanup_chroot() {
    echo "${RED}Unmounting Chard${RESET}"
    sudo umount -l "$CHARD_ROOT/run/cras"                           2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev/input"                          2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev/dri"                            2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/run/chrome"                         2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/run/dbus"                           2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/etc/ssl"                            2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev/pts"                            2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev/shm"                            2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev"                                2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/sys"                                2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/proc"                               2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/tmp/usb_mount"                      2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/run/user/1000"                      2>/dev/null || true
    sleep 0.2
    sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"               2>/dev/null || true
    sleep 0.2
    sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT" 2>/dev/null || true
    sleep 0.2
    sudo setfacl -Rb /run/chrome 2>/dev/null
    sudo umount -l "$CHARD_ROOT/run/cras"                           2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev/input"                          2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev/dri"                            2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/run/chrome"                         2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/run/dbus"                           2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/etc/ssl"                            2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev/pts"                            2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev/shm"                            2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/dev"                                2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/sys"                                2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/proc"                               2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/tmp/usb_mount"                      2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT/run/user/1000"                      2>/dev/null || true
    sleep 0.2
    sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"               2>/dev/null || true
    sleep 0.2
    sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null || true
    sleep 0.2
    sudo umount -l "$CHARD_ROOT" 2>/dev/null || true
    sleep 0.2
    sudo setfacl -Rb /run/chrome 2>/dev/null
}

existing_int_trap=$(trap -p INT | cut -d"'" -f2)
existing_term_trap=$(trap -p TERM | cut -d"'" -f2)

trap 'cleanup_chroot; '"$existing_int_trap" INT
trap 'cleanup_chroot; '"$existing_term_trap" TERM
trap cleanup_chroot EXIT

echo "${RESET}${RED}[*] Unmounting active bind mounts...${RESET}"
sudo umount -l "$CHARD_ROOT/run/cras"                           2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/dev/input"                          2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/dev/dri"                            2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/run/chrome"                         2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/run/dbus"                           2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/etc/ssl"                            2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/dev/pts"                            2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/dev/shm"                            2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/dev"                                2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/sys"                                2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/proc"                               2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/tmp/usb_mount"                      2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/run/user/1000"                      2>/dev/null || true
sleep 0.2
sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"               2>/dev/null || true
sleep 0.2
sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT" 2>/dev/null || true
sleep 0.2
sudo setfacl -Rb /run/chrome 2>/dev/null
sudo umount -l "$CHARD_ROOT/run/cras"                           2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/dev/input"                          2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/dev/dri"                            2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/run/chrome"                         2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/run/dbus"                           2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/etc/ssl"                            2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/dev/pts"                            2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/dev/shm"                            2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/dev"                                2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/sys"                                2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/proc"                               2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/tmp/usb_mount"                      2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT/run/user/1000"                      2>/dev/null || true
sleep 0.2
sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap"               2>/dev/null || true
sleep 0.2
sudo umount -l -f "$CHARD_ROOT/usr/local/bubblepatch/bin/bwrap" 2>/dev/null || true
sleep 0.2
sudo umount -l "$CHARD_ROOT" 2>/dev/null || true
sleep 0.2
sudo setfacl -Rb /run/chrome 2>/dev/null
echo "${RED}[*] Removing $CHARD_ROOT...${RESET}"
sleep 0.2
sudo rm -rf "$CHARD_ROOT" 2>/dev/null

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

CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
DEFAULT_BASHRC="$HOME/.bashrc"
TARGET_FILE=""
        
if [ -f "$CHROMEOS_BASHRC" ]; then
    TARGET_FILE="$CHROMEOS_BASHRC"
elif [ -f "$DEFAULT_BASHRC" ]; then
    TARGET_FILE="$DEFAULT_BASHRC"
fi
        
if [ -n "$TARGET_FILE" ]; then
    sed -i '/^# <<< CHARD ENV MARKER <<</,/^# <<< END CHARD ENV MARKER <<</d' "$TARGET_FILE"
else
    echo "${RED}No .bashrc found! ${RESET}"
fi

if ! grep -Fxq "# <<< CHARD ENV MARKER <<<" "$TARGET_FILE"; then
    {
        echo "# <<< CHARD ENV MARKER <<<"
        echo "source \"$CHARD_RC\""
        echo "# <<< END CHARD ENV MARKER <<<"
    } >> "$TARGET_FILE"
fi

sudo mkdir -p "$CHARD_ROOT/run/dbus"
sudo mkdir -p "$CHARD_ROOT/tmp"
sudo mkdir -p "$CHARD_ROOT/run/cras"
sudo mkdir -p "$CHARD_ROOT/run/chrome"

echo "${RESET}${RED}Detected .bashrc: ${BOLD}${TARGET_FILE}${RESET}${RED}"
CHARD_HOME="$(dirname "$TARGET_FILE")"
CHARD_HOME="${CHARD_HOME#/}"

if [[ "$CHARD_HOME" == home/* ]]; then
    CHARD_HOME="${CHARD_HOME%%/user*}"

    CHARD_USER="${CHARD_HOME#*/}"
fi

sudo tee "$CHARD_ROOT/.chard_home" >/dev/null <<EOF
$CHARD_HOME
EOF

sudo tee "$CHARD_ROOT/.chard_user" >/dev/null <<EOF
$CHARD_USER
EOF

echo "CHARD_HOME: $CHARD_ROOT/$CHARD_HOME"
echo "CHARD_USER: $CHARD_USER"

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        GENTOO_ARCH="amd64"
        CHOST="x86_64-pc-linux-gnu"
        sudo mkdir -p "$CHARD_ROOT/usr/bin"
        sudo chmod -R +x "$CHARD_ROOT/usr/bin"
        ;;
    aarch64|arm64)
        GENTOO_ARCH="arm64"
        CHOST="aarch64-unknown-linux-gnu"
        sudo mkdir -p "$CHARD_ROOT/usr/bin"
        sudo chmod -R +x "$CHARD_ROOT/usr/bin"
        ;;
    *)
        echo "${RED}[!] Unsupported architecture: $ARCH${RESET}"
        exit 1
        ;;
esac

sudo mkdir -p "$CHARD_ROOT/var/tmp"
PORTAGE_DIR="$CHARD_ROOT/usr/portage"
SNAPSHOT_URL="https://gentoo.osuosl.org/snapshots/portage-latest.tar.xz"
TMP_TAR="$CHARD_ROOT/var/tmp/portage-latest.tar.xz"
echo "${RED}[+] Downloading Portage tree snapshot"
sudo curl -L --progress-bar -o "$TMP_TAR" "$SNAPSHOT_URL"
sudo mkdir -p "$PORTAGE_DIR"
sudo tar -xJf "$TMP_TAR" -C "$PORTAGE_DIR" --strip-components=1 \
    --checkpoint=.100 --checkpoint-action=echo="   extracted %u files"
sudo rm -f "$TMP_TAR"

STAGE3_TXT="https://gentoo.osuosl.org/releases/$GENTOO_ARCH/autobuilds/current-stage3-$GENTOO_ARCH-systemd/latest-stage3-$GENTOO_ARCH-systemd.txt"
STAGE3_FILENAME=$(curl -fsSL "$STAGE3_TXT" | grep -Eo 'stage3-.*\.tar\.xz' | head -n1)
STAGE3_URL=$(dirname "$STAGE3_TXT")"/$STAGE3_FILENAME"
STAGE3_FILE=$(basename "$STAGE3_URL")
TMP_STAGE3="$CHARD_ROOT/var/tmp/$STAGE3_FILE"

echo "${RESET}${YELLOW}[+] Downloading latest Stage3 tarball: $STAGE3_FILENAME"
sudo curl -L --progress-bar -o "$TMP_STAGE3" "$STAGE3_URL"

echo "${RESET}${YELLOW}[+] Extracting Stage3 tarball"
sudo tar -xJf "$TMP_STAGE3" -C "$CHARD_ROOT" --strip-components=1 \
    --checkpoint=.100 --checkpoint-action=echo="   extracted %u files"

sudo rm -f "$TMP_STAGE3"

PROFILE_DIR="$PORTAGE_DIR/profiles/default/linux/$GENTOO_ARCH/23.0/desktop"
MAKE_PROFILE="$CHARD_ROOT/etc/portage/make.profile"
sudo mkdir -p "$(dirname "$MAKE_PROFILE")"
if [ -d "$PROFILE_DIR" ]; then
    REL_TARGET=$(realpath --relative-to="$CHARD_ROOT/etc/portage" "$PROFILE_DIR")
    sudo ln -sfn "$REL_TARGET" "$MAKE_PROFILE"
    echo "${RESET}${GREEN}[+] Portage profile set to $REL_TARGET"
else
    echo "${YELLOW}[!] Desktop profile not found for $GENTOO_ARCH at $PROFILE_DIR"
fi

export PYTHON="$CHARD_ROOT/bin/python3"
export CC="$CHARD_ROOT/usr/bin/gcc"
export CXX="$CHARD_ROOT/usr/bin/g++"
export AR="$CHARD_ROOT/usr/bin/gcc-ar"
export RANLIB="$CHARD_ROOT/usr/bin/gcc-ranlib"
export PATH="$PATH:$CHARD_ROOT/usr/bin"
export CXXFLAGS="$CFLAGS"
export AWK=/usr/bin/mawk
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}/usr/lib64"
export MAKEFLAGS="-j$(nproc)"
export INSTALL_ROOT="$CHARD_ROOT"
export ACLOCAL_PATH="$CHARD_ROOT/usr/share/aclocal"
export PYTHONPATH="$CHARD_ROOT/usr/lib/python3.13/site-packages:$PYTHONPATH"
export PKG_CONFIG_PATH="$CHARD_ROOT/usr/lib64/pkgconfig:$CHARD_ROOT/usr/lib/pkgconfig"
export CFLAGS="-I$CHARD_ROOT/usr/include $CFLAGS"
export LDFLAGS="-L$CHARD_ROOT/usr/lib64 -L$CHARD_ROOT/usr/lib $LDFLAGS"
export GIT_TEMPLATE_DIR="$CHARD_ROOT/usr/share/git-core/templates"

KERNEL_INDEX=$(curl -fsSL https://cdn.kernel.org/pub/linux/kernel/v6.x/ \
    | grep -o 'href="linux-[0-9]\+\.[0-9]\+\.[0-9]\+\.tar\.xz"' \
    | sed 's/href="linux-\(.*\)\.tar\.xz"/\1/' )

KERNEL_VER=$(echo "$KERNEL_INDEX" | sort -V | tail -n2 | head -n1)
KERNEL_TAR="linux-$KERNEL_VER.tar.xz"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/$KERNEL_TAR"
KERNEL_BUILD="$BUILD_DIR/linux-$KERNEL_VER"

echo "Fetching kernel version: $KERNEL_VER"
echo "URL: $KERNEL_URL"

sudo mkdir -p "$BUILD_DIR"

if [ ! -f "$BUILD_DIR/$KERNEL_TAR" ]; then
    echo "${RESET}${GREEN}[+] Fetching $KERNEL_TAR..."
    sudo curl -L --progress-bar -o "$BUILD_DIR/$KERNEL_TAR" "$KERNEL_URL"
else
    echo "${RESET}${RED}[!] Kernel tarball already exists, skipping download."
fi

sudo rm -rf "$KERNEL_BUILD"
sudo tar -xf "$BUILD_DIR/$KERNEL_TAR" -C "$BUILD_DIR" \
    --checkpoint=.500 --checkpoint-action=echo="   extracted %u files"

echo "${RESET}${CYAN}[+] Installing Linux headers into Chard Root..."

sudo chroot "$CHARD_ROOT" /bin/bash -c "
cd /var/tmp/build/linux-$KERNEL_VER

HOST_ARCH=\$(uname -m)
case \"\$HOST_ARCH\" in
    x86_64) KERNEL_ARCH=x86_64 ;;
    aarch64) KERNEL_ARCH=arm64 ;;
    *) echo \"Unsupported Architecture: \$HOST_ARCH\"; exit 1 ;;
esac

make mrproper
make defconfig

rm -rf /usr/src/linux
cp -a . /usr/src/linux

make INSTALL_HDR_PATH=/usr headers_install

cp .config /usr/src/linux/.config
"

echo "${RESET}${BLUE}[+] Linux headers and sources installed to $CHARD_ROOT/usr/src/linux"
echo ""

sudo rm -rf "$KERNEL_BUILD"

CONFIG_FILE="$CHARD_ROOT/usr/src/linux/.config"
OPTIONS=(
    "CONFIG_CGROUP_BPF"
    "CONFIG_FANOTIFY"
    "CONFIG_USER_NS"
    "CONFIG_CRYPTO_USER_API_HASH"
    "CONFIG_INPUT_MOUSEDEV"
)

for opt in "${OPTIONS[@]}"; do
    sudo sed -i -E "s/^# $opt is not set/$opt=y/" "$CONFIG_FILE"
done

for opt in "${OPTIONS[@]}"; do
    if ! sudo grep -q "^$opt=" "$CONFIG_FILE"; then
        echo "$opt=y" | sudo tee -a "$CONFIG_FILE" >/dev/null
    fi
done

sudo grep -E "CONFIG_CGROUP_BPF|CONFIG_FANOTIFY|CONFIG_USER_NS|CONFIG_CRYPTO_USER_API_HASH|CONFIG_INPUT_MOUSEDEV" "$CHARD_ROOT/usr/src/linux/.config" | wc -l

CHARD_HOME=$(cat "$CHARD_ROOT/.chard_home")
CHARD_USER=$(cat "$CHARD_ROOT/.chard_user")
USER_ID=1000
GROUP_ID=1000
PASSWD_FILE="$CHARD_ROOT/etc/passwd"

if grep -q "^${CHARD_USER}:x:${USER_ID}:${GROUP_ID}::" "$PASSWD_FILE"; then
    echo "Fixing empty GECOS field for $CHARD_USER"
    sudo sed -i "s/^${CHARD_USER}:x:${USER_ID}:${GROUP_ID}::/${CHARD_USER}:x:${USER_ID}:${GROUP_ID}:${CHARD_USER} User:/" "$PASSWD_FILE"
else
    echo "GECOS field for $CHARD_USER is already set or missing."
fi

sudo mkdir -p "$CHARD_ROOT/etc/portage"
sudo mkdir -p "$CHARD_ROOT/etc/sandbox.d"
sudo mkdir -p "$CHARD_ROOT/etc/ssl"
sudo mkdir -p "$CHARD_ROOT/usr/bin"
sudo mkdir -p "$CHARD_ROOT/usr/lib"
sudo mkdir -p "$CHARD_ROOT/usr/lib64"
sudo mkdir -p "$CHARD_ROOT/usr/include"
sudo mkdir -p "$CHARD_ROOT/usr/share"
sudo mkdir -p "$CHARD_ROOT/usr/local/bin"
sudo mkdir -p "$CHARD_ROOT/usr/local/lib"
sudo mkdir -p "$CHARD_ROOT/usr/local/include"
sudo mkdir -p "$CHARD_ROOT/var/tmp/build"
sudo mkdir -p "$CHARD_ROOT/var/cache/distfiles"
sudo mkdir -p "$CHARD_ROOT/var/cache/packages"
sudo mkdir -p "$CHARD_ROOT/var/log"
sudo mkdir -p "$CHARD_ROOT/var/run"
sudo mkdir -p "$CHARD_ROOT/dev/shm"
sudo mkdir -p "$CHARD_ROOT/dev/pts"
sudo mkdir -p "$CHARD_ROOT/proc"
sudo mkdir -p "$CHARD_ROOT/sys"
sudo mkdir -p "$CHARD_ROOT/$CHARD_HOME/.local/share"
sudo mkdir -p "$CHARD_ROOT/$CHARD_HOME/Desktop"
sudo mkdir -p "$CHARD_ROOT/mnt"
sudo mkdir -p "$CHARD_ROOT/usr/local/src/gtest-1.16.0"
sudo mkdir -p "$(dirname "$LOG_FILE")"
sudo mkdir -p "$CHARD_ROOT/etc/portage/repos.conf"

sudo rm -f \
    "$CHARD_ROOT/.chardrc" \
    "$CHARD_ROOT/.chard.env" \
    "$CHARD_ROOT/.chard.logic" \
    "$CHARD_ROOT/bin/SMRT" \
    "$CHARD_ROOT/bin/chard"

    
sudo mkdir -p $CHARD_ROOT/run/user/1000
sudo cp /run/user/1000/.Xauthority $CHARD_ROOT/run/user/1000/.Xauthority 2>/dev/null
sudo cp /run/user/1000/.mutter-Xwaylandauth.ID0RE3 $CHARD_ROOT/run/user/1000/.mutter-Xwaylandauth.ID0RE3 2>/dev/null

sudo mkdir -p "$CHARD_ROOT/bin" "$CHARD_ROOT/usr/bin" "$CHARD_ROOT/usr/lib" "$CHARD_ROOT/usr/lib64"

echo "${BLUE}[*] Downloading Chard components...${RESET}"
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/.chardrc"            -o "$CHARD_ROOT/.chardrc"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/.chard.env"          -o "$CHARD_ROOT/.chard.env"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/.chard.logic"        -o "$CHARD_ROOT/.chard.logic"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/.chard.preload"      -o "$CHARD_ROOT/.chard.preload"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/Uninstall_Chard.sh"  -o "$CHARD_ROOT/bin/Uninstall_Chard.sh"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/SMRT.sh"             -o "$CHARD_ROOT/bin/SMRT"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/chard.sh"            -o "$CHARD_ROOT/bin/chard"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/.bashrc"             -o "$CHARD_ROOT/$CHARD_HOME/.bashrc"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_version"       -o "$CHARD_ROOT/$CHARD_HOME/chard_version"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/LICENSE"             -o "$CHARD_ROOT/$CHARD_HOME/CHARD_LICENSE"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/.rootrc"             -o "$CHARD_ROOT/bin/.rootrc"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/chariot.sh"          -o "$CHARD_ROOT/bin/chariot"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_debug.sh"      -o "$CHARD_ROOT/bin/chard_debug"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/chard_sommelier.sh"  -o "$CHARD_ROOT/bin/chard_sommelier"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_scale.sh"      -o "$CHARD_ROOT/bin/chard_scale"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/wx"                  -o "$CHARD_ROOT/bin/wx"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_mount"         -o "$CHARD_ROOT/bin/chard_mount"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_unmount"         -o "$CHARD_ROOT/bin/chard_unmount"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_preload.sh"         -o "$CHARD_ROOT/bin/chard_preload"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Gentoo/chardonnay.sh"         -o "$CHARD_ROOT/bin/chardonnay"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_volume.sh"         -o "$CHARD_ROOT/bin/chard_volume"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chardwire.sh"         -o "$CHARD_ROOT/bin/chardwire"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_stage3_preload.sh"         -o "$CHARD_ROOT/bin/chard_stage3_preload"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/rainbow.sh"         -o "$CHARD_ROOT/bin/rainbow"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/error_color.sh"         -o "$CHARD_ROOT/bin/error_color"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/color_reset.sh"         -o "$CHARD_ROOT/bin/color_reset"
sleep 0.2

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
sudo chmod +x "$CHARD_ROOT/bin/chard_preload"
sudo chmod +x "$CHARD_ROOT/bin/chardonnay"
sudo chmod +x "$CHARD_ROOT/bin/chard_volume"
sudo chmod +x "$CHARD_ROOT/bin/chardwire"
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
        echo "${RED}[!] Missing: $file — download failed${RESET}"
    fi
done

sudo mv "$CHARD_ROOT/bin/.rootrc" "$CHARD_ROOT/.bashrc"

CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
DEFAULT_BASHRC="$HOME/.bashrc"
TARGET_FILE=""

if [ -f "$CHROMEOS_BASHRC" ]; then
    TARGET_FILE="$CHROMEOS_BASHRC"
    sudo mkdir -p "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads"
    sudo mkdir -p $CHARD_ROOT/external
    sudo chown -R chronos:chronos-access $CHARD_ROOT/external
else
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
    else
        echo "${YELLOW}[!] Chard already sourced in $FILE"
    fi
}

add_chard_marker "$TARGET_FILE"
sudo mkdir -p "$CHARD_ROOT/usr/local/src/gtest-1.16.0"
sudo mkdir -p "$(dirname "$LOG_FILE")"
sudo mkdir -p "$CHARD_ROOT/etc/portage/repos.conf"
sudo mkdir -p "$CHARD_ROOT/var/db/repos/gentoo/profiles"
sudo mkdir -p "$CHARD_ROOT/etc/portage/make.profile"
sudo mkdir -p "$CHARD_ROOT/run/user/0"
sudo chmod 700 "$CHARD_ROOT/run/user/0"
sudo mkdir -p "$CHARD_ROOT/run/user/1000"
sudo chmod 700 "$CHARD_ROOT/run/user/1000"
exec > >(sudo tee -a "$LOG_FILE") 2>&1
sudo mkdir -p "$CHARD_ROOT/etc/portage/repos.conf"
sudo mkdir -p "$CHARD_ROOT/etc/portage/package.use"
sudo mkdir -p "$CHARD_ROOT/dev/dri"
sudo mkdir -p "$CHARD_ROOT/dev/input"
sudo mkdir -p "$CHARD_ROOT/tmp"

for pkg in "${PACKAGES[@]}"; do
    IFS="|" read -r NAME VERSION EXT URL DIR BUILDSYS <<< "$pkg"
    ARCHIVE="$NAME-$VERSION.$EXT"

    echo "${RESET}${GREEN}[+] Downloading $URL "

    attempt=1
    while true; do
        sudo curl -L --progress-bar -o "$BUILD_DIR/$ARCHIVE" "$URL" && break

        echo "${RED}[!] Download failed for $NAME-$VERSION (attempt $attempt/$MAX_RETRIES), retrying in $RETRY_DELAY seconds..."
        (( attempt++ ))

        if (( attempt > MAX_RETRIES )); then
            echo "${BOLD}${RED}[!] Failed to download $NAME-$VERSION after $MAX_RETRIES attempts. Aborting.${RESET}"
            exit 1
        fi
        sleep $RETRY_DELAY
    done

    echo "${RESET}${YELLOW}[+] Extracting $NAME-$VERSION"
    case "$EXT" in
        tar.gz|tgz)
            sudo tar -xzf "$BUILD_DIR/$ARCHIVE" -C "$BUILD_DIR" \
                --checkpoint=.500 --checkpoint-action=echo="   extracted %u files"
            ;;
        tar.xz)
            sudo tar -xJf "$BUILD_DIR/$ARCHIVE" -C "$BUILD_DIR" \
                --checkpoint=.500 --checkpoint-action=echo="   extracted %u files"
            ;;
        tar.bz2)
            sudo tar -xjf "$BUILD_DIR/$ARCHIVE" -C "$BUILD_DIR" \
                --checkpoint=.500 --checkpoint-action=echo="   extracted %u files"
            ;;
        zip)
            sudo bsdtar -xf "$BUILD_DIR/$ARCHIVE" -C "$BUILD_DIR"
            ;;
        *)
            echo "Unsupported Archive Format: $EXT"
    esac
done

sudo tee "$CHARD_ROOT/bin/emerge" > /dev/null <<'EOF'
#!/usr/bin/env python3
import os
import sys
import errno
import glob
import tokenize

CHROOT_PYTHON = "/usr/sbin/python"
if os.path.exists(CHROOT_PYTHON):
    python_exec = CHROOT_PYTHON
else:
    python_exec = sys.executable

major = sys.version_info.major
minor = sys.version_info.minor
dotver = f"{major}.{minor}"

PYEXEC_BASE = "/usr/lib/python-exec"
if not os.path.isdir(PYEXEC_BASE):
    PYEXEC_BASE = "/usr/lib/python-exec"

exec_dirs = sorted(glob.glob(os.path.join(PYEXEC_BASE, "python[0-9]*.[0-9]*")))
if not exec_dirs:
    exec_dirs = [os.path.join(PYEXEC_BASE, f"python{dotver}")]

python_dir = exec_dirs[-2] if len(exec_dirs) > 1 else exec_dirs[-1]

python_ver = python_dir.split('/')[-1].replace("python", "")
python_underscore = python_ver.replace(".", "_")

os.environ["PYEXEC_DIR"] = python_dir
os.environ["PYTHON_SINGLE_TARGET"] = f"python{python_underscore}"
os.environ["PYTHON_TARGETS"] = f"python{python_underscore}"

python_site = f"/usr/lib/python{python_ver}/site-packages"
if os.environ.get("PYTHONPATH"):
    os.environ["PYTHONPATH"] = f"{python_site}:{os.environ['PYTHONPATH']}"
else:
    os.environ["PYTHONPATH"] = python_site

target_name = os.path.basename(sys.argv[0])
target_path = os.path.join(python_dir, target_name)

data = None
while data is None:
    try:
        kwargs = {}
        with open(target_path, "rb") as f:
            kwargs["encoding"] = tokenize.detect_encoding(f.readline)[0]
        with open(target_path, "r", **kwargs) as f:
            data = f.read()
    except IOError as e:
        if e.errno == errno.EINTR:
            continue
        elif e.errno == errno.ENOENT:
            sys.stderr.write(f"{target_path}: Python implementation not supported: {python_exec}\n")
            sys.exit(127)
        else:
            raise

sys.argv[0] = target_path
new_globals = dict(globals())
new_globals["__file__"] = target_path

exec(data, new_globals)
EOF

sudo chmod +x "$CHARD_ROOT/bin/emerge"

sudo tee "$CHARD_ROOT/etc/portage/repos.conf/gentoo.conf" > /dev/null <<'EOF'
[gentoo]
location = /var/db/repos/gentoo
sync-type = rsync
sync-uri = rsync://rsync.gentoo.org/gentoo-portage
auto-sync = yes
EOF

if [[ "$ARCH" == "x86_64" ]]; then
    PROFILE_PATH="default/linux/amd64/23.0/systemd"
elif [[ "$ARCH" == "aarch64" ]]; then
    PROFILE_PATH="default/linux/arm64/23.0/systemd"
fi

ln -snf "../../usr/portage/profiles/$PROFILE_PATH" "$CHARD_ROOT/etc/portage/make.profile"

echo "Profile set to: $PROFILE_PATH"

sudo tee "$CHARD_ROOT/etc/profile.d/display.sh" > /dev/null <<'EOF'
export DISPLAY=:0
EOF
sudo chmod +x "$CHARD_ROOT/etc/profile.d/display.sh"

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
        VIDEO_CARDS="iris i915 intel"
        ;;
    amd)
        VIDEO_CARDS="radeonsi r600"
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

USE_FLAGS="X a52 aac acl acpi alsa bindist -bluetooth branding bzip2 cairo cdda cdr cet crypt cube curl dbus dri dri3 dts encode exif egl flac gdbm gif gpm gtk gtk3 gui iconv icu introspection ipv6 jpeg jit kms layers lcms libnotify libtirpc llvm mad minizip mng mp3 mp4 mpeg ncurses nls ogg opengl openmp opus pam pango pcre pdf png postproc ppds proprietary-codecs pulseaudio qml qt5 qt6 readline sdl seccomp sound -sound-server spell spirv ssl startup-notification svg tiff truetype udev -udisks unicode -upower usb -utils vorbis wayland wxwidgets x264 x265 xattr xcb xft xml xv xvid zlib python_targets_python3_13 systemd vpx zstd -elogind"

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

echo "${RESET}${BLUE}make.conf generated successfully for $GPU_TYPE + $ARCH -> $MAKECONF_FILE ${RESET}"

sudo mkdir -p "$CHARD_ROOT/usr/share/sandbox"

sudo tee "$CHARD_ROOT/etc/sandbox.conf" > /dev/null <<'EOF'
SANDBOX_BASHRC="/usr/share/sandbox/sandbox.bashrc"
SANDBOX_D="/etc/sandbox.d"
ns-mount-off
ns-pid-off
ns-ipc-off
ns-net-off
ns-user-off
EOF

sudo tee "$CHARD_ROOT/usr/share/sandbox/sandbox.bashrc" > /dev/null <<'EOF'
export HOME="/$CHARD_HOME/"
export USER="chronos"
export LOGNAME="chronos"
export PATH=/usr/bin:/bin:/usr/local/bin:$HOME/.cargo/bin:$PATH
EOF

ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        sudo tee "$CHARD_ROOT/mesonrust.ini" > /dev/null <<'EOF'
[binaries]
c = '/usr/bin/gcc'
cpp = '/usr/bin/g++'
ar = '/usr/bin/gcc-ar'
ranlib = '/usr/bin/gcc-ranlib'
strip = '/usr/bin/strip'
pkgconfig = 'pkg-config'
cargo = '/$CHARD_HOME/.cargo/bin/cargo'
rust = '/$CHARD_HOME/.cargo/bin/rustc'

[properties]
rust_target = 'x86_64-pc-linux-gnu'

[host_machine]
system = 'linux'
cpu_family = 'x86_64'
cpu = 'x86_64'
endian = 'little'
EOF
        ;;
    aarch64|arm64)
        sudo tee "$CHARD_ROOT/mesonrust.ini" > /dev/null <<'EOF'
[binaries]
c = '/usr/bin/gcc'
cpp = '/usr/bin/g++'
ar = '/usr/bin/gcc-ar'
ranlib = '/usr/bin/gcc-ranlib'
strip = '/usr/bin/strip'
pkgconfig = 'pkg-config'
cargo = '/$CHARD_HOME/.cargo/bin/cargo'
rust = '/$CHARD_HOME/.cargo/bin/rustc'

[properties]
rust_target = 'aarch64-unknown-linux-gnu'

[host_machine]
system = 'linux'
cpu_family = 'aarch64'
cpu = 'aarch64'
endian = 'little'
EOF
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        CHOST=x86_64-pc-linux-gnu
        PROFILE_DIR="$CHARD_ROOT/var/db/repos/gentoo/profiles/default/linux/amd64/17.1"
        ;;
    aarch64)
        CHOST=aarch64-unknown-linux-gnu
        PROFILE_DIR="$CHARD_ROOT/var/db/repos/gentoo/profiles/default/linux/arm64/17.1"
        ;;
    *)
        echo "Unknown architecture: $ARCH"
        exit 1
        ;;
esac

sudo mkdir -p "$CHARD_ROOT/var/db/repos/gentoo/profiles"
sudo mkdir -p "$PROFILE_DIR"

sudo tee "$CHARD_ROOT/var/db/repos/gentoo/profiles/repo_name" > /dev/null <<'EOF'
gentoo
EOF

echo "${RESET}${BLUE}Created $CHARD_ROOT/mesonrust.ini for $ARCH ${RESET}"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        CHOST=x86_64-pc-linux-gnu
        CPU_FAMILY=x86_64
        ;;
    aarch64)
        CHOST=aarch64-unknown-linux-gnu
        CPU_FAMILY=arm64
        ;;
    *)
        echo "Unknown architecture: $ARCH"
        exit 1
        ;;
esac

MESON_FILE="$CHARD_ROOT/meson-cross.ini"

sudo tee "$MESON_FILE" > /dev/null <<EOF

c = '/usr/bin/gcc'
cpp = '/usr/bin/g++'
ar = '/usr/bin/gcc-ar'
ranlib = '/usr/bin/gcc-ranlib'
strip = '/usr/bin/strip'
pkgconfig = '/usr/bin/pkg-config'
pkg-config = '/usr/bin/pkg-config'
llvm-config = 'llvm-config'
fortran = 'false'
objc = 'false'
objcpp = 'false'
objcopy = '/usr/bin/gcc-objcopy'
windres = '/usr/bin/gcc-windres'
python = '/usr/bin/python3'
ninja = '/usr/bin/ninja'

[built-in options]
c_args = ['-march=native', '-O2', '-pipe', '-fPIC', '-I/usr/include']
c_link_args = ['-march=native', '-L/usr/lib64']
cpp_args = ['-march=native', '-O2', '-pipe', '-fPIC', '-I/usr/include']
cpp_link_args = ['-march=native', '-L/usr/lib64']
fortran_args = []
fortran_link_args = []
objc_args = []
objc_link_args = []
objcpp_args = []
objcpp_link_args = []

[properties]
needs_exe_wrapper = false
pkg_config_libdir = '/usr/lib64/pkgconfig'

[build_machine]
system = 'linux'
cpu_family = '$CPU_FAMILY'
cpu = '$CPU_FAMILY'
endian = 'little'
EOF

echo "${RESET}${BLUE}[+] Meson file created at $MESON_FILE for architecture $ARCH"

sudo mkdir -p "$CHARD_ROOT/etc/X11/xorg.conf.d"

XORG_CONF_DIR="$CHARD_ROOT/etc/X11/xorg.conf.d"
sudo mkdir -p "$XORG_CONF_DIR"

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        CHOST="x86_64-pc-linux-gnu"
        CPU_FAMILY="x86_64"
        ;;
    aarch64)
        CHOST="aarch64-unknown-linux-gnu"
        CPU_FAMILY="arm64"
        ;;
    armv7*|armhf)
        CHOST="armv7a-unknown-linux-gnueabihf"
        CPU_FAMILY="arm"
        ;;
    *)
        echo "${YELLOW}Unknown architecture:${RESET} $ARCH"
        ;;
esac

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

detect_gpu_freq
GPU_VENDOR="$GPU_TYPE"
IDENTIFIER="Generic GPU"
DRIVER="modesetting"
ACCEL="glamor"

case "$GPU_VENDOR" in
    intel)
        IDENTIFIER="Intel Graphics"
        DRIVER="modesetting"
        ;;
    amd)
        IDENTIFIER="AMD Graphics"
        DRIVER="amdgpu"
        ;;
    nvidia)
        IDENTIFIER="NVIDIA Graphics"
        DRIVER="nvidia"
        ACCEL="nouveau"
        ;;
    mali)
        IDENTIFIER="ARM Mali Graphics"
        DRIVER="panfrost"
        ;;
    adreno)
        IDENTIFIER="Qualcomm Adreno Graphics"
        DRIVER="freedreno"
        ;;
    mediatek)
        IDENTIFIER="MediaTek GPU"
        DRIVER="panfrost"
        ;;
    vivante)
        IDENTIFIER="Vivante GPU"
        DRIVER="etnaviv"
        ;;
    *)
        IDENTIFIER="Generic GPU"
        DRIVER="modesetting"
        ;;
esac

sudo tee "$XORG_CONF_DIR/20-glamor.conf" > /dev/null <<EOF
Section "Device"
    Identifier "$IDENTIFIER"
    Driver "$DRIVER"
EOF

if [[ -n "$ACCEL" ]]; then
    echo "    Option \"AccelMethod\" \"$ACCEL\"" | sudo tee -a "$XORG_CONF_DIR/20-glamor.conf" > /dev/null
fi

echo "EndSection" | sudo tee -a "$XORG_CONF_DIR/20-glamor.conf" > /dev/null

if [[ -n "$GPU_VENDOR" && "$GPU_VENDOR" != "unknown" ]]; then
    echo "${BLUE}Detected GPU:${RESET}${GREEN} $GPU_VENDOR ($ARCH)${RESET}"
else
    echo "${YELLOW}Warning:${RESET}${RED} GPU not detected. Using generic Xorg configuration.${RESET}"
fi

sudo mkdir -p "$CHARD_ROOT/tmp/.X11-unix"
sudo chmod 1777 "$CHARD_ROOT/tmp/.X11-unix"


echo "${RESET}${BLUE}[+] Mounting Chard Chroot${RESET}"
sudo cp /etc/resolv.conf "$CHARD_ROOT/etc/resolv.conf"

echo "${RESET}${BLUE}${BOLD}Setting up Emerge!"
sudo mkdir -p "$CHARD_ROOT/var/lib/portage/"
sudo touch "$CHARD_ROOT/var/lib/portage/world"

sudo chroot $CHARD_ROOT /bin/bash -c "

    mountpoint -q /proc       || mount -t proc proc /proc 2>/dev/null
    mountpoint -q /sys        || mount -t sysfs sys /sys 2>/dev/null
    mountpoint -q /dev        || mount -t devtmpfs devtmpfs /dev 2>/dev/null
    mountpoint -q /dev/shm    || mount -t tmpfs tmpfs /dev/shm 2>/dev/null
    mountpoint -q /dev/pts    || mount -t devpts devpts /dev/pts 2>/dev/null
    mountpoint -q /dev/input  || mount --bind /dev/input 2>/dev/null
    mountpoint -q /etc/ssl    || mount --bind /etc/ssl /etc/ssl 2>/dev/null
    mountpoint -q /run/dbus   || mount --bind /run/dbus /run/dbus 2>/dev/null

                        
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
    CHARD_USER=\$(cat /.chard_user)
    HOME=\$CHARD_HOME
    USER=\$CHARD_USER
    source \$HOME/.bashrc 2>/dev/null
    mkdir -p /var/db/pkg /var/lib/portage
    chown -R portage:portage /var/db/pkg /var/lib/portage
    chmod -R 755 /var/db/pkg
    chmod 644 /var/lib/portage/world

    emerge --sync
    /bin/SMRT
    source \$HOME/.smrt_env.sh

    umount -l /run/chrome  2>/dev/null || true
    umount -l /run/dbus    2>/dev/null || true
    umount -l /etc/ssl     2>/dev/null || true
    umount -l /dev/input   2>/dev/null || true
    umount -l /dev/pts     2>/dev/null || true
    umount -l /dev/shm     2>/dev/null || true
    umount -l /dev         2>/dev/null || true
    umount -l /sys         2>/dev/null || true
    umount -l /proc        2>/dev/null || true
"

sudo mv "$CHARD_ROOT/usr/lib/libcrypt.so" "$CHARD_ROOT/usr/lib/libcrypt.so.bak" 2>/dev/null
sudo mkdir -p $CHARD_ROOT/etc/sudoers.d/
echo "$CHARD_USER ALL=(ALL) NOPASSWD: ALL" | sudo tee $CHARD_ROOT/etc/sudoers.d/$CHARD_USER > /dev/null

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

                        groupdel alarm 2>/dev/null
                        groupdel audio 2>/dev/null
                        groupdel video 2>/dev/null
                        groupdel input 2>/dev/null
                        groupdel lp 2>/dev/null
                        
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
                        getent group portage >/dev/null || groupadd -g 250 portage 2>/dev/null
                        getent group steam >/dev/null || groupadd -g 20001 steam 2>/dev/null
                        getent group render >/dev/null || groupadd -g 989 render 2>/dev/null
                        getent group 222  >/dev/null    || groupadd -g 222 input 2>/dev/null
                        getent group 238 >/dev/null     || groupadd -g 238 hidraw 2>/dev/null
                        getent group 213 >/dev/null     || groupadd -g 213 cros-disks 2>/dev/null



                        if ! id \"\$CHARD_USER\" &>/dev/null; then
                            useradd -u 1000 -g 1000 -d \"/\$CHARD_HOME\" -M -s /bin/bash \"\$CHARD_USER\"
                        fi

                        usermod -aG chronos,wayland,arc-bridge,arc-keymintd,arc-sensor,android-everybody,audio,input,lp,video,bluetooth-audio,cras,usb,traced-producer,traced-consumer,chronos-access,brltty,arcvm-boot-notification-server,arc-mojo-proxy,arc-host-clock,midis,suzy-q,ml-core,fuse-archivemount,crash,crash-access,crash-user-access,fuse-drivefs,regmond_senders,arc-camera,camera,pkcs11,policy-readers,arc-keymasterd,debugfs-access,portage,steam,render,input,hidraw,cros-disks \$CHARD_USER
                        
                        mkdir -p \"/\$CHARD_HOME\"
                        chown \$USER:\$USER \"/\$CHARD_HOME\"
        
                        emerge app-admin/sudo
        
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
                
echo "$CHARD_USER ALL=(ALL) NOPASSWD: ALL" | sudo tee $CHARD_ROOT/etc/sudoers.d/$CHARD_USER > /dev/null

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
    source \$HOME/.smrt_env.sh
    chown -R 1000:1000 \$HOME/
    emerge app-portage/gentoolkit
    emerge app-misc/resolve-march-native && \
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

ARCH=$(uname -m)
detect_gpu_freq() {
    GPU_FREQ_PATH=""
    GPU_MAX_FREQ=""
    GPU_TYPE="unknown"

    if [ -f "/sys/class/drm/card0/gt_max_freq_mhz" ]; then
        GPU_FREQ_PATH="/sys/class/drm/card0/gt_max_freq_mhz"
        GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
        GPU_TYPE="intel"
        return
    fi

    if [ -f "/sys/class/drm/card0/device/pp_dpm_sclk" ]; then
        GPU_TYPE="nvidia"
        PP_DPM_SCLK="/sys/class/drm/card0/device/pp_dpm_sclk"
        MAX_MHZ=$(grep -o '[0-9]\+' "$PP_DPM_SCLK" | sort -nr | head -n1)
        GPU_MAX_FREQ="$MAX_MHZ"
        GPU_FREQ_PATH="$PP_DPM_SCLK"
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
        return
    fi

    if [[ -d /sys/class/drm ]]; then
        if grep -qi "mediatek" /sys/class/drm/*/device/uevent 2>/dev/null; then
            GPU_TYPE="mediatek"
            return
        elif grep -qi "vivante" /sys/class/drm/*/device/uevent 2>/dev/null; then
            GPU_TYPE="vivante"
            return
        elif grep -qi "asahi" /sys/class/drm/*/device/uevent 2>/dev/null; then
            GPU_TYPE="asahi"
            return
        elif grep -qi "panfrost" /sys/class/drm/*/device/uevent 2>/dev/null; then
            GPU_TYPE="mali"
            return
        fi
    fi

    for d in /sys/class/devfreq/*; do
        if grep -qi 'mali' <<< "$d" || grep -qi 'gpu' <<< "$d"; then
            if [ -f "$d/max_freq" ]; then
                GPU_FREQ_PATH="$d/max_freq"
                GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
                GPU_TYPE="mali"
                return
            elif [ -f "$d/available_frequencies" ]; then
                GPU_FREQ_PATH="$d/available_frequencies"
                GPU_MAX_FREQ=$(tr ' ' '\n' < "$GPU_FREQ_PATH" | sort -nr | head -n1)
                GPU_TYPE="mali"
                return
            fi
        fi
    done

    if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
        if [ -f "/sys/class/kgsl/kgsl-3d0/max_gpuclk" ]; then
            GPU_FREQ_PATH="/sys/class/kgsl/kgsl-3d0/max_gpuclk"
            GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
            GPU_TYPE="adreno"
            return
        elif [ -f "/sys/class/kgsl/kgsl-3d0/gpuclk" ]; then
            GPU_FREQ_PATH="/sys/class/kgsl/kgsl-3d0/gpuclk"
            GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
            GPU_TYPE="adreno"
            return
        fi
    fi

    GPU_TYPE="unknown"
}

detect_gpu_freq
GPU_VENDOR="$GPU_TYPE"

case "$ARCH" in
    x86_64)
        case "$GPU_VENDOR" in
            amd)
                CONFIG_DRM_AMDGPU=y
                CONFIG_DRM_I915=n
                CONFIG_DRM_NOUVEAU=n
                CONFIG_LAVAPIPE=n
                CONFIG_KVM_INTEL=n
                CONFIG_KVM_AMD=y
                ;;
            intel)
                CONFIG_DRM_AMDGPU=n
                CONFIG_DRM_I915=y
                CONFIG_DRM_NOUVEAU=n
                CONFIG_LAVAPIPE=n
                CONFIG_KVM_INTEL=y
                CONFIG_KVM_AMD=n
                ;;
            nvidia)
                CONFIG_DRM_AMDGPU=n
                CONFIG_DRM_I915=n
                CONFIG_DRM_NOUVEAU=y
                CONFIG_LAVAPIPE=n
                CONFIG_KVM_INTEL=n
                CONFIG_KVM_AMD=n
                ;;
            *)
                CONFIG_DRM_AMDGPU=n
                CONFIG_DRM_I915=n
                CONFIG_DRM_NOUVEAU=n
                CONFIG_LAVAPIPE=y
                CONFIG_KVM_INTEL=n
                CONFIG_KVM_AMD=n
                ;;
        esac

sudo tee "$CHARD_ROOT/usr/src/linux/enable_features.cfg" > /dev/null <<EOF
CONFIG_SWAP=y
CONFIG_DRM=y
CONFIG_SWAPFILESYSTEM=y
CONFIG_ZRAM=y
CONFIG_BLK_DEV_RAM=y
CONFIG_MMU=y
CONFIG_ZRAM_WRITEBACK=y
CONFIG_CGROUP_SWAP=y 
CONFIG_PROC_FS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_DRM_I915=$CONFIG_DRM_I915
CONFIG_DRM_AMDGPU=$CONFIG_DRM_AMDGPU
CONFIG_DRM_NOUVEAU=$CONFIG_DRM_NOUVEAU
CONFIG_LAVAPIPE=$CONFIG_LAVAPIPE
CONFIG_NAMESPACES=y
CONFIG_USER_NS=y
CONFIG_UID_MAP=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_IPC_NS=y
CONFIG_MNT_NS=y
CONFIG_UTS_NS=y
CONFIG_KEYS_NS=y
CONFIG_CGROUP_NS=y
CONFIG_SECCOMP=y
CONFIG_SECCOMP_FILTER=y
CONFIG_BPF=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT=y
CONFIG_CGROUP_BPF=y
CONFIG_FHANDLE=y
CONFIG_FANOTIFY=y
CONFIG_EPOLL=y
CONFIG_INOTIFY_USER=y
CONFIG_NET=y
CONFIG_FUSE_FS=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT2=y
CONFIG_FS_POSIX_ACL=y
CONFIG_FS_SECURITY=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_KEY_DH_OPERATIONS=y
CONFIG_VIDEO_DEV=y
CONFIG_DRM_GEM_SHMEM_HELPER=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=$CONFIG_KVM_INTEL
CONFIG_KVM_AMD=$CONFIG_KVM_AMD
CONFIG_TUN=y
CONFIG_ARM_MALI=n
CONFIG_DRM_ROCKCHIP=n
CONFIG_DRM_ARM_DC=n
EOF
        ;;
    aarch64)
        case "$GPU_VENDOR" in
            mali)
                CONFIG_DRM_MALI=y
                CONFIG_DRM_ROCKCHIP=n
                CONFIG_DRM_ARM_DC=n
                CONFIG_DRM_MSM=n
                CONFIG_DRM_ETNAVIV=n
                CONFIG_LAVAPIPE=n
                CONFIG_DRM_MEDIATEK=n
                CONFIG_DRM_MEDIATEK_HDMI=n
                CONFIG_MEDIATEK_CMDQ=n
                CONFIG_MTK_CMDQ_MBOX=n
                CONFIG_MTK_IOMMU=n
                CONFIG_DRM_PANFROST=y
                ;;
            adreno)
                CONFIG_DRM_MALI=n
                CONFIG_DRM_ROCKCHIP=n
                CONFIG_DRM_ARM_DC=n
                CONFIG_DRM_MSM=y
                CONFIG_DRM_ETNAVIV=n
                CONFIG_LAVAPIPE=n
                CONFIG_DRM_MEDIATEK=n
                CONFIG_DRM_MEDIATEK_HDMI=n
                CONFIG_MEDIATEK_CMDQ=n
                CONFIG_MTK_CMDQ_MBOX=n
                CONFIG_MTK_IOMMU=n
                CONFIG_DRM_PANFROST=n
                ;;
            mediatek)
                CONFIG_DRM_MALI=n
                CONFIG_DRM_ROCKCHIP=n
                CONFIG_DRM_ARM_DC=n
                CONFIG_DRM_MSM=n
                CONFIG_DRM_ETNAVIV=n
                CONFIG_LAVAPIPE=n
                CONFIG_DRM_MEDIATEK=y
                CONFIG_DRM_MEDIATEK_HDMI=y
                CONFIG_MEDIATEK_CMDQ=y
                CONFIG_MTK_CMDQ_MBOX=y
                CONFIG_MTK_IOMMU=y
                CONFIG_DRM_PANFROST=y
                
                ;;
            vivante)
                CONFIG_DRM_MALI=n
                CONFIG_DRM_ROCKCHIP=n
                CONFIG_DRM_ARM_DC=n
                CONFIG_DRM_MSM=n
                CONFIG_DRM_ETNAVIV=y
                CONFIG_LAVAPIPE=n
                CONFIG_DRM_MEDIATEK=n
                CONFIG_DRM_MEDIATEK_HDMI=n
                CONFIG_MEDIATEK_CMDQ=n
                CONFIG_MTK_CMDQ_MBOX=n
                CONFIG_MTK_IOMMU=n
                CONFIG_DRM_PANFROST=n
                ;;
            *)
                CONFIG_DRM_MALI=n
                CONFIG_DRM_ROCKCHIP=n
                CONFIG_DRM_ARM_DC=n
                CONFIG_DRM_MSM=n
                CONFIG_DRM_ETNAVIV=n
                CONFIG_LAVAPIPE=y
                CONFIG_DRM_MEDIATEK=n
                CONFIG_DRM_MEDIATEK_HDMI=n
                CONFIG_MEDIATEK_CMDQ=n
                CONFIG_MTK_CMDQ_MBOX=n
                CONFIG_MTK_IOMMU=n
                CONFIG_DRM_PANFROST=n
                ;;
        esac
        
sudo tee "$CHARD_ROOT/usr/src/linux/enable_features.cfg" > /dev/null <<EOF
CONFIG_SWAP=y
CONFIG_DRM=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_SWAPFILESYSTEM=y
CONFIG_ZRAM=y
CONFIG_BLK_DEV_RAM=y
CONFIG_MMU=y
CONFIG_ZRAM_WRITEBACK=y
CONFIG_CGROUP_SWAP=y 
CONFIG_PROC_FS=y
CONFIG_SYSFS=y
CONFIG_DRM_MALI=$CONFIG_DRM_MALI
CONFIG_DRM_ROCKCHIP=$CONFIG_DRM_ROCKCHIP
CONFIG_DRM_ARM_DC=$CONFIG_DRM_ARM_DC
CONFIG_DRM_MSM=$CONFIG_DRM_MSM
CONFIG_DRM_ETNAVIV=$CONFIG_DRM_ETNAVIV
CONFIG_DRM_AMDGPU=n
CONFIG_DRM_I915=n
CONFIG_DRM_NOUVEAU=n
CONFIG_LAVAPIPE=$CONFIG_LAVAPIPE
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_NAMESPACES=y
CONFIG_USER_NS=y
CONFIG_UID_MAP=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_IPC_NS=y
CONFIG_MNT_NS=y
CONFIG_UTS_NS=y
CONFIG_KEYS_NS=y
CONFIG_CGROUP_NS=y
CONFIG_SECCOMP=y
CONFIG_SECCOMP_FILTER=y
CONFIG_BPF=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT=y
CONFIG_CGROUP_BPF=y
CONFIG_FHANDLE=y
CONFIG_FANOTIFY=y
CONFIG_EPOLL=y
CONFIG_INOTIFY_USER=y
CONFIG_NET=y
CONFIG_FUSE_FS=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT2=y
CONFIG_FS_POSIX_ACL=y
CONFIG_FS_SECURITY=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_KEY_DH_OPERATIONS=y
CONFIG_VIDEO_DEV=y
CONFIG_KVM=y
CONFIG_KVM_ARM_HOST=y
CONFIG_TUN=y
CONFIG_DRM_MEDIATEK=$CONFIG_DRM_MEDIATEK
CONFIG_DRM_MEDIATEK_HDMI=$CONFIG_DRM_MEDIATEK_HDMI
CONFIG_MEDIATEK_CMDQ=$CONFIG_MEDIATEK_CMDQ
CONFIG_MTK_CMDQ_MBOX=$CONFIG_MTK_CMDQ_MBOX
CONFIG_MTK_IOMMU=$CONFIG_MTK_IOMMU
CONFIG_DEVFREQ_THERMAL=y
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DRM_GEM_SHMEM_HELPER=y
EOF
        ;;
    *)
        echo "${RED}Unknown architecture: $ARCH${RESET}"
        exit 1
        ;;
esac

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
sudo tee -a "$CHARD_ROOT/etc/env.d/99python-fork" <<< 'export PYTHONMULTIPROCESSING_START_METHOD=fork'

WAYLAND_CONF_DIR="$CHARD_ROOT/etc/profile.d"
sudo mkdir -p "$WAYLAND_CONF_DIR"

WAYLAND_CONF_FILE="$WAYLAND_CONF_DIR/wayland_gpu.sh"
sudo tee "$WAYLAND_CONF_FILE" > /dev/null <<EOF
#!/bin/sh
# Wayland GPU environment setup for Chard
EOF

case "$GPU_TYPE" in
    intel)
        DRIVER="iris"
        echo "export MESA_LOADER_DRIVER_OVERRIDE='iris i965 i915'" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
        ;;
    amd)
        DRIVER="radeonsi"
        echo "export MESA_LOADER_DRIVER_OVERRIDE='radeonsi r600'" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
        ;;
    nvidia)
        DRIVER="nouveau"
        echo "export MESA_LOADER_DRIVER_OVERRIDE='nouveau nvk'" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
        ;;
    mali)
        DRIVER="panfrost"
        echo "export MESA_LOADER_DRIVER_OVERRIDE='panfrost lima'" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
        ;;
    adreno)
        DRIVER="freedreno"
        echo "export MESA_LOADER_DRIVER_OVERRIDE='freedreno'" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
        ;;
   mediatek)
        DRIVER="panfrost"
        sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null <<'EOF'
export DRIVER="panfrost"
export MESA_LOADER_DRIVER_OVERRIDE=panfrost,lima
export MALI_PLATFORM_CONFIG=/etc/mali_platform.conf
EOF
    ;;

    vivante)
        DRIVER="etnaviv"
        echo "export MESA_LOADER_DRIVER_OVERRIDE='etnaviv'" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
        ;;
    *)
        DRIVER="llvmpipe"
        echo "export LIBGL_ALWAYS_SOFTWARE=1" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
        echo "export MESA_LOADER_DRIVER_OVERRIDE='llvmpipe'" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
        if [[ "$ARCH" == "x86_64" ]]; then
            echo "export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
        fi
        ;;
esac

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

sudo mkdir -p "$CHARD_ROOT/etc/portage/env"
sudo mkdir -p "$CHARD_ROOT/etc/portage/package.env"

echo "dev-lang/perl ~$(arch)" | sudo tee -a "$CHARD_ROOT/etc/portage/package.accept_keywords/perl" >/dev/null
echo "export SOMMELIER_USE_WAYLAND=1" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
sudo chmod +x "$WAYLAND_CONF_FILE"
echo "${MAGENTA}Detected GPU: $GPU_VENDOR ($ARCH)${RESET}"

PULSEHOME="$CHARD_ROOT/$CHARD_HOME/.config/pulse"
sudo mkdir -p "$PULSEHOME"
sudo tee "${PULSEHOME}/default.pa" > /dev/null <<'EOF'
#!/usr/bin/pulseaudio -nF
# Copyright (c) 2016 The crouton Authors. All rights reserved.
.include /etc/pulse/default.pa
load-module module-alsa-sink device=cras sink_name=cras-sink
load-module module-alsa-source device=cras source_name=cras-source
set-default-sink cras-sink
set-default-source cras-source
EOF
    
sudo chown -R 1000:1000 "${PULSEHOME}"
sudo chown 1000:1000 $CHARD_ROOT/$CHARD_HOME/.bashrc            

source "$CHARD_ROOT/.chardrc"

if [ -f "/home/chronos/user/.bashrc" ]; then
    sudo mountpoint -q "$CHARD_ROOT/run/chrome" || sudo mount --bind /run/chrome "$CHARD_ROOT/run/chrome" 2>/dev/null
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

sudo ln -s $CHARD_ROOT/usr/lib/python-exec /usr/lib/python-exec 2>/dev/null

sudo mkdir -p $CHARD_ROOT/usr/lib64
sudo mkdir -p $CHARD_ROOT/usr/share/vulkan/icd.d
sudo mkdir -p $CHARD_ROOT/etc/portage/env
#sudo mkdir -p $CHARD_ROOT/etc/portage/package.env/sys-libs

#sudo tee "$CHARD_ROOT/etc/portage/env/glibc.conf" > /dev/null <<'EOF'
#LDFLAGS="${LDFLAGS} -Wl,--pack-dyn-relocs=relr"
#EOF

#sudo tee "$CHARD_ROOT/etc/portage/package.env/sys-libs/glibc" > /dev/null <<'EOF'
#glibc.conf
#EOF

if [[ "$(uname -m)" == "aarch64" ]]; then
    sudo cp /usr/lib64/libmali.so "$CHARD_ROOT/usr/lib64/" 2>/dev/null
    sudo cp /usr/lib64/libmali.so.0 "$CHARD_ROOT/usr/lib64/" 2>/dev/null
    sudo cp /usr/lib64/libmali.so.0.44.1 "$CHARD_ROOT/usr/lib64/" 2>/dev/null
    sudo cp /usr/share/vulkan/icd.d/mali_icd.json "$CHARD_ROOT/usr/share/vulkan/icd.d/" 2>/dev/null
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
        cleanup() {
            echo \"Logging out $USER\"
        }
        trap cleanup EXIT INT TERM
        source \$HOME/.bashrc 2>/dev/null
        source \$HOME/.smrt_env.sh 2>/dev/null
        sudo chown -R 1000:1000 $HOME
        sudo -E /bin/chariot
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
$CHARD_ROOT/bin/chard_preload
CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
if [ -f "$CHROMEOS_BASHRC" ]; then
    CHROME_MILESTONE=$(grep '^CHROMEOS_RELEASE_CHROME_MILESTONE=' /etc/lsb-release | cut -d'=' -f2)
    echo "$CHROME_MILESTONE" | sudo tee "$CHARD_ROOT/.chard_chrome" > /dev/null
    sudo ln -sf /usr/local/chard/usr/bin/xkbcomp /usr/bin/xkbcomp 2>/dev/null
fi

sudo cp /etc/asound.conf $CHARD_ROOT/etc 2>/dev/null
sudo mkdir -p $CHARD_ROOT/etc/pulse/default.pa.d/
sudo mkdir -p $CHARD_ROOT/etc/pulse/

sudo tee $CHARD_ROOT/etc/pulse/default.pa.d/10-cras.pa > /dev/null << 'EOF'
load-module module-alsa-sink device=default sink_name=cras_sink
set-default-sink cras_sink
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
    "$CHARD_ROOT/etc/pulse/daemon.conf" 2>/dev/null

sudo cp $CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa $CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa.bak.$(date +%s) 2>/dev/null
grep -qxF ".include /etc/pulse/default.pa" "$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa" 2>/dev/null || \
( sed '/^\.fail$/a\.include /etc/pulse/default.pa' "$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa" 2>/dev/null > "$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa.tmp" && \
mv "$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa.tmp" "$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa" )
sudo mkdir -p $CHARD_ROOT/usr/share/file/misc
sudo ln -sf $CHARD_ROOT/usr/share/misc/magic.mgc $CHARD_ROOT/usr/share/file/misc/magic.mgc
echo "${GREEN}[+] Chard Root is ready! To use, open a new shell and run: ${BOLD}chard root${RESET}"
if [[ "$(uname -m)" == "aarch64" ]]; then
    echo "${YELLOW}[!] ARM64 Devices might need to reboot ChromeOS before proceeding. ${RESET}"
fi
show_progress
sudo cp "$CHARD_ROOT/chardbuild.log" ~/
echo "${YELLOW}Copied chardbuild.log to $HOME ${RESET}"
echo "${GREEN}[+] Chard Root is ready! To use, open a new shell and run: ${BOLD}chard root${RESET}"
if [[ "$(uname -m)" == "aarch64" ]]; then
    echo "${YELLOW}[!] ARM64 Devices might need to reboot ChromeOS before proceeding. ${RESET}"
fi
