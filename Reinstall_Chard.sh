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
    sudo umount -l "$CHARD_ROOT/tmp/usb_mount" 2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/run/user/1000" 2>/dev/null || true
    sudo umount -l -f "$CHARD_ROOT/$CHARD_HOME/bwrap" 2>/dev/null || true
}

trap cleanup_chroot EXIT INT TERM
