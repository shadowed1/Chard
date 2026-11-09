#!/bin/bash
# chard_proot.sh - Launch Chard using unshare + pivot_root
# By i-am-days (concept) + proper pivot_root usage

sudo $CHARD_ROOT/bin/killall -9 chard_launch_daemon 2>/dev/null
sudo $CHARD_ROOT/bin/killall -9 chardwire 2>/dev/null
sudo $CHARD_ROOT/bin/killall -9 chard_hidraw 2>/dev/null
CHARD_ROOT="/usr/local/chard"
VERSION_FILE="$CHARD_ROOT/.chard_chrome"
if [ -f "/home/chronos/user/.bashrc" ]; then
    sudo mountpoint -q "$CHARD_ROOT/run/chrome" || sudo mount --bind /run/chrome "$CHARD_ROOT/run/chrome" 2>/dev/null
    sudo umount -l "$CHARD_ROOT/run/chrome/gvfs" 2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/run/chrome/doc" 2>/dev/null || true
    sudo mountpoint -q "$CHARD_ROOT/home/chronos/user/MyFiles/Downloads" || sudo mount --bind "/home/chronos/user/MyFiles/Downloads" "$CHARD_ROOT/home/chronos/user/MyFiles/Downloads" 2>/dev/null
    sudo mount -o remount,rw,bind "$CHARD_ROOT/home/chronos/user/MyFiles/Downloads" 2>/dev/null
    $CHARD_ROOT/bin/chard_mount 2>/dev/null
    $CHARD_ROOT/bin/chard_mtp_mount 2>/dev/null
    sudo chmod 666 /dev/hidraw* 2>/dev/null
else
    sudo mountpoint -q "$CHARD_ROOT/run/user/1000" || sudo mount --bind /run/user/1000 "$CHARD_ROOT/run/user/1000" 2>/dev/null
fi
sudo mountpoint -q "$CHARD_ROOT/run/dbus" || sudo mount --bind /run/dbus "$CHARD_ROOT/run/dbus" 2>/dev/null
sudo mountpoint -q "$CHARD_ROOT/run/udev" || sudo mount --bind /run/udev "$CHARD_ROOT/run/udev" 2>/dev/null
sudo mountpoint -q "$CHARD_ROOT/dev/dri" || sudo mount --bind /dev/dri "$CHARD_ROOT/dev/dri" 2>/dev/null
sudo mountpoint -q "$CHARD_ROOT/dev/input" || sudo mount --bind /dev/input "$CHARD_ROOT/dev/input" 2>/dev/null
if [ -f "/home/chronos/user/.bashrc" ]; then
    sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/cras "$CHARD_ROOT/run/cras" 2>/dev/null
    sudo mount --rbind /usr/bin $CHARD_ROOT/opt/usr/bin 2>/dev/null
    sudo mount --make-rslave $CHARD_ROOT/opt/usr/bin 2>/dev/null
    sudo mount --rbind /usr/lib64 $CHARD_ROOT/opt/usr/lib64 2>/dev/null
    sudo mount --make-rslave $CHARD_ROOT/opt/usr/lib64 2>/dev/null
    sudo mount --rbind /lib64 $CHARD_ROOT/opt/lib64 2>/dev/null
    sudo mount --make-rslave $CHARD_ROOT/opt/lib64 2>/dev/null
    sudo mount --rbind /run $CHARD_ROOT/run 2>/dev/null
    sudo mount --make-rslave $CHARD_ROOT/run 2>/dev/null
else
    sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/user/1000/pulse "$CHARD_ROOT/run/cras" 2>/dev/null
fi
sudo cp /etc/resolv.conf "$CHARD_ROOT/etc/resolv.conf" 2>/dev/null
dbus-send --system --print-reply --dest=org.chromium.ResourceManager /org/chromium/ResourceManager org.chromium.ResourceManager.SetGameMode byte:1 2>/dev/null
sudo unshare --mount --pid --fork --kill-child bash -ec '
    mount --make-rprivate /
    mount --rbind /dev /usr/local/chard/dev
    mount --rbind /sys /usr/local/chard/sys
    mount --rbind /usr/local/chard /usr/local/chard
    install -d -o 1000 -g 1000 -m 700 /usr/local/chard/run/user/1000
    touch /usr/local/chard/run/user/1000/wayland-0
    #touch /usr/local/chard/run/user/1000/DISPLAY-:0-wl
    mkdir -p /usr/local/chard/run/user/1000/pulse
    mount --bind /run/chrome/wayland-0 /usr/local/chard/run/user/1000/wayland-0
    #mount --bind /run/chrome/DISPLAY-:0-wl /usr/local/chard/run/user/1000/DISPLAY-:0-wl
    mount --bind /run/chrome/pulse /usr/local/chard/run/user/1000/pulse
    cd /usr/local/chard
    pivot_root . mnt
    cd /
    mount -t proc proc /proc
    exec sudo -Hu chronos env \
      XDG_RUNTIME_DIR=/run/user/1000 \
      FLATPAK_BWRAP=/var/tmp/bwrap/build/bwrap \
      bash
' 2>&1
