#!/bin/bash
# shadowed1
# Runs in Chard!

RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

if [[ -f "/.chard_home" ]]; then
    CHARD_HOME=$(cat "/.chard_home" | tr -d '[:space:]')
else
    echo "${RED}[charon] Error: /.chard_home not found${RESET}" >&2
    sleep 5
    exit 1
fi

CMD_FIFO="/${CHARD_HOME}/charon/charon.fifo"
AUTH_FILE="/${CHARD_HOME}/charon/.charon.auth"

if [[ ! -p "$CMD_FIFO" ]]; then
    echo "${RED}[charon] charon_daemon is not running${RESET}" >&2
    echo "${RED}Expected FIFO: $CMD_FIFO ${RESET}" >&2
    sleep 5
    exit 1
fi

if [[ ! -f "$AUTH_FILE" ]]; then
    echo "${RED}[charon] Authentication file not found${RESET}" >&2
    sleep 5
    exit 1
fi

AUTH_TOKEN=$(cat "$AUTH_FILE")

if [[ $# -eq 0 ]]; then
    echo "${GREEN}[charon] charon_daemon is running - commands enabled${RESET}"
    echo "${CYAN}FIFO:${BOLD} $CMD_FIFO ${RESET}"
    exit 0
fi

REPLY_FIFO="/${CHARD_HOME}/charon/reply.$$"

cleanup() {
    rm -f "$REPLY_FIFO"
}

trap cleanup EXIT
mkfifo "$REPLY_FIFO"
chmod 600 "$REPLY_FIFO"

TTY_DEV=$(tty 2>/dev/null | grep -E '^/dev/' || echo "/dev/tty1")
cmd=$(printf '%q ' "$@" | sed 's/ $//')

{
    printf '%s|%s|%s|%s\n' "$AUTH_TOKEN" "$REPLY_FIFO" "$TTY_DEV" "$cmd"
} >"$CMD_FIFO" || {
    echo "${RED}[charon] Failed to write to command FIFO${RESET}" >&2
    sleep 5
    exit 1
}

exit_code=0
found_exit=false
while IFS= read -r line; do
    if [[ "$line" == "__CHARD_EXIT__:"* ]]; then
        exit_code="${line#__CHARD_EXIT__:}"
        if [[ "$exit_code" =~ ^[0-9]+$ ]]; then
            found_exit=true
        fi
        break
    else
        echo "$line"
    fi
done <"$REPLY_FIFO"

if [[ "$found_exit" != "true" ]]; then
    echo "${RED}[charon] No exit marker received from daemon${RESET}" >&2
    sleep 5
    exit 1
fi

exit "$exit_code"
