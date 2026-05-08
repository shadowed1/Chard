#!/bin/sh
# Created by Days
sudo install -o 1000 -g 1000 -m 0755 /dev/stdin "/bin/bwrap_userns" <<'EOF'
unset LD_PRELOAD
exec "/usr/local/bwrap-nosuid/bin/bwrap" \
    --unshare-user \
    --uid 0 \
    --gid 0 \
    "$@"
EOF
sudo chmod +x "/bin/bwrap_userns"
