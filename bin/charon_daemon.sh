#!/bin/bash
# shadowed1
# Runs in ChromeOS shell!
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

BASHRC_PATH=""
if [[ -f "/home/chronos/user/.bashrc" ]]; then
    BASHRC_PATH="/home/chronos/user/.bashrc"
else
    CURRENT_USER=$(whoami 2>/dev/null || echo "")
    if [[ -n "$CURRENT_USER" && -f "/home/$CURRENT_USER/.bashrc" ]]; then
        BASHRC_PATH="/home/$CURRENT_USER/.bashrc"
    fi
fi

if [[ -z "$BASHRC_PATH" ]]; then
    echo "${RED}[charon_daemon] Error: No .bashrc found to discover chard config${RESET}" >&2
    exit 1
fi

CHARDRC_PATH=$(sed -n '/# <<< CHARD ENV MARKER <<</,/# <<< END CHARD ENV MARKER <<< /p' "$BASHRC_PATH" 2>/dev/null | grep 'source' | sed 's/.*source[[:space:]]*"\([^"]*\)".*/\1/' | head -1)

if [[ -z "$CHARDRC_PATH" ]]; then
    echo "${RED}[charon_daemon] Warning: No source command found inside CHARD ENV MARKER in $BASHRC_PATH${RESET}" >&2
    echo "Expected: source \"<path-to-chardrc>\" inside CHARD ENV MARKER block" >&2
    exit 1
fi

if [[ -f "$CHARDRC_PATH" ]]; then

    CHARD_ROOT=$(sed -n '/# <<< CHARD_ROOT_MARKER >>>/,/# <<< END_CHARD_ROOT_MARKER >>>/p' "$CHARDRC_PATH" | grep '^CHARD_ROOT=' | head -1 | sed 's/CHARD_ROOT="//;s/"//')
    CHARD_HOME=$(sed -n '/# <<< CHARD_ROOT_MARKER >>>/,/# <<< END_CHARD_ROOT_MARKER >>>/p' "$CHARDRC_PATH" | grep '^CHARD_HOME=' | head -1 | sed 's/CHARD_HOME="//;s/"//')
    CHARD_USER=$(sed -n '/# <<< CHARD_ROOT_MARKER >>>/,/# <<< END_CHARD_ROOT_MARKER >>>/p' "$CHARDRC_PATH" | grep '^CHARD_USER=' | head -1 | sed 's/CHARD_USER="//;s/"//')

    if [[ -z "$CHARD_ROOT" ]]; then
        echo "${RED}[charon_daemon] Error: CHARD_ROOT not found in $CHARDRC_PATH${RESET}" >&2
        exit 1
    fi
else
    echo "${RED}[charon_daemon] Error: $CHARDRC_PATH not found${RESET}" >&2
    exit 1
fi

CHARON_DIR="${CHARD_ROOT}/${CHARD_HOME}/charon"
CMD_FIFO="${CHARON_DIR}/charon.fifo"
LOCK_FILE="${CHARON_DIR}/.charon.lock"
AUTH_FILE="${CHARON_DIR}/.charon.auth"

mkdir -p "$CHARON_DIR"

exec 200>"$LOCK_FILE" || exit 1
flock -n 200 || {
    echo "${YELLOW}[charon_daemon] Already running${RESET}"
    exit 1
}

if [[ ! -f "$AUTH_FILE" ]]; then
    head -c 32 /dev/urandom | base64 | tr -d '/+=' | head -c 43 > "$AUTH_FILE"
    chmod 400 "$AUTH_FILE"
    chown -R chronos:chronos "$CHARON_DIR" 2>/dev/null || true
    echo "${GREEN}[charon_daemon] Generated new authentication token${RESET}"
fi

AUTH_TOKEN=$(cat "$AUTH_FILE")

rm -f "$CMD_FIFO" 2>/dev/null
mkfifo "$CMD_FIFO"
chown -R chronos:chronos "$CHARON_DIR" 2>/dev/null || true
chmod 600 "$CMD_FIFO"

execute_command() {
    local token="$1"
    local reply_fifo="$2"
    local tty_dev="$3"
    local cmd="$4"

    if [[ "$token" != "$AUTH_TOKEN" ]]; then
        echo "[charon_daemon] Authentication failed" >&2
        {
            echo "${RED}[charon_daemon] Authentication failed${RESET}"
            echo "__CHARD_EXIT__:1"
        } >"$reply_fifo" 2>/dev/null
        return
    fi

    local host_reply_fifo="${CHARD_ROOT}${reply_fifo}"

    local reply_dir
    reply_dir="$(dirname "$host_reply_fifo")"
    mkdir -p "$reply_dir" 2>/dev/null || true

    if [[ ! -p "$host_reply_fifo" ]]; then
        mkfifo "$host_reply_fifo" 2>/dev/null || true
    fi

    echo "${MAGENTA}[charon_daemon] Running:${RESET}${CYAN} $cmd ${RESET}" >&2

    {
        # Only redirect TTY if it's a valid terminal device
        if [[ -n "$tty_dev" && -c "$tty_dev" && -t 0 ]]; then
            if result=$(/bin/bash -c "$cmd" <"$tty_dev" 2>&1); then
                exit_code=0
            else
                exit_code=$?
            fi
        else
            # Don't redirect stdin for non-TTY environments (LLMs, scripts)
            if result=$(/bin/bash -c "$cmd" 2>&1); then
                exit_code=0
            else
                exit_code=$?
            fi
        fi
        echo "$result"
        echo "__CHARD_EXIT__:$exit_code"
    } >"$host_reply_fifo" 2>/dev/null
}

cleanup() {
    jobs -p | xargs -r kill 2>/dev/null
    wait 2>/dev/null
    rm -f "$CMD_FIFO" 2>/dev/null
    rm -f "$LOCK_FILE" 2>/dev/null
    echo "${RED}[charon_daemon] Stopped${RESET}"
}

trap cleanup EXIT
trap 'exit 0' SIGINT SIGTERM

echo
echo "${GREEN}[charon_daemon] Listening on $CMD_FIFO${RESET}"
echo "${GREEN}[charon_daemon] CHARD_ROOT=$CHARD_ROOT  CHARD_HOME=$CHARD_HOME  CHARD_USER=$CHARD_USER${RESET}"
echo "[charon_daemon] Authentication enabled - Ctrl-C to exit.${RESET}"
echo

exec 3<>"$CMD_FIFO"

while IFS= read -r line <&3 || [[ -n "$line" ]]; do
    line="${line//$'\r'/}"
    [[ -z "$line" ]] && continue
    req_token="${line%%|*}"
    rest="${line#*|}"
    req_reply="${rest%%|*}"
    rest="${rest#*|}"
    req_tty="${rest%%|*}"
    req_cmd="${rest#*|}"

    if [[ -z "$req_token" || -z "$req_reply" || -z "$req_cmd" ]]; then
        echo "[charon_daemon] Malformed request: $line" >&2
        continue
    fi

    execute_command "$req_token" "$req_reply" "$req_tty" "$req_cmd" &
done

echo "${RED}[charon_daemon] FIFO closed, exiting. ${RESET}" >&2
