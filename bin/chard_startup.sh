#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

if ls /.chard* > /dev/null 2>&1; then
    echo "${RED}chard_startup must be run from the host shell, not inside Chard.${RESET}"
    sleep 3
    exit 1
fi

CHARD_USER=$(awk -F: '$3 == 1000 {print $1}' /etc/passwd)
CHARD_USER="${CHARD_USER:-chronos}"

if [ -f "/home/chronos/user/.bashrc" ]; then
    BASHRC="/home/chronos/user/.bashrc"
elif [ -f "/home/$CHARD_USER/.bashrc" ]; then
    BASHRC="/home/$CHARD_USER/.bashrc"
else
    echo "${RED}Error: Could not find .bashrc — please run this from the Host shell.${RESET}"
    sleep 3
    exit 1
fi

TEST_FILE="/etc/init/.boot_test"
if ! sudo touch "$TEST_FILE" 2>/dev/null; then
    echo "${RED}Rootfs is not writable — rootfs verification must be disabled first.${RESET}"
    echo ""
    read -rp "${BLUE}${BOLD}Disable rootfs verification now? Enter counts as yes! ${RESET}${BOLD}(Y/n): ${RESET}" verify
    echo ""
    case "$verify" in
        [Yy]* | "")
            sudo /usr/libexec/debugd/helpers/dev_features_rootfs_verification
            echo ""
            echo "${GREEN}Done. Please ${BOLD}${YELLOW}REBOOT${RESET}${GREEN} and re-run ${BOLD}chard_startup${RESET}${GREEN} to complete boot setup.${RESET}"
            exit 0
            ;;
        [Nn]*)
            echo "${BLUE}Skipping boot setup.${RESET}"
            exit 0
            ;;
        *)
            echo "${RED}Please answer Y/n.${RESET}"
            sleep 2
            exit 1
            ;;
    esac
fi
sudo rm -f "$TEST_FILE"

echo ""
read -rp "${GREEN}${BOLD}Start Chard automatically on boot? Enter counts as yes! ${RESET}${BOLD}(Y/n): ${RESET}" confirm
echo ""

case "$confirm" in
    [Yy]* | "")
        ;;
    [Nn]*)
        echo "${BLUE}Skipping boot setup.${RESET}"
        echo
        exit 0
        ;;
    *)
        echo "${RED}Please answer Y/n.${RESET}"
        sleep 2
        echo
        exit 1
        ;;
esac
sleep 0.05
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard.conf" -o "/etc/init/chard.conf"

if [ $? -ne 0 ]; then
    echo
    echo "${RED}Failed to download chard.conf${RESET}"
    echo
    exit 1
fi
sudo chmod 644 /etc/init/chard.conf
sudo initctl reload-configuration 2>/dev/null
echo
echo "${GREEN}Chard startup enabled. ${RESET}"
echo
