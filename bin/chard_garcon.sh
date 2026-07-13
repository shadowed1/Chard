#!/bin/bash
# chard_garcon
# version 1 by days
LD="/opt/lib64/ld-linux-x86-64.so.2"
LIB="/opt/lib64:/opt/usr/lib64"
VSH="/opt/usr/bin/vsh"
HASH="$(cat /.chard_hash)"
GARCON="/usr/local/google/cros-containers/bin/garcon"
exec $LD --library-path $LIB $VSH --vm_name=termina --target_container=penguin --owner_id=$HASH -- $GARCON --client --url "$@"
