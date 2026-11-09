#!/bin/bash
CHARD_ROOT="/usr/local/chard"
CHARD_HOME=$(cat "$CHARD_ROOT/.chard_home" 2>/dev/null || echo "home")
CHARD_USER=$(cat "$CHARD_ROOT/.chard_user" 2>/dev/null || echo "chronos")
VERSION_FILE="$CHARD_ROOT/.chard_chrome"
export XDG_RUNTIME_DIR="/run/chrome/"
export USER="$CHARD_USER"
export HOME="$CHARD_HOME"

if [ -s "$VERSION_FILE" ]; then
    CHROMEOS_VERSION=$(cat "$VERSION_FILE" 2>/dev/null)
else
    CHROMEOS_VERSION=0
fi

if [ -f "/home/chronos/user/.bashrc" ]; then
    sudo mountpoint -q "$CHARD_ROOT/run/chrome" || sudo mount --bind /run/chrome "$CHARD_ROOT/run/chrome" 2>/dev/null
    sudo umount -l "$CHARD_ROOT/run/chrome/gvfs" 2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/run/chrome/doc" 2>/dev/null || true
    sudo mountpoint -q "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" || sudo mount --bind "/home/chronos/user/MyFiles/Downloads" "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null
    sudo mount -o remount,rw,bind "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads" 2>/dev/null
    $CHARD_ROOT/bin/chard_mount 2>/dev/null
    $CHARD_ROOT/bin/chard_mtp_mount 2>/dev/null
    sudo chmod 666 /dev/hidraw* 2>/dev/null
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
    sudo mountpoint -q "$CHARD_ROOT/run/user/1000" || sudo mount --bind /run/user/1000 "$CHARD_ROOT/run/user/1000" 2>/dev/null
    sudo mountpoint -q "$CHARD_ROOT/run/cras" || sudo mount --bind /run/user/1000/pulse "$CHARD_ROOT/run/cras" 2>/dev/null
fi
sudo mountpoint -q "$CHARD_ROOT/run/dbus" || sudo mount --bind /run/dbus "$CHARD_ROOT/run/dbus" 2>/dev/null
sudo mountpoint -q "$CHARD_ROOT/run/udev" || sudo mount --bind /run/udev "$CHARD_ROOT/run/udev" 2>/dev/null
sudo mountpoint -q "$CHARD_ROOT/dev/dri" || sudo mount --bind /dev/dri "$CHARD_ROOT/dev/dri" 2>/dev/null
sudo mountpoint -q "$CHARD_ROOT/dev/input" || sudo mount --bind /dev/input "$CHARD_ROOT/dev/input" 2>/dev/null
if [ "$CHROMEOS_VERSION" -le 103 ]; then
    sudo mountpoint -q "$CHARD_ROOT/dev" || sudo mount --bind /dev "$CHARD_ROOT/dev" 2>/dev/null
    sudo mountpoint -q "$CHARD_ROOT/proc" || sudo mount --bind /proc "$CHARD_ROOT/proc" 2>/dev/null
fi
sudo mountpoint -q "$CHARD_ROOT/usr/bin/bwrap" || sudo mount --bind "$CHARD_ROOT/$CHARD_HOME/bwrap" "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null
sudo chown root:root "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null
sudo chmod u+s "$CHARD_ROOT/usr/bin/bwrap" 2>/dev/null
sudo cp /etc/resolv.conf "$CHARD_ROOT/etc/resolv.conf" 2>/dev/null
sudo $CHARD_ROOT/bin/killall -9 chard_launch_daemon 2>/dev/null
sudo $CHARD_ROOT/bin/killall -9 chardwire 2>/dev/null
sudo $CHARD_ROOT/bin/killall -9 chard_hidraw 2>/dev/null
sudo $CHARD_ROOT/bin/killall -9 pipewire 2>/dev/null
sudo $CHARD_ROOT/bin/killall -9 pipewire-pulse 2>/dev/null
sudo $CHARD_ROOT/bin/killall -9 pulseaudio 2>/dev/null
sudo $CHARD_ROOT/bin/killall -9 chard_scale 2>/dev/null
sudo rm -f /run/chrome/pipewire-0.lock /run/chrome/pipewire-0-manager.lock 2>/dev/null
sudo rm -f /run/chrome/pulse/native /run/chrome/pulse/* 2>/dev/null
sudo mkdir -p /run/chrome/pulse 2>/dev/null
sudo chown 1000:1000 /run/chrome/pulse 2>/dev/null
sudo chmod 770 /run/chrome/pulse 2>/dev/null

echo "Enabling Game Mode:"
dbus-send --system --print-reply --dest=org.chromium.ResourceManager /org/chromium/ResourceManager org.chromium.ResourceManager.SetGameMode byte:1 2>/dev/null

sudo unshare --mount --pid --fork --kill-child --mount-proc=/usr/local/chard/proc bash -ec '
    mount --make-rprivate /
    mount --rbind /dev /usr/local/chard/dev
    mount --rbind /sys /usr/local/chard/sys
    mount --rbind /usr/local/chard /usr/local/chard
    install -d -o 1000 -g 1000 -m 700 /usr/local/chard/run/user/1000
    touch /usr/local/chard/run/user/1000/wayland-0
    mount --bind /run/chrome/wayland-0 /usr/local/chard/run/user/1000/wayland-0
    cd /usr/local/chard
    pivot_root . mnt
    umount -l /mnt
    cd /
    mount -t proc proc /proc 2>/dev/null || true
    exec chroot --userspec=1000:1000 . /bin/bash -c "\"
        # Source bashrc
        [ -f \"\$HOME/.bashrc\" ] && source \"\$HOME/.bashrc\" 2>/dev/null
        [ -f \"\$HOME/.smrt_env.sh\" ] && source \"\$HOME/.smrt_env.sh\"
        export XDG_RUNTIME_DIR=/run/user/1000
        export FLATPAK_BWRAP=/var/tmp/bwrap/build/bwrap
        sudo rm -f /run/chrome/pipewire-0.lock /run/chrome/pipewire-0-manager.lock 2>/dev/null
        sudo rm -f /run/chrome/pulse/native /run/chrome/pulse/* 2>/dev/null
        killall -9 pipewire 2>/dev/null
        killall -9 pipewire-pulse 2>/dev/null
        killall -9 pulseaudio 2>/dev/null
        sudo chmod +x /bin/powercontrol-gui 2>/dev/null
        chard_sommelier
    \""
' 2>&1
