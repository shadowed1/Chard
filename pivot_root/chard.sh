#!/usr/bin/env bash
# Launches a namespace-isolated environment for an unprivileged user session; thereby superseding our chroot.

# TODO(days): This precursor establishes mount and PID namespaces through privileged pivot_root setup
#             before dropping privileges, eliminating the need for a persistent privileged shell.
#             It separates CHARD's filesystem and process views from the host while enabling
#             support for sandboxed applications improveing isolation and compatibility.

sudo unshare --mount --pid --fork --kill-child --mount-proc=/usr/local/chard/proc bash -ec '
    mount --make-rprivate /
    mount --rbind /dev /usr/local/chard/dev
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
      bash
  '
