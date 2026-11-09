# By i-am-days
# precursor to replacing chroot with proot lots to test
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
    cd /
    umount -l /mnt

    exec sudo -Hu chronos env \
      XDG_RUNTIME_DIR=/run/user/1000 \
      FLATPAK_BWRAP=/var/tmp/bwrap/build/bwrap \
      bash
  '
