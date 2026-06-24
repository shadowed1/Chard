#!/bin/bash
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'


chard_boot_setup() {
    local TEST_FILE="/etc/init/.boot_test"
    local CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
    if [ ! -f "$CHROMEOS_BASHRC" ]; then
        echo "${GREEN}Skipping boot setup, not ChromeOS!${RESET}"
        return 0
    fi
    if ! sudo touch "$TEST_FILE" 2>/dev/null; then
        echo "${RED}Rootfs verification must be disabled for on-boot startup.${RESET}"
        echo ""
        while true; do
            read -rp "${BLUE}${BOLD}Disable rootfs verification now? Enter counts as yes! ${RESET}${BOLD}(Y/n): ${RESET}" verify
            echo ""
            case "$verify" in
                [Yy]* | "")
                    sudo /usr/libexec/debugd/helpers/dev_features_rootfs_verification
                    echo ""
                    echo "${GREEN}After install is finished, reboot and run ${BOLD}${YELLOW}chard_startup${RESET}${GREEN} to enable automatic startup.${RESET}"
                    echo ""
                    return 0
                    ;;
                [Nn]*)
                    echo "${BLUE}Skipping boot setup.${RESET}"
                    echo ""
                    return 0
                    ;;
                *)
                    echo "${RED}Please answer Y/n.${RESET}"
                    echo ""
                    ;;
            esac
        done
    fi
    sudo rm -f "$TEST_FILE"
    echo ""
    while true; do
        read -rp "${GREEN}${BOLD}Start Chard automatically on boot? Enter counts as yes! ${RESET}${BOLD}(Y/n): ${RESET}" confirm
        echo ""
        case "$confirm" in
            [Yy]* | "")
                break
                ;;
            [Nn]*)
                echo "${BLUE}Skipping boot setup.${RESET}"
                echo ""
                return 0
                ;;
            *)
                echo "${RED}Please answer Y/n.${RESET}"
                echo ""
                ;;
        esac
    done
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

    if vmc list 2>/dev/null | grep -q "^termina\b.*baguette"; then
        echo ""
        while true; do
            read -rp "${GREEN}${BOLD}Start Crostini automatically on boot for shortcut support? Enter counts as yes! ${RESET}${BOLD}(Y/n): ${RESET}" baguette_confirm
            echo ""
            case "$baguette_confirm" in
                [Yy]* | "")
                    sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_baguette.conf" -o "/etc/init/chard_baguette.conf"
                    sleep 0.05
                    if [ $? -ne 0 ] || [ ! -s "/etc/init/chard_baguette.conf" ]; then
                        echo "${RED}Failed to download chard_baguette.conf${RESET}"
                        echo ""
                        return 1
                    fi
                    sudo chmod 644 /etc/init/chard_baguette.conf
                    sudo initctl reload-configuration 2>/dev/null
                    echo "${GREEN}Crostini startup enabled.${RESET}"
                    echo ""
                    break
                    ;;
                [Nn]*)
                    echo "${BLUE}Skipping Crostini boot setup.${RESET}"
                    echo ""
                    break
                    ;;
                *)
                    echo "${RED}Please answer Y/n.${RESET}"
                    echo ""
                    ;;
            esac
        done
    fi

    echo "${GREEN}Chard startup enabled.${RESET}"
	echo "${YELLOW}Run: ${BOLD}chard_startup${RESET}${YELLOW} in VT-2 logged in as chronos to change! ${RESET}"
    echo ""
	sleep 4
    return 0
}
chard_boot_setup
