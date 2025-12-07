#!/bin/bash
# Chard Uninstaller

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

read -r -p "${RED}${BOLD}Remove $CHARD_ROOT and Chard entry from ~/.bashrc? [y/N] ${RESET}" ans

if [[ "$ans" =~ ^[Yy]$ ]]; then
            
        echo "${RESET}${RED}[*] Unmounting active bind mounts...${RESET}"
        unset LD_PRELOAD
            
        sudo umount -l "$CHARD_ROOT/run/cras"   2>/dev/null || true
        sleep 0.2
        sudo umount -l "$CHARD_ROOT/dev/input"  2>/dev/null || true
        sleep 0.2
        sudo umount -l "$CHARD_ROOT/dev/dri"    2>/dev/null || true
        sleep 0.2
        sudo umount -l "$CHARD_ROOT/run/udev"    2>/dev/null || true
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
            
            echo "${RED}[*] Removing $CHARD_ROOT...${RESET}"
            sudo rm -rf "$CHARD_ROOT" 2>/dev/null
            
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
            
        echo "${CYAN}[+] Uninstalled ${RESET}"
else
        echo "${RED}[*] Cancelled.${RESET}"
fi

exit 0
