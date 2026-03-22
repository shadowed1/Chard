#!/usr/bin/env bash
# Not final
CHARD_USER=$(awk -F: '$3 == 1000 {print $1}' /etc/passwd)
CHARD_USER="${CHARD_USER:-chronos}"
BASHRC=""
i=0
while [ "$i" -lt 60 ]; do
    if [ -f "/home/chronos/user/.bashrc" ]; then
        BASHRC="/home/chronos/user/.bashrc"
        break
    elif [ -f "/home/$CHARD_USER/.bashrc" ]; then
        BASHRC="/home/$CHARD_USER/.bashrc"
        break
    fi
    sleep 1
    i=$((i + 1))
done

if [ -z "$BASHRC" ]; then
    logger -t chard "Timed out waiting for .bashrc (tried /home/chronos/user/.bashrc and /home/$CHARD_USER/.bashrc)"
    exit 1
fi

CHARD_ROOT=$(sed -n \
    '/<<< CHARD ENV MARKER <<</,/<<< END CHARD ENV MARKER <<</p' \
    "$BASHRC" | \
    sed -n 's|.*source "\(.*\)/\.chardrc".*|\1|p')

if [ -z "$CHARD_ROOT" ]; then
    logger -t chard "chard-start: could not parse CHARD_ROOT"
    exit 1
fi

if [ ! -x "$CHARD_ROOT/bin/chard" ]; then
    logger -t chard "chard-start: binary missing at $CHARD_ROOT/bin/chard"
    exit 1
fi

logger -t chard "chard-start: launching $CHARD_ROOT/bin/chard root"
exec "$CHARD_ROOT/bin/chard" root
