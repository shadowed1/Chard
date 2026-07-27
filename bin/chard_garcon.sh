#!/bin/bash
# chard_garcon by days (iamday)
# URL handling by shadowed1
# zenity logic by saragon

RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

print_termina_status() {
    local override="$1"
    sudo -n nsenter -t 1 -m -- vmc list | awk \
        -v RESET="$RESET" -v INFO="$GREEN" -v WARN="$RED" -v NOTE="$YELLOW" -v OVERRIDE="$override" \
        '
        /^termina/ {
            if (OVERRIDE!="") { $(NF+1) = NOTE OVERRIDE RESET }
            else if ($NF=="running") { $NF = INFO "running" RESET }
            else { $(NF+1) = WARN "not running" RESET }
            printf "%s\n", $0
        }
    '
}

open_url() {
    ERROR_MSG=$(sudo -n nsenter -t 1 -m -- vsh \
        --vm_name=termina \
        --target_container=penguin \
        --owner_id="$(cat /.chard_hash)" \
        -- /opt/google/cros-containers/bin/garcon --client --url "$URL" 2>&1)
    STATUS=$?
    if [[ $STATUS -ne 0 ]] || echo "$ERROR_MSG" | grep -q "ERROR vsh:"; then
        return 1
    fi
    return 0
}

URL="$1"
if [[ "$URL" != http://* && "$URL" != https://* ]]; then
    URL="https://$URL"
fi

if open_url; then
    exit 0
fi

status=$(sudo -n nsenter -t 1 -m -- vmc list | awk '/^termina/ {print $NF; exit}')
if [[ "$status" != "running" ]]; then
    print_termina_status "starting"
    sudo -n nsenter -t 1 -m -- vmc start \
        --enable-gpu --vm-type BAGUETTE --no-shell \
        termina --timeout 30
    print_termina_status

    status=$(sudo -n nsenter -t 1 -m -- vmc list | awk '/^termina/ {print $NF; exit}')
    if [[ "$status" == "running" ]]; then
        open_url && exit 0
    fi
fi

zenity --error \
    --title="Unable to open Link" \
    --text="Please start crostini (ChromeOS Linux) to open links." \
    --width=400
exit 1
