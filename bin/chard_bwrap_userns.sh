#!/bin/sh
unset LD_PRELOAD
exec "/usr/local/bwrap-nosuid/bin/bwrap" \
    --unshare-user \
    --uid 0 \
    --gid 0 \
    "$@"
