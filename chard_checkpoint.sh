#!/bin/bash

CHECKPOINT_FILE="/.chard_checkpoint"
if [[ -f "$CHECKPOINT_FILE" ]]; then
    CURRENT_CHECKPOINT=$(cat "$CHECKPOINT_FILE")
else
    CURRENT_CHECKPOINT=0
fi

run_checkpoint() {
    local step=$1
    local desc=$2

    if (( CURRENT_CHECKPOINT < step )); then
        echo ">>> Running checkpoint $step: $desc"
        shift 2
        "$@"

        echo $step > "$CHECKPOINT_FILE"
        sync
        echo ">>> Checkpoint $step complete"
        CURRENT_CHECKPOINT=$step
    else
        echo ">>> Skipping checkpoint $step ($desc)"
    fi
}

# --- Checkpoint 1 ---
if (( CURRENT_CHECKPOINT < 1 )); then
    echo ">>> Checkpoint 1: emerge dev-build/make + cleanup"
    emerge dev-build/make
    rm -rf /var/tmp/portage/dev-build/make-*
    eclean-dist -d
    echo 1 > "$CHECKPOINT_FILE"
    CURRENT_CHECKPOINT=1
fi

# --- Checkpoint 2 ---
if (( CURRENT_CHECKPOINT < 2 )); then
    echo ">>> Checkpoint 2: emerge app-portage/gentoolkit + cleanup"
    emerge app-portage/gentoolkit
    rm -rf /var/tmp/portage/app-portage/gentoolkit-*
    eclean-dist -d
    echo 2 > "$CHECKPOINT_FILE"
    CURRENT_CHECKPOINT=2
fi

# --- Checkpoint 3 ---
if (( CURRENT_CHECKPOINT < 3 )); then
    echo ">>> Checkpoint 3: emerge dev-libs/gmp + cleanup"
    emerge dev-libs/gmp
    rm -rf /var/tmp/portage/dev-libs/gmp-*
    eclean-dist -d
    echo 3 > "$CHECKPOINT_FILE"
    CURRENT_CHECKPOINT=3
fi

# --- Checkpoint 4 ---
if (( CURRENT_CHECKPOINT < 4 )); then
    echo ">>> Checkpoint 4: emerge dev-libs/mpfr + cleanup"
    emerge dev-libs/mpfr
    rm -rf /var/tmp/portage/dev-libs/mpfr-*
    eclean-dist -d
    echo 4 > "$CHECKPOINT_FILE"
    CURRENT_CHECKPOINT=4
fi

# --- Checkpoint 5 ---
if (( CURRENT_CHECKPOINT < 5 )); then
    echo ">>> Checkpoint 5: emerge sys-devel/binutils + cleanup"
    emerge sys-devel/binutils
    rm -rf /var/tmp/portage/sys-devel/binutils-*
    eclean-dist -d
    echo 5 > "$CHECKPOINT_FILE"
    CURRENT_CHECKPOINT=5
fi

# --- Checkpoint 6 ---
if (( CURRENT_CHECKPOINT < 6 )); then
    echo ">>> Checkpoint 6: emerge sys-apps/diffutils + cleanup"
    emerge sys-apps/diffutils
    rm -rf /var/tmp/portage/sys-apps/diffutils-*
    eclean-dist -d
    echo 6 > "$CHECKPOINT_FILE"
    CURRENT_CHECKPOINT=6
fi

# --- Checkpoint 7 ---
if (( CURRENT_CHECKPOINT < 7 )); then
    echo ">>> Checkpoint 7: emerge dev-libs/openssl + cleanup"
    emerge dev-libs/openssl
    rm -rf /var/tmp/portage/dev-libs/openssl-*
    eclean-dist -d
    echo 7 > "$CHECKPOINT_FILE"
    CURRENT_CHECKPOINT=7
fi

# --- Checkpoint 8 ---
if (( CURRENT_CHECKPOINT < 8 )); then
    echo ">>> Checkpoint 8: emerge net-misc/curl + cleanup"
    emerge net-misc/curl
    rm -rf /var/tmp/portage/net-misc/curl-*
    eclean-dist -d
    echo 8 > "$CHECKPOINT_FILE"
    CURRENT_CHECKPOINT=8
fi

# --- Checkpoint 9 ---
if (( CURRENT_CHECKPOINT < 9 )); then
    echo ">>> Checkpoint 9: emerge dev-vcs/git + cleanup"
    emerge dev-vcs/git
    rm -rf /var/tmp/portage/dev-vcs/git-*
    eclean-dist -d
    echo 9 > "$CHECKPOINT_FILE"
    CURRENT_CHECKPOINT=9
fi

# --- Checkpoint 10 ---
if (( CURRENT_CHECKPOINT < 10 )); then
    echo ">>> Checkpoint 10: emerge sys-apps/coreutils + cleanup"
    emerge sys-apps/coreutils
    rm -rf /var/tmp/portage/sys-apps/coreutils-*
    eclean-dist -d
    echo 10 > "$CHECKPOINT_FILE"
    CURRENT_CHECKPOINT=10
fi

# --- Checkpoint 11 ---
if (( CURRENT_CHECKPOINT < 11 )); then
    echo ">>> Checkpoint 11: emerge app-misc/fastfetch + cleanup"
    emerge app-misc/fastfetch
    rm -rf /var/tmp/portage/app-misc/fastfetch-*
    eclean-dist -d
    echo 11 > "$CHECKPOINT_FILE"
    CURRENT_CHECKPOINT=11
fi

# --- Checkpoint 12 ---
if (( CURRENT_CHECKPOINT < 12 )); then
    echo ">>> Checkpoint 12: emerge dev-lang/perl + cleanup"
    emerge dev-lang/perl
    rm -rf /var/tmp/portage/dev-lang/perl-*
    eclean-dist -d
    echo 12 > "$CHECKPOINT_FILE"
    CURRENT_CHECKPOINT=12
fi

# --- Checkpoint 13 ---
if (( CURRENT_CHECKPOINT < 13 )); then
    echo ">>> Checkpoint 13: emerge dev-perl/Capture-Tiny + cleanup"
    emerge dev-perl/Capture-Tiny
    rm -rf /var/tmp/portage/dev-perl/Capture-Tiny-*
    eclean-dist -d
    echo 13 > "$CHECKPOINT_FILE"
    CURRENT_CHECKPOINT=13
fi

# --- Checkpoint 14 ---
if (( CURRENT_CHECKPOINT < 14 )); then
    echo ">>> Checkpoint 14: emerge dev-perl/Try-Tiny + cleanup"
    emerge dev-perl/Try-Tiny
    rm -rf /var/tmp/portage/dev-perl/Try-Tiny-*
    eclean-dist -d
    echo 14 > "$CHECKPOINT_FILE"
    CURRENT_CHECKPOINT=14
fi

echo ">>> Chard Root is ready!"
