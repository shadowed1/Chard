#!/bin/bash

RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

echo
echo "${YELLOW}Welcome to Chard Repair. This does not remove any files, it just updates Chard Markers. ${RESET}"
echo

DEFAULT_CHARD_ROOT="/usr/local/chard"

if [ -n "$CHARD_ROOT" ] && [ -f "$CHARD_ROOT/.install_path" ]; then
    CHARD_ROOT=$(sudo cat "$CHARD_ROOT/.install_path")
    echo -e "${CYAN}Found existing Install Path: ${BOLD}$CHARD_ROOT${RESET}"
elif [ -f "$DEFAULT_CHARD_ROOT/.install_path" ]; then
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

CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
DEFAULT_BASHRC="$HOME/.bashrc"
TARGET_FILE=""
        
if [ -f "$CHROMEOS_BASHRC" ]; then
    TARGET_FILE="$CHROMEOS_BASHRC"
elif [ -f "$DEFAULT_BASHRC" ]; then
    TARGET_FILE="$DEFAULT_BASHRC"
fi

echo "${RESET}${CYAN}Detected .bashrc: ${BOLD}${TARGET_FILE}${RESET}"
CHARD_HOME="$(dirname "$TARGET_FILE")"
CHARD_HOME="${CHARD_HOME#/}"

if [[ "$CHARD_HOME" == home/* ]]; then
    CHARD_HOME="${CHARD_HOME%%/user*}"

    CHARD_USER="${CHARD_HOME#*/}"
fi

echo "${CYAN}[*] Downloading Chard components...${RESET}"
echo ""
BASE_URL="https://raw.githubusercontent.com/shadowed1/Chard/main"
				
			FILES=(
				    "Gentoo/.chardrc|$CHARD_ROOT/.chardrc|0"
				    "Gentoo/.chard.env|$CHARD_ROOT/.chard.env|0"
				    "bin/Uninstall_Chard.sh|$CHARD_ROOT/bin/Uninstall_Chard.sh|1"
				    "Gentoo/chard.sh|$CHARD_ROOT/bin/chard|1"
				    "Gentoo/.bashrc|$CHARD_ROOT/$CHARD_HOME/.bashrc|0"
				    "bin/chard_version|$CHARD_ROOT/bin/chard_version|1"
				    "LICENSE|$CHARD_ROOT/$CHARD_HOME/CHARD_LICENSE|0"
				    "Gentoo/.rootrc|$CHARD_ROOT/.rootrc|1"
				    "Gentoo/chariot.sh|$CHARD_ROOT/bin/chariot|1"
				    "bin/chard_debug.sh|$CHARD_ROOT/bin/chard_debug|1"
				    "Gentoo/chard_sommelier.sh|$CHARD_ROOT/bin/chard_sommelier|1"
				    "bin/chard_scale.sh|$CHARD_ROOT/bin/chard_scale|1"
				    "bin/wx|$CHARD_ROOT/bin/wx|1"
				    "Gentoo/SMRT.sh|$CHARD_ROOT/bin/SMRT|1"
				    "bin/chard_mount|$CHARD_ROOT/bin/chard_mount|1"
				    "bin/chard_unmount|$CHARD_ROOT/bin/chard_unmount|1"
				    "bin/chard_volume.sh|$CHARD_ROOT/bin/chard_volume|1"
				    "bin/chardwire.sh|$CHARD_ROOT/bin/chardwire|1"
				    "Gentoo/.chard.preload|$CHARD_ROOT/.chard.preload|1"
				    "bin/chard_preload.sh|$CHARD_ROOT/bin/chard_preload|1"
					"Gentoo/chard_wrappers.sh|$CHARD_ROOT/bin/chard_wrappers|1"
					"bin/chard_svg.sh|$CHARD_ROOT/bin/chard_svg|1"
					"bin/chard_downgrade_bwrap_flatpak.sh|$CHARD_ROOT/bin/chard_downgrade_bwrap_flatpak|1"
					"bin/chard_mtp_mount.sh|$CHARD_ROOT/bin/chard_mtp_mount|1"
					"bin/autoclicker.c|$CHARD_ROOT/tmp/chard_startup|1"
					"bin/chard_mtp_unmount.sh|$CHARD_ROOT/bin/chard_mtp_unmount|1"
					"bin/virtm.c|$CHARD_ROOT/tmp/virtm.c|1"
					"bin/rainbow.sh|$CHARD_ROOT/bin/rainbow|1"
					"bin/chard_browser.sh|$CHARD_ROOT/bin/chard_browser|1"
				)
        
for entry in "${FILES[@]}"; do
    IFS='|' read -r source target executable <<< "$entry"

    sudo mkdir -p "$(dirname "$target")"

    if sudo curl -fsSL "$BASE_URL/$source" -o "$target"; then
        echo "${BLUE}${BOLD}$target ${RESET}"

        if [ "$executable" = "1" ]; then
            sudo chmod +x "$target"
        fi
    else
        echo "${RED}Failed: ${BOLD}$source ${RESET}"
    fi
done

for file in \
    "$CHARD_ROOT/.chardrc" \
    "$CHARD_ROOT/.chard.env" \
    "$CHARD_ROOT/$CHARD_HOME/.bashrc" \
    "$CHARD_ROOT/.rootrc" \
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

if [ -f "/etc/init/chard.conf" ]; then
    sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard.conf" -o "/etc/init/chard.conf"
    sleep 0.05
    if [ $? -ne 0 ] || [ ! -s "/etc/init/chard.conf" ]; then
        echo ""
        echo "${RED}Failed to download chard.conf${RESET}"
        echo ""
        return 1
    fi
    sudo chmod 644 /etc/init/chard.conf
    sudo initctl reload-configuration 2>/dev/null
fi

if [ -f "/etc/init/chard_baguette.conf" ]; then
    sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_baguette.conf" -o "/etc/init/chard_baguette.conf"
    sleep 0.05
    if [ $? -ne 0 ] || [ ! -s "/etc/init/chard_baguette.conf" ]; then
        echo ""
        echo "${RED}Failed to download chard_baguette.conf${RESET}"
        echo ""
        return 1
    fi
    sudo chmod 644 /etc/init/chard_baguette.conf
    sudo initctl reload-configuration 2>/dev/null
fi
