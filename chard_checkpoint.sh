#!/bin/bash
CHECKPOINT_FILE="/.chard_checkpoint"

if [[ -f "$CHECKPOINT_FILE" ]]; then
    CURRENT_CHECKPOINT=$(cat "$CHECKPOINT_FILE")
else
    CURRENT_CHECKPOINT=0
fi

trap 'echo; echo ">>> Ctrl+C detected. Exiting immediately."; exit 1' SIGINT

run_checkpoint() {
    local step=$1
    local desc=$2
    shift 2

    if (( CURRENT_CHECKPOINT < step )); then
        echo ">>> Running checkpoint $step: $desc"

        "$@"
        local ret=$?

        if (( ret != 0 )); then
            echo ">>> Checkpoint $step FAILED or interrupted. Exiting."
            exit $ret
        fi

        echo $step > "$CHECKPOINT_FILE"
        sync
        CURRENT_CHECKPOINT=$step
        echo ">>> Checkpoint $step complete"
    else
        echo ">>> Skipping checkpoint $step ($desc)"
    fi
}

run_checkpoint 1 "emerge dev-build/make + cleanup" \
    emerge dev-build/make && rm -rf /var/tmp/portage/dev-build/make-* && eclean-dist -d

run_checkpoint 2 "emerge app-portage/gentoolkit + cleanup" \
    emerge app-portage/gentoolkit && rm -rf /var/tmp/portage/app-portage/gentoolkit-* && eclean-dist -d
    
