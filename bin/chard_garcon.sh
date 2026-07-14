#!/bin/bash
# chard_garcon by days (iamday)
# URL handling by shadowed1
# zenity logic by saragon

URL="$1"

if [[ "$URL" != http://* && "$URL" != https://* ]]; then
    URL="https://$URL"
fi

ERROR_MSG=$(sudo -n nsenter -t 1 -m -- vsh \
    --vm_name=termina \
    --target_container=penguin \
    --owner_id="$(cat /.chard_hash)" \
    -- /opt/google/cros-containers/bin/garcon --client --url "$URL" 2>&1)

STATUS=$?

if [[ $STATUS -ne 0 ]] || echo "$ERROR_MSG" | grep -q "ERROR vsh:"; then
    zenity --error \
        --title="Unable to open Link" \
        --text="Please start crostini (ChromeOS Linux) to open links." \
        --width=400
    exit 1
fi

exit 0
