description "Chard Baguette autostart."
#grep chard /var/log/messages | tail -10
start on started ui
stop on stopping ui
task
script
    logger -t chard_baguette "[chard_baguette]: starting"
    BASHRC=""
    attempt=0
    max_attempts=10
    wait_seconds=60
    while [ "$attempt" -lt "$max_attempts" ]; do
        logger -t chard_baguette "[chard_baguette]: waiting for .bashrc (attempt $((attempt+1))/$max_attempts)"
        i=0
        while [ "$i" -lt "$wait_seconds" ]; do
            if [ -f "/home/chronos/user/.bashrc" ]; then
                BASHRC="/home/chronos/user/.bashrc"
                break
            fi
            sleep 1
            i=$((i + 1))
        done
        if [ -n "$BASHRC" ]; then
            break
        fi
        attempt=$((attempt + 1))
        sleep 5
    done
    if [ -z "$BASHRC" ]; then
        logger -t chard_baguette "[chard_baguette]: timed out waiting for .bashrc after $max_attempts attempts"
        exit 1
    fi

    attempt=0
    max_attempts=10
    while [ "$attempt" -lt "$max_attempts" ]; do
        logger -t chard_baguette "[chard_baguette]: starting termina (attempt $((attempt+1))/$max_attempts)"
        if vmc start --enable-gpu --vm-type BAGUETTE --no-shell termina; then
            logger -t chard_baguette "[chard_baguette]: termina started successfully"
            exit 0
        fi
        attempt=$((attempt + 1))
        logger -t chard_baguette "[chard_baguette]: vmc start failed, retrying in 10s"
        sleep 10
    done
    logger -t chard_baguette "[chard_baguette]: failed to start termina after $max_attempts attempts"
    exit 1
end script
