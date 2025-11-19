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
    sudo umount -l "$CHARD_ROOT" 2>/dev/null || true
    sleep 0.2
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

echo "${CYAN}[*] Downloading Chard components...${RESET}"
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/.chardrc"            -o "$CHARD_ROOT/.chardrc"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/.chard.env"          -o "$CHARD_ROOT/.chard.env"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/Reinstall_Chard.sh"  -o "$CHARD_ROOT/bin/Reinstall_Chard.sh"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/Uninstall_Chard.sh"  -o "$CHARD_ROOT/bin/Uninstall_Chard.sh"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/chard.sh"            -o "$CHARD_ROOT/bin/chard"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/.bashrc"             -o "$CHARD_ROOT/$CHARD_HOME/.bashrc"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_version"       -o "$CHARD_ROOT/$CHARD_HOME/chard_version"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/LICENSE"             -o "$CHARD_ROOT/$CHARD_HOME/CHARD_LICENSE"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/.rootrc"             -o "$CHARD_ROOT/bin/.rootrc"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/chariot.sh"          -o "$CHARD_ROOT/bin/chariot"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_debug.sh"      -o "$CHARD_ROOT/bin/chard_debug"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/chard_sommelier.sh"  -o "$CHARD_ROOT/bin/chard_sommelier"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_scale.sh"      -o "$CHARD_ROOT/bin/chard_scale"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/wx"                  -o "$CHARD_ROOT/bin/wx"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/SMRT.sh"                  -o "$CHARD_ROOT/bin/SMRT"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_mount"         -o "$CHARD_ROOT/bin/chard_mount"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_unmount"       -o "$CHARD_ROOT/bin/chard_unmount"
sleep 0.2
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/chardsetup.sh"       -o "$CHARD_ROOT/bin/chardsetup"
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
    else
        echo "${YELLOW}[!] Chard already sourced in $FILE"
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

                echo "${MAGENTA}[*] Quick reinstall complete.${RESET}"
                ;;
            2)
                echo "${RESET}${YELLOW}[*] Performing full reinstall..."
                bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_download?$(date +%s)")
                ;;
            q|Q|*)
                echo "${RESET}${RED}[*] Reinstall cancelled.${RESET}"
                ;;
         esac
