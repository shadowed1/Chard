#!/bin/bash
# Chard Uninstaller

# <<< CHARD_ROOT_MARKER >>>
CHARD_ROOT=""
CHARD_HOME=""
CHARD_USER=""
# <<< END_CHARD_ROOT_MARKER >>>

read -r -p "${RED}${BOLD}Are you sure you want to remove $CHARD_ROOT and chard entries from ~/.bashrc? [y/N] ${RESET}" ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            
    echo "${RESET}${RED}[*] Unmounting active bind mounts...${RESET}"

    unset LD_PRELOAD
    
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
    
    echo "${RED}[*] Removing $CHARD_ROOT...${RESET}"
    sudo rm -rf "$CHARD_ROOT"
    
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
    fi
    
        echo "${CYAN}[+] Uninstalled ${RESET}"
    else
        echo "${RED}[*] Cancelled.${RESET}"
    fi
