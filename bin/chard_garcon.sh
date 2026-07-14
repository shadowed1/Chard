#!/bin/bash
# chard_garcon
# by days (iamday) 
URL="$1"
if [[ "$URL" != http://* && "$URL" != https://* ]]; then
    URL="https://$URL"
fi
sudo -n nsenter -t 1 -m -- vsh --vm_name=termina --target_container=penguin --owner_id="$(cat /.chard_hash)" -- /opt/google/cros-containers/bin/garcon --client --url "$URL"
