# Chard Uninstaller

# <<< CHARD_ROOT_MARKER >>>
CHARD_ROOT=""
CHARD_HOME=""
CHARD_USER=""
# <<< END_CHARD_ROOT_MARKER >>>

echo "${RESET}${RED}[*] Unmounting active bind mounts...${RESET}"

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
else
    TARGET_FILE="$DEFAULT_BASHRC"
    [ -f "$TARGET_FILE" ] || touch "$TARGET_FILE"
fi

sed -i '/^# <<< CHARD ENV MARKER <<</,/^# <<< END CHARD ENV MARKER <<</d' "$TARGET_FILE"

echo "${GREEN}Chard is uninstalled!${RESET}"
echo
