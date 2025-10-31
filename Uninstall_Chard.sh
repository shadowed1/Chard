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
echo "${GREEN}Chard is uninstalled!${RESET}
