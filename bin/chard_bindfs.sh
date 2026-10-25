#!/bin/bash
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

   for SRC in ~/external/.raw/*/; do
       N=$(basename "$SRC")
       DST=~/external/$N
       mountpoint -q "$DST" && continue
       sudo mkdir -p "$DST"
       sudo bindfs -o uid=1000,gid=1001 -o allow_other --perms=ugo+x "$SRC" "$DST" \
           || sudo mount --bind "$SRC" "$DST"
   done
