#!/bin/bash
# Chariot

# <<< CHARD_ROOT_MARKER >>>
CHARD_ROOT=""
CHARD_HOME=""
CHARD_USER=""
# <<< END_CHARD_ROOT_MARKER >>>

START_TIME=$(date +%s)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

touch ~/chariot.log
LOG_FILE=~/chariot.log
exec > >( tee -a "$LOG_FILE") 2>&1

format_time() {
    local total_seconds=$1
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))
    
    if [ $hours -gt 0 ]; then
        printf "%dh %dm %ds" $hours $minutes $seconds
    elif [ $minutes -gt 0 ]; then
        printf "%dm %ds" $minutes $seconds
    else
        printf "%ds" $seconds
    fi
}

show_progress() {
    local current_time=$(date +%s)
    local elapsed=$((current_time - START_TIME))
    local formatted_time=$(format_time $elapsed)
    echo "${CYAN}[Runtime: $formatted_time]${RESET} $1"
}

reset() {
    rm /.chard_checkpoint
    echo
    echo "${RED}Chariot Progress Reset! ${RESET}"
    echo
    exit 0
}

if [[ "$1" == "reset" ]]; then
    reset
fi

echo ""
echo ""
echo "${RESET}${RED}"        
echo "             ------------ ----    ----    ------    -----------  --------    --------   ------------" 
echo "             ************ ****    ****   ********   ***********  ********   **********  ************" 
echo "             ---          ----    ----  ----------  ----    ---    ----    ----    ---- ------------" 
echo "             ***          ************ ****    **** *********      ****    ***      ***     ****"     
echo "             ---          ------------ ------------ ---------      ----    ---      ---     ----"     
echo "             ***          ****    **** ************ ****  ****     ****    ****    ****     ****"     
echo "             ------------ ----    ---- ----    ---- ----   ----  --------   ----------      ----"     
echo "             ************ ****    **** ****    **** ****    **** ********    ********       ****" 
echo "${RESET}${RED}"                                                                                                   
echo "                    ######"                                                                          
echo "                  @@####@@##"                                                                        
echo "                  ########"                                                                          
echo "                  ##@@####::"                                                                        
echo "                      @@@                                                     ##MM--##"              
echo "                    ##--mm                                              ##################"          
echo "                  ##########                                              ####################"      
echo "              ####################MM###############                    ####################"        
echo "            ####  ##########   ##  ::######      ##############           ::##############mm"        
echo "              ##    ########              ########              ##########..########@@######@@"      
echo "              ..    ########                       ############      ....##################"        
echo "              MM..--#######---##MM        ####  ##             ###########--    ..--..  ##mm"        
echo "                  ################      ##########  mm##    ########################++"              
echo "                      ############      ############  ##############################"                
echo "                  ++##############    ::############  ############################@@"                
echo "                ..########@@--####  ##############  ################################"                
echo "              ####################  ############@@  ######################  ############"            
echo "            ..##################::    ######::############  ##############  ############"            
echo "            ########  ##..######@@######mm        MM####mm########              ##    MM##"          
echo "          ##################@@                    ##############                ##      @@"          
echo "            ########  ##  ########              ##  ..######                    @@    ..  ##"        
echo "                    ######                    ######  ##      ##                    ::    ##"        
echo "            ##    ##  ##  ##    ##            ##  ##          mm##            ####  .."              
echo "                MM    ##    mm              ##  ##    ##                      --"                    
echo "                      ##                    ####      ####"                                          
echo "                  ####  ####                ##          ##"
echo ""
echo ""
echo "${RESET}"
                                                                       
echo
echo "${CYAN}${BOLD}Chariot is an install assistant for Chard which implements a checkpoint system to resume if interrupted! ${RESET}"
echo "${RESET}${GREEN}Run: ${BLUE}${BOLD}chariot${RESET}${GREEN} in ChromeOS shell to resume..."
echo
echo "${RESET}${YELLOW}Example to resume from a specific checkpoint: ${RESET}${MAGENTA}${BOLD}chariot 137${RESET}"
echo "${GREEN}Run: ${RESET}${BOLD}${RED}chariot reset ${RESET}${GREEN}to ${RESET}${RED}revert${GREEN} to checkpoint 1.${RESET}${GREEN}"
echo

CHECKPOINT_FILE="/.chard_checkpoint"

if [[ -z "$CHECKPOINT_FILE" || "${CHECKPOINT_FILE:0:1}" != "/" ]]; then
    echo "${RED}FATAL: CHECKPOINT_FILE is not set correctly: '$CHECKPOINT_FILE'${RESET}"
    exit 1
fi

echo "$CHECKPOINT_FILE"

if [[ ! -e "$CHECKPOINT_FILE" ]]; then
    sudo bash -c "echo 0 > '$CHECKPOINT_FILE'" || { echo "${RED}Cannot create $CHECKPOINT_FILE${RESET}"; exit 1; }
fi

CURRENT_CHECKPOINT=$(sudo cat "$CHECKPOINT_FILE" 2>/dev/null || echo "0")
if ! [[ "$CURRENT_CHECKPOINT" =~ ^[0-9]+$ ]]; then
    CURRENT_CHECKPOINT=0
fi

SINGLE_STEP=false
REQUESTED_STEP=""
CHECKPOINT_OVERRIDE=""

if [[ "$1" == "-s" ]]; then
    if [[ -z "$2" || ! "$2" =~ ^[0-9]+$ ]]; then
        echo "${RED}-s requires a numeric checkpoint${RESET}"
        exit 1
    fi
    SINGLE_STEP=true
    REQUESTED_STEP="$2"
    CHECKPOINT_OVERRIDE=$REQUESTED_STEP
    echo "${BOLD}${MAGENTA}Single-step requested: $REQUESTED_STEP ${RESET}"

    CURRENT_CHECKPOINT=$((CHECKPOINT_OVERRIDE - 1))
    sudo bash -c "printf '%s\n' '$CURRENT_CHECKPOINT' > '$CHECKPOINT_FILE'" \
        || { echo "${RED}Failed to write $CHECKPOINT_FILE${RESET}"; exit 1; }

    shift 2
fi

if ! $SINGLE_STEP && [[ "$1" =~ ^[0-9]+$ ]]; then
    CHECKPOINT_OVERRIDE=$1
    echo "${BOLD}${MAGENTA}Checkpoint requested: $CHECKPOINT_OVERRIDE ${RESET}"

    CURRENT_CHECKPOINT=$((CHECKPOINT_OVERRIDE - 1))
    sudo bash -c "printf '%s\n' '$CURRENT_CHECKPOINT' > '$CHECKPOINT_FILE'" \
        || { echo "${RED}Failed to write $CHECKPOINT_FILE${RESET}"; exit 1; }
fi

CURRENT_CHECKPOINT=$(sudo cat "$CHECKPOINT_FILE" 2>/dev/null || echo "$CURRENT_CHECKPOINT")
if ! [[ "$CURRENT_CHECKPOINT" =~ ^-?[0-9]+$ ]]; then
    CURRENT_CHECKPOINT=0
fi

echo
echo "Starting in 10 seconds..."
sleep 8

trap 'echo; echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${RED}Exiting${RESET}"; exit 1' SIGINT

run_checkpoint() {
    local step=$1
    local desc=$2
    shift 2

    if (( CURRENT_CHECKPOINT < step )); then
        echo
        echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}>${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${GREEN}${BOLD}Checkpoint $step / 145 ($desc) Starting ${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${GREEN}"
        echo

        "$@"
        local ret=$?

        if (( ret != 0 )); then
            echo
            echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}>${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${RED}${BOLD}Checkpoint $step / 145 ($desc) DNF ${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${GREEN}${RESET}${GREEN}"
            echo
            return $ret
        fi

        echo "$step" | sudo tee "$CHECKPOINT_FILE" >/dev/null
        sync
        CURRENT_CHECKPOINT=$step
        echo
        echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}>${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${CYAN}${BOLD}Checkpoint $step / 145 ($desc) Finished ${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${GREEN}${RESET}${GREEN}"
        echo

        if $SINGLE_STEP && (( step == REQUESTED_STEP )); then
            echo "${GREEN}Single-step completed: exiting after checkpoint $step${RESET}"
            exit 0
        fi

    else
        echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}>${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${CYAN}${BOLD}Checkpoint $step / 145 ($desc) Completed ${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${GREEN}${RESET}${GREEN}"
        echo
    fi
}

checkpoint_1() {
    sudo chown -R 1000:1000 ~/
    sudo -E emerge dev-build/make
    rm -rf /var/tmp/portage/dev-build/make-*
}
run_checkpoint 1 "sudo -E emerge dev-build/make" checkpoint_1

checkpoint_2() {
    sudo -E emerge --noreplace app-portage/gentoolkit
    rm -rf /var/tmp/portage/app-portage/gentoolkit-*
    eclean-dist -d
}
run_checkpoint 2 "sudo -E emerge app-portage/gentoolkit" checkpoint_2

checkpoint_3() {
    USE="-gui" sudo -E emerge -1 dev-build/cmake
    rm -rf /var/tmp/portage/dev-build/cmake-*
    eclean-dist -d
}
run_checkpoint 3 'USE="-gui" sudo -E emerge -1 dev-build/cmake' checkpoint_3

checkpoint_4() {
    sudo -E emerge app-misc/resolve-march-native
    rm -rf /var/tmp/portage/app-misc/resolve-march-native-*
    eclean-dist -d
}
run_checkpoint 4 "sudo -E emerge resolve-march-native" checkpoint_4

checkpoint_5() {
    sudo -E emerge dev-libs/gmp
    rm -rf /var/tmp/portage/dev-libs/gmp-*
    eclean-dist -d
}
run_checkpoint 5 "sudo -E emerge dev-libs/gmp" checkpoint_5

checkpoint_6() {
    sudo -E emerge dev-libs/mpfr
    rm -rf /var/tmp/portage/dev-libs/mpfr-*
    eclean-dist -d
}
run_checkpoint 6 "sudo -E emerge dev-libs/mpfr" checkpoint_6

checkpoint_7() {
    sudo -E emerge sys-devel/binutils
    rm -rf /var/tmp/portage/sys-devel/binutils-*
    eclean-dist -d
}
run_checkpoint 7 "sudo -E emerge sys-devel/binutils" checkpoint_7

checkpoint_8() {
    sudo -E emerge sys-apps/diffutils
    rm -rf /var/tmp/portage/sys-apps/diffutils-*
    eclean-dist -d
}
run_checkpoint 8 "sudo -E emerge sys-apps/diffutils" checkpoint_8

checkpoint_9() {
    sudo -E emerge dev-libs/openssl
    rm -rf /var/tmp/portage/dev-libs/openssl-*
    eclean-dist -d
}
run_checkpoint 9 "sudo -E emerge dev-libs/openssl" checkpoint_9

checkpoint_10() {
    sudo -E emerge net-misc/curl
    rm -rf /var/tmp/portage/net-misc/curl-*
    eclean-dist -d
}
run_checkpoint 10 "sudo -E emerge net-misc/curl" checkpoint_10

checkpoint_11() {
    sudo -E emerge app-misc/ca-certificates
    sudo update-ca-certificates
    USE="curl" sudo -E emerge dev-vcs/git
    rm -rf /var/tmp/portage/dev-vcs/git-*
    eclean-dist -d
    GIT_CURL_VERBOSE=1 GIT_TRACE=1 git ls-remote https://github.com/torvalds/linux.git HEAD 2>&1 | head -50
    GIT_EXEC_PATH=/usr/libexec/git-core
}
run_checkpoint 11 "sudo -E emerge dev-vcs/git" checkpoint_11

checkpoint_12() {
    sudo -E emerge sys-apps/coreutils
    rm -rf /var/tmp/portage/sys-apps/coreutils-*
    eclean-dist -d
}
run_checkpoint 12 "sudo -E emerge sys-apps/coreutils" checkpoint_12

#checkpoint_13() {
#    sudo -E emerge app-misc/fastfetch
#    rm -rf /var/tmp/portage/app-misc/fastfetch-*
#    eclean-dist -d
#}
#run_checkpoint 13 "sudo -E emerge app-misc/fastfetch" checkpoint_13

checkpoint_14() {
    sudo -E emerge dev-lang/perl
    rm -rf /var/tmp/portage/dev-lang/perl-*
    eclean-dist -d
}
run_checkpoint 14 "sudo -E emerge dev-lang/perl" checkpoint_14

checkpoint_15() {
    sudo -E emerge dev-perl/Capture-Tiny
    rm -rf /var/tmp/portage/dev-perl/Capture-Tiny-*
    eclean-dist -d
    sudo -E perl-cleaner --all
}
run_checkpoint 15 "sudo -E emerge dev-perl/Capture-Tiny" checkpoint_15

checkpoint_16() {
    sudo -E emerge dev-perl/Try-Tiny
    rm -rf /var/tmp/portage/dev-perl/Try-Tiny-*
    eclean-dist -d
}
run_checkpoint 16 "sudo -E emerge dev-perl/Try-Tiny" checkpoint_16

checkpoint_17() {
    sudo -E emerge dev-perl/Config-AutoConf
    rm -rf /var/tmp/portage/dev-perl/Config-AutoConf-*
    eclean-dist -d
}
run_checkpoint 17 "sudo -E emerge dev-perl/Config-AutoConf" checkpoint_17

checkpoint_18() {
    sudo -E emerge dev-perl/Test-Fatal
    rm -rf /var/tmp/portage/dev-perl/Test-Fatal-*
    eclean-dist -d
}
run_checkpoint 18 "sudo -E emerge dev-perl/Test-Fatal" checkpoint_18

checkpoint_19() {
    sudo -E emerge sys-apps/findutils
    rm -rf /var/tmp/portage/sys-apps/findutils-*
    eclean-dist -d
}
run_checkpoint 19 "sudo -E emerge sys-apps/findutils" checkpoint_19

checkpoint_20() {
    sudo -E emerge dev-libs/elfutils
    rm -rf /var/tmp/portage/dev-libs/elfutils-*
    eclean-dist -d
}
run_checkpoint 20 "sudo -E emerge dev-libs/elfutils" checkpoint_20

checkpoint_21() {
    sudo bash -c '
        if [ "$(uname -m)" = "aarch64" ]; then
            export ARCH=arm64
        fi

        cd /usr/src/linux || exit 1

        scripts/kconfig/merge_config.sh -m .config enable_features.cfg
        make olddefconfig

        make -j"$(nproc)" tools/objtool
        make -j"$(nproc)"

        make modules_install
        make INSTALL_PATH=/boot install

        make headers_install INSTALL_HDR_PATH=/usr/include/linux-headers-"$(uname -r)"

        if [ "$(uname -m)" = "aarch64" ]; then
            export ARCH=aarch64
        fi
    '
}
run_checkpoint 21 "build and install kernel + modules" checkpoint_21

checkpoint_22() {
    sudo -E emerge dev-lang/python
    rm -rf /var/tmp/portage/dev-lang/python-*
    eclean-dist -d
}
run_checkpoint 22 "sudo -E emerge dev-lang/python" checkpoint_22

checkpoint_23() {
    sudo -E emerge dev-build/meson
    rm -rf /var/tmp/portage/dev-build/meson-*
    eclean-dist -d
}
run_checkpoint 23 "sudo -E emerge dev-build/meson" checkpoint_23

checkpoint_24() {
    USE="-tiff" sudo -E emerge media-libs/libwebp
    USE="-truetype" sudo -E emerge -1 dev-python/pillow
    sudo -E emerge media-libs/libwebp
    rm -rf /var/tmp/portage/dev-python/pillow-*
    rm -rf /var/tmp/portage/media-libs/libwebp-*
    eclean-dist -d
}
run_checkpoint 24 "sudo -E emerge dev-python/pillow and libwebp" checkpoint_24

checkpoint_25() {
    sudo -E emerge media-libs/harfbuzz
    rm -rf /var/tmp/portage/media-libs/harfbuzz-*
    eclean-dist -d
}
run_checkpoint 25 "sudo -E emerge media-libs/harfbuzz" checkpoint_25

checkpoint_26() {
    sudo -E emerge dev-libs/glib
    rm -rf /var/tmp/portage/dev-libs/glib-*
    eclean-dist -d
}
run_checkpoint 26 "sudo -E emerge dev-libs/glib" checkpoint_26

checkpoint_27() {
    sudo -E emerge dev-util/pkgcon
    rm -rf /var/tmp/portage/dev-util/pkgcon-*
    eclean-dist -d
}
run_checkpoint 27 "sudo -E emerge dev-util/pkgcon" checkpoint_27

checkpoint_28() {
    sudo -E emerge dev-cpp/gtest
    rm -rf /var/tmp/portage/dev-cpp/gtest-*
    eclean-dist -d
}
run_checkpoint 28 "sudo -E emerge dev-cpp/gtest" checkpoint_28

checkpoint_29() {
    sudo -E emerge dev-util/gtest-parallel
    rm -rf /var/tmp/portage/dev-util/gtest-parallel-*
    eclean-dist -d
}
run_checkpoint 29 "sudo -E emerge dev-util/gtest-parallel" checkpoint_29

checkpoint_30() {
    sudo -E emerge dev-util/re2c
    rm -rf /var/tmp/portage/dev-util/re2c-*
    eclean-dist -d
}
run_checkpoint 30 "sudo -E emerge dev-util/re2c" checkpoint_30

checkpoint_31() {
    sudo -E emerge dev-build/ninja
    rm -rf /var/tmp/portage/dev-build/ninja-*
    eclean-dist -d
}
run_checkpoint 31 "sudo -E emerge dev-build/ninja" checkpoint_31

checkpoint_32() {
    sudo -E emerge app-text/docbook2X
    rm -rf /var/tmp/portage/app-text/docbook2X-*
    eclean-dist -d
}
run_checkpoint 32 "sudo -E emerge app-text/docbook2X" checkpoint_32

checkpoint_33() {
    sudo -E emerge app-text/build-docbook-catalog
    rm -rf /var/tmp/portage/app-text/build-docbook-catalog-*
    eclean-dist -d
}
run_checkpoint 33 "sudo -E emerge app-text/build-docbook-catalog" checkpoint_33

checkpoint_34() {
    sudo -E emerge dev-util/gtk-doc
    rm -rf /var/tmp/portage/dev-util/gtk-doc-*
    eclean-dist -d
}
run_checkpoint 34 "sudo -E emerge dev-util/gtk-doc" checkpoint_34

checkpoint_35() {
    sudo -E emerge sys-libs/zlib
    rm -rf /var/tmp/portage/sys-libs/zlib-*
    eclean-dist -d
}
run_checkpoint 35 "sudo -E emerge sys-libs/zlib" checkpoint_35

checkpoint_36() {
    sudo -E emerge dev-libs/libunistring
    rm -rf /var/tmp/portage/dev-libs/libunistring-*
    eclean-dist -d
}
run_checkpoint 36 "sudo -E emerge dev-libs/libunistring" checkpoint_36

checkpoint_37() {
    sudo -E emerge sys-apps/file
    rm -rf /var/tmp/portage/sys-apps/file-*
    eclean-dist -d
}
run_checkpoint 37 "sudo -E emerge sys-apps/file" checkpoint_37

checkpoint_38() {
    sudo -E emerge kde-frameworks/extra-cmake-modules
    rm -rf /var/tmp/portage/kde-frameworks/extra-cmake-modules-*
    eclean-dist -d
}
run_checkpoint 38 "sudo -E emerge kde-frameworks/extra-cmake-modules" checkpoint_38

checkpoint_39() {
    sudo -E emerge -j$(nproc) dev-perl/File-LibMagic
    rm -rf /var/tmp/portage/dev-perl/File-LibMagic-*
    eclean-dist -d
}
run_checkpoint 39 "sudo -E emerge dev-perl/File-LibMagic" checkpoint_39

checkpoint_40() {
    sudo -E emerge net-libs/libpsl
    rm -rf /var/tmp/portage/net-libs/libpsl-*
    eclean-dist -d
}
run_checkpoint 40 "sudo -E emerge net-libs/libpsl" checkpoint_40

checkpoint_41() {
    sudo -E emerge dev-libs/expat
    rm -rf /var/tmp/portage/dev-libs/expat-*
    eclean-dist -d
}
run_checkpoint 41 "sudo -E emerge dev-libs/expat" checkpoint_41

checkpoint_42() {
    sudo -E emerge dev-lang/duktape
    rm -rf /var/tmp/portage/dev-lang/duktape-*
    eclean-dist -d
}
run_checkpoint 42 "sudo -E emerge dev-lang/duktape" checkpoint_42

checkpoint_43() {
    sudo -E emerge app-arch/brotli
    rm -rf /var/tmp/portage/app-arch/brotli-*
    eclean-dist -d
}
run_checkpoint 43 "sudo -E emerge app-arch/brotli" checkpoint_43

checkpoint_44() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}
run_checkpoint 44 "install rustup" checkpoint_44

checkpoint_45() {
    sudo -E emerge -j$(nproc) dev-libs/boehm-gc
    rm -rf /var/tmp/portage/dev-libs/boehm-gc-*
    eclean-dist -d
}
run_checkpoint 45 "sudo -E emerge dev-libs/boehm-gc" checkpoint_45

checkpoint_46() {
    MEM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    MEM_GB=$(( (MEM_KB + 1024*1024 - 1) / (1024*1024) ))
    THREADS=$(( MEM_GB / 2 ))
    (( THREADS < 1 )) && THREADS=1 
    TOTAL_CORES=$(nproc)
    PCT=$(( THREADS * 100 / TOTAL_CORES ))
    (( PCT > 100 )) && PCT=100
    SMRT "$PCT"
    sudo -E emerge sys-auth/polkit
    rm -rf /var/tmp/portage/sys-auth/polkit-*
    eclean-dist -d
}
run_checkpoint 46 "sudo -E emerge sys-auth/polkit" checkpoint_46

checkpoint_47() {
    sudo -E emerge sys-apps/bubblewrap
    rm -rf /var/tmp/portage/sys-apps/bubblewrap-*
    eclean-dist -d
}
run_checkpoint 47 "sudo -E emerge sys-apps/bubblewrap" checkpoint_47
# Fix for long term
checkpoint_48() {
    sudo -E emerge -v =llvm-core/libclc-20*
    sudo -E emerge llvm-runtimes/libcxx
    sudo -E emerge llvm-runtimes/libcxxabi
    rm -rf /var/tmp/portage/llvm-core/libclc-*
    rm -rf /var/tmp/portage/llvm-runtimes/libcxx-*
    rm -rf /var/tmp/portage/llvm-runtimes/libcxxabi-*
    eclean-dist -d
}
run_checkpoint 48 "sudo -E emerge llvm-core/libclc-20" checkpoint_48

checkpoint_49() {
    SMRT 75
    sudo -E emerge x11-base/xorg-drivers
    rm -rf /var/tmp/portage/x11-base/xorg-drivers-*
    eclean-dist -d
}
run_checkpoint 49 "sudo -E emerge x11-base/xorg-drivers" checkpoint_49

checkpoint_50() {
    sudo -E emerge x11-base/xorg-server
    rm -rf /var/tmp/portage/x11-base/xorg-server-*
    eclean-dist -d
}
run_checkpoint 50 "sudo -E emerge x11-base/xorg-server" checkpoint_50

checkpoint_51() {
    sudo -E emerge x11-base/xorg-apps
    rm -rf /var/tmp/portage/x11-base/xorg-apps-*
    eclean-dist -d
}
run_checkpoint 51 "sudo -E emerge x11-base/xorg-apps" checkpoint_51

checkpoint_52() {
    sudo -E emerge x11-libs/libX11
    rm -rf /var/tmp/portage/x11-libs/libX11-*
    eclean-dist -d
}
run_checkpoint 52 "sudo -E emerge x11-libs/libX11" checkpoint_52

checkpoint_53() {
    sudo -E emerge x11-libs/libXft
    rm -rf /var/tmp/portage/x11-libs/libXft-*
    eclean-dist -d
}
run_checkpoint 53 "sudo -E emerge x11-libs/libXft" checkpoint_53

checkpoint_54() {
    sudo -E emerge x11-libs/libXrender
    rm -rf /var/tmp/portage/x11-libs/libXrender-*
    eclean-dist -d
}
run_checkpoint 54 "sudo -E emerge x11-libs/libXrender" checkpoint_54

checkpoint_55() {
    sudo -E emerge x11-libs/libXrandr
    rm -rf /var/tmp/portage/x11-libs/libXrandr-*
    eclean-dist -d
}
run_checkpoint 55 "sudo -E emerge x11-libs/libXrandr" checkpoint_55

checkpoint_56() {
    sudo -E emerge x11-libs/libXcursor
    rm -rf /var/tmp/portage/x11-libs/libXcursor-*
    eclean-dist -d
}
run_checkpoint 56 "sudo -E emerge x11-libs/libXcursor" checkpoint_56

checkpoint_57() {
    sudo -E emerge x11-libs/libXi
    rm -rf /var/tmp/portage/x11-libs/libXi-*
    eclean-dist -d
}
run_checkpoint 57 "sudo -E emerge x11-libs/libXi" checkpoint_57

checkpoint_58() {
    sudo -E emerge x11-libs/libXinerama
    rm -rf /var/tmp/portage/x11-libs/libXinerama-*
    eclean-dist -d
}
run_checkpoint 58 "sudo -E emerge x11-libs/libXinerama" checkpoint_58

checkpoint_59() {
    sudo -E emerge x11-libs/pango
    rm -rf /var/tmp/portage/x11-libs/pango-*
    eclean-dist -d
}
run_checkpoint 59 "sudo -E emerge x11-libs/pango" checkpoint_59

checkpoint_60() {
    sudo -E emerge dev-libs/wayland
    rm -rf /var/tmp/portage/dev-libs/wayland-*
    eclean-dist -d
}
run_checkpoint 60 "sudo -E emerge dev-libs/wayland" checkpoint_60

checkpoint_61() {
    sudo -E emerge dev-libs/wayland-protocols
    rm -rf /var/tmp/portage/dev-libs/wayland-protocols-*
    eclean-dist -d
}
run_checkpoint 61 "sudo -E emerge dev-libs/wayland-protocols" checkpoint_61

checkpoint_62() {
    sudo -E emerge x11-base/xwayland
    rm -rf /var/tmp/portage/x11-base/xwayland-*
    eclean-dist -d
}
run_checkpoint 62 "sudo -E emerge x11-base/xwayland" checkpoint_62

checkpoint_63() {
    sudo -E emerge x11-libs/libxkbcommon
    rm -rf /var/tmp/portage/x11-libs/libxkbcommon-*
    eclean-dist -d
}
run_checkpoint 63 "sudo -E emerge x11-libs/libxkbcommon" checkpoint_63

checkpoint_64() {
    sudo -E emerge gui-libs/gtk
    rm -rf /var/tmp/portage/gui-libs/gtk-*
    eclean-dist -d
}
run_checkpoint 64 "sudo -E emerge gui-libs/gtk" checkpoint_64

checkpoint_65() {
    sudo -E emerge xfce-base/libxfce4util
    rm -rf /var/tmp/portage/xfce-base/libxfce4util-*
    eclean-dist -d
}
run_checkpoint 65 "sudo -E emerge xfce-base/libxfce4util" checkpoint_65

checkpoint_66() {
    sudo -E emerge xfce-base/xfconf
    rm -rf /var/tmp/portage/xfce-base/xfconf-*
    eclean-dist -d
}
run_checkpoint 66 "sudo -E emerge xfce-base/xfconf" checkpoint_66

checkpoint_67() {
    sudo -E emerge sys-apps/xdg-desktop-portal
    rm -rf /var/tmp/portage/sys-apps/xdg-desktop-portal-*
    eclean-dist -d
}
run_checkpoint 67 "sudo -E emerge sys-apps/xdg-desktop-portal" checkpoint_67

checkpoint_68() {
    sudo -E emerge gui-libs/xdg-desktop-portal-wlr
    rm -rf /var/tmp/portage/gui-libs/xdg-desktop-portal-wlr-*
    eclean-dist -d
}
run_checkpoint 68 "sudo -E emerge gui-libs/xdg-desktop-portal-wlr" checkpoint_68

checkpoint_69() {
    sudo -E emerge media-libs/mesa
    rm -rf /var/tmp/portage/media-libs/mesa-*
    eclean-dist -d
}
run_checkpoint 69 "sudo -E emerge media-libs/mesa" checkpoint_69

checkpoint_70() {
    sudo -E emerge x11-apps/mesa-progs
    rm -rf /var/tmp/portage/x11-apps/mesa-progs-*
    eclean-dist -d
}
run_checkpoint 70 "sudo -E emerge x11-apps/mesa-progs" checkpoint_70

checkpoint_71() {
    sudo -E emerge dev-qt/qtbase
    rm -rf /var/tmp/portage/dev-qt/qtbase-*
    eclean-dist -d
}
run_checkpoint 71 "sudo -E emerge dev-qt/qtbase" checkpoint_71

checkpoint_72() {
    sudo -E emerge dev-qt/qttools
    rm -rf /var/tmp/portage/dev-qt/qttools-*
    eclean-dist -d
}
run_checkpoint 72 "sudo -E emerge dev-qt/qttools" checkpoint_72

checkpoint_73() {
    sudo -E emerge dev-qt/qtnetwork
    rm -rf /var/tmp/portage/dev-qt/qtnetwork-*
    eclean-dist -d
}
run_checkpoint 73 "sudo -E emerge dev-qt/qtnetwork" checkpoint_73

checkpoint_74() {
    sudo -E emerge dev-qt/qtconcurrent
    rm -rf /var/tmp/portage/dev-qt/qtconcurrent-*
    eclean-dist -d
}
run_checkpoint 74 "sudo -E emerge dev-qt/qtconcurrent" checkpoint_74

checkpoint_75() {
    sudo -E emerge dev-qt/qtxml
    rm -rf /var/tmp/portage/dev-qt/qtxml-*
    eclean-dist -d
}
run_checkpoint 75 "sudo -E emerge dev-qt/qtxml" checkpoint_75

checkpoint_76() {
    sudo -E emerge dev-qt/qtgui
    rm -rf /var/tmp/portage/dev-qt/qtgui-*
    eclean-dist -d
}
run_checkpoint 76 "sudo -E emerge dev-qt/qtgui" checkpoint_76

checkpoint_77() {
    sudo -E emerge dev-qt/qtcore
    rm -rf /var/tmp/portage/dev-qt/qtcore-*
    eclean-dist -d
}
run_checkpoint 77 "sudo -E emerge dev-qt/qtcore" checkpoint_77

checkpoint_78() {
    sudo -E emerge dev-build/cmake
    rm -rf /var/tmp/portage/dev-build/cmake-*
    eclean-dist -d
}
run_checkpoint 78 "sudo -E emerge dev-build/cmake" checkpoint_78

checkpoint_79() {
    sudo -E emerge sys-apps/dbus
    rm -rf /var/tmp/portage/sys-apps/dbus-*
    eclean-dist -d
}
run_checkpoint 79 "sudo -E emerge sys-apps/dbus" checkpoint_79

checkpoint_80() {
    sudo -E emerge app-accessibility/at-spi2-core
    rm -rf /var/tmp/portage/app-accessibility/at-spi2-core-*
    eclean-dist -d
}
run_checkpoint 80 "sudo -E emerge app-accessibility/at-spi2-core" checkpoint_80

checkpoint_81() {
    sudo -E emerge app-accessibility/at-spi2-atk
    rm -rf /var/tmp/portage/app-accessibility/at-spi2-atk-*
    eclean-dist -d
}
run_checkpoint 81 "sudo -E emerge app-accessibility/at-spi2-atk" checkpoint_81

checkpoint_82() {
    sudo -E emerge media-libs/fontconfig
    rm -rf /var/tmp/portage/media-libs/fontconfig-*
    eclean-dist -d
}
run_checkpoint 82 "sudo -E emerge media-libs/fontconfig" checkpoint_82

checkpoint_83() {
    sudo -E emerge media-fonts/dejavu
    rm -rf /var/tmp/portage/media-fonts/dejavu-*
    eclean-dist -d
}
run_checkpoint 83 "sudo -E emerge media-fonts/dejavu" checkpoint_83

checkpoint_84() {
    sudo -E emerge x11-themes/gtk-engines
    rm -rf /var/tmp/portage/x11-themes/gtk-engines-*
    eclean-dist -d
}
run_checkpoint 84 "sudo -E emerge x11-themes/gtk-engines" checkpoint_84

checkpoint_85() {
    sudo -E emerge x11-themes/gtk-engines-murrine
    rm -rf /var/tmp/portage/x11-themes/gtk-engines-murrine-*
    eclean-dist -d
}
run_checkpoint 85 "sudo -E emerge x11-themes/gtk-engines-murrine" checkpoint_85

checkpoint_86() {
    sudo -E emerge dev-lang/python
    sudo -E emerge dev-python/pip
    rm -rf /var/tmp/portage/dev-lang/python-*
    rm -rf /var/tmp/portage/dev-lang/pip-*
    eclean-dist -d
}
run_checkpoint 86 "sudo -E emerge dev-lang/python" checkpoint_86

checkpoint_87() {
    sudo -E emerge x11-libs/libnotify
    rm -rf /var/tmp/portage/x11-libs/libnotify-*
    eclean-dist -d
}
run_checkpoint 87 "sudo -E emerge x11-libs/libnotify" checkpoint_87

checkpoint_88() {
    sudo -E emerge dev-libs/libdbusmenu
    rm -rf /var/tmp/portage/dev-libs/libdbusmenu-*
    eclean-dist -d
}
run_checkpoint 88 "sudo -E emerge dev-libs/libdbusmenu" checkpoint_88

checkpoint_89() {
    sudo -E emerge x11-libs/libSM
    rm -rf /var/tmp/portage/x11-libs/libSM-*
    eclean-dist -d
}
run_checkpoint 89 "sudo -E emerge x11-libs/libSM" checkpoint_89

checkpoint_90() {
    sudo -E emerge x11-libs/libICE
    rm -rf /var/tmp/portage/x11-libs/libICE-*
    eclean-dist -d
}
run_checkpoint 90 "sudo -E emerge x11-libs/libICE" checkpoint_90

checkpoint_91() {
    sudo -E emerge x11-libs/libwnck
    rm -rf /var/tmp/portage/x11-libs/libwnck-*
    eclean-dist -d
}
run_checkpoint 91 "sudo -E emerge x11-libs/libwnck" checkpoint_91

checkpoint_92() {
    sudo -E emerge dev-build/cmake
    rm -rf /var/tmp/portage/dev-build/cmake-*
    eclean-dist -d
}
run_checkpoint 92 "sudo -E emerge dev-build/cmake" checkpoint_92

checkpoint_93() {
    sudo -E emerge xfce-base/exo
    rm -rf /var/tmp/portage/xfce-base/exo-*
    eclean-dist -d
}
run_checkpoint 93 "sudo -E emerge xfce-base/exo" checkpoint_93

checkpoint_94() {
    sudo -E emerge app-admin/exo
    rm -rf /var/tmp/portage/app-admin/exo-*
    eclean-dist -d
}
run_checkpoint 94 "sudo -E emerge app-admin/exo" checkpoint_94

checkpoint_95() {
    sudo -E emerge app-arch/tar
    rm -rf /var/tmp/portage/app-arch/tar-*
    eclean-dist -d
}
run_checkpoint 95 "sudo -E emerge app-arch/tar" checkpoint_95

checkpoint_96() {
    sudo -E emerge app-arch/xz-utils
    rm -rf /var/tmp/portage/app-arch/xz-utils-*
    eclean-dist -d
}
run_checkpoint 96 "sudo -E emerge app-arch/xz-utils" checkpoint_96

checkpoint_97() {
    sudo -E emerge net-libs/gnutls
    rm -rf /var/tmp/portage/net-libs/gnutls-*
    eclean-dist -d
}
run_checkpoint 97 "sudo -E emerge net-libs/gnutls" checkpoint_97

checkpoint_98() {
    sudo -E emerge net-libs/glib-networking
    rm -rf /var/tmp/portage/net-libs/glib-networking-*
    eclean-dist -d
}
run_checkpoint 98 "sudo -E emerge net-libs/glib-networking" checkpoint_98

checkpoint_99() {
    sudo -E emerge sys-libs/libseccomp
    rm -rf /var/tmp/portage/sys-libs/libseccomp-*
    eclean-dist -d
}
run_checkpoint 99 "sudo -E emerge sys-libs/libseccomp" checkpoint_99

checkpoint_100() {
    sudo -E emerge app-eselect/eselect-repository
    rm -rf /var/tmp/portage/app-eselect/eselect-repository-*
    eclean-dist -d
}
run_checkpoint 100 "sudo -E emerge app-eselect/eselect-repository" checkpoint_100

checkpoint_101() {
    sudo -E emerge dev-libs/appstream-glib
    rm -rf /var/tmp/portage/dev-libs/appstream-glib-*
    eclean-dist -d
}
run_checkpoint 101 "sudo -E emerge dev-libs/appstream-glib" checkpoint_101

checkpoint_102() {
    sudo -E emerge app-crypt/gpgme
    rm -rf /var/tmp/portage/app-crypt/gpgme-*
    eclean-dist -d
}
run_checkpoint 102 "sudo -E emerge app-crypt/gpgme" checkpoint_102

checkpoint_103() {
    sudo -E emerge dev-util/ostree
    rm -rf /var/tmp/portage/dev-util/ostree-*
    eclean-dist -d
}
run_checkpoint 103 "sudo -E emerge dev-util/ostree" checkpoint_103

checkpoint_104() {
    sudo -E emerge sys-apps/xdg-dbus-proxy
    rm -rf /var/tmp/portage/sys-apps/xdg-dbus-proxy-*
    eclean-dist -d
}
run_checkpoint 104 "sudo -E emerge sys-apps/xdg-dbus-proxy" checkpoint_104

checkpoint_105() {
    sudo -E emerge x11-libs/gdk-pixbuf
    rm -rf /var/tmp/portage/x11-libs/gdk-pixbuf-*
    eclean-dist -d
}
run_checkpoint 105 "sudo -E emerge x11-libs/gdk-pixbuf" checkpoint_105

checkpoint_106() {
    sudo -E emerge sys-fs/fuse
    rm -rf /var/tmp/portage/sys-fs/fuse-*
    eclean-dist -d
}
run_checkpoint 106 "sudo -E emerge sys-fs/fuse" checkpoint_106

checkpoint_107() {
    sudo -E emerge dev-python/pygobject
    rm -rf /var/tmp/portage/dev-python/pygobject-*
    eclean-dist -d
}
run_checkpoint 107 "sudo -E emerge dev-python/pygobject" checkpoint_107

checkpoint_108() {
    sudo -E emerge gnome-base/dconf
    rm -rf /var/tmp/portage/gnome-base/dconf-*
    eclean-dist -d
}
run_checkpoint 108 "sudo -E emerge gnome-base/dconf" checkpoint_108

checkpoint_109() {
    sudo -E emerge x11-misc/xdg-utils
    rm -rf /var/tmp/portage/x11-misc/xdg-utils-*
    eclean-dist -d
}
run_checkpoint 109 "sudo -E emerge x11-misc/xdg-utils" checkpoint_109

checkpoint_110() {
    sudo -E emerge x11-apps/xinit
    rm -rf /var/tmp/portage/x11-apps/xinit-*
    eclean-dist -d
}
run_checkpoint 110 "sudo -E emerge x11-apps/xinit" checkpoint_110

checkpoint_111() {
    sudo -E emerge x11-terms/xterm
    rm -rf /var/tmp/portage/x11-terms/xterm-*
    eclean-dist -d
}
run_checkpoint 111 "sudo -E emerge x11-terms/xterm" checkpoint_111

checkpoint_112() {
    sudo -E emerge x11-wm/twm
    rm -rf /var/tmp/portage/x11-wm/twm-*
    eclean-dist -d
}
run_checkpoint 112 "sudo -E emerge x11-wm/twm" checkpoint_112

checkpoint_113() {
    sudo -E emerge dev-python/pillow
    sudo -E emerge app-misc/fastfetch
    rm -rf /var/tmp/portage/dev-python/pillow-*
    rm -rf /var/tmp/portage/app-misc/fastfetch-*
    eclean-dist -d
}
run_checkpoint 113 "sudo -E emerge dev-python/pillow + fastfetch" checkpoint_113

checkpoint_114() {
    sudo -E emerge media-gfx/chafa
    rm -rf /var/tmp/portage/media-gfx/chafa-*
    eclean-dist -d
}
run_checkpoint 114 "sudo -E emerge media-gfx/chafa" checkpoint_114

checkpoint_115() {
    sudo -E emerge app-text/doxygen
    rm -rf /var/tmp/portage/app-text/doxygen-*
    eclean-dist -d
}
run_checkpoint 115 "sudo -E emerge app-text/doxygen" checkpoint_115

checkpoint_116() {
    sudo -E emerge -1 =llvm-core/libclc-20*
    sudo -E emerge gui-libs/egl-gbm
    rm -rf /var/tmp/portage/gui-libs/egl-gbm-*
    eclean-dist -d
}
run_checkpoint 116 "sudo -E emerge gui-libs/egl-gbm" checkpoint_116

checkpoint_117() {
    cd /tmp
    git clone https://chromium.googlesource.com/chromiumos/platform2
    cd platform2/vm_tools/sommelier
    meson setup build
    ninja -C build
    sudo -E ninja -C build install
    sudo rm -rf /tmp/platform2
}
run_checkpoint 117 "Build Sommelier" checkpoint_117

checkpoint_118() {
    sudo -E emerge sys-apps/flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    rm -rf /var/tmp/portage/sys-apps/flatpak-*
    chown -R 1000:1000 ~/.local/share/flatpak
    eclean-dist -d
}
run_checkpoint 118 "sudo -E emerge sys-apps/flatpak" checkpoint_118

checkpoint_119() {
    sudo -E emerge app-admin/sudo
    rm -rf /var/tmp/portage/app-admin/sudo-*
    eclean-dist -d
}
run_checkpoint 119 "sudo -E emerge app-admin/sudo" checkpoint_119

#checkpoint_120() {
#    sudo -E emerge x11-misc/xkeyboard-config
#    rm -rf /var/tmp/portage/x11-misc/xkeyboard-config-*
#    eclean-dist -d
#}
#run_checkpoint 120 "sudo -E emerge x11-misc/xkeyboard-config" checkpoint_120


checkpoint_121() {
    USE="udisks" sudo -E emerge xfce-base/thunar
    rm -rf /var/tmp/portage/xfce-base/thunar-*
    eclean-dist -d
}
run_checkpoint 121 "sudo -E emerge xfce-base/thunar" checkpoint_121

checkpoint_122() {
    USE="udisks" sudo -E emerge gnome-base/gvfs
    rm -rf /var/tmp/portage/gnome-base/gvfs-*
    eclean-dist -d
}
run_checkpoint 122 "sudo -E emerge gnome-base/gvfs" checkpoint_122

checkpoint_123() {
    sudo -E emerge xfce-base/xfce4-meta
    rm -rf /var/tmp/portage/xfce-base/xfce4-meta-*
    eclean-dist -d
}
run_checkpoint 123 "sudo -E emerge xfce-base/xfce4-meta" checkpoint_123

checkpoint_123() {
    sudo -E emerge media-libs/libao
    sudo -E emerge net-misc/yt-dlp
    sudo -E emerge media-libs/opus
    sudo -E emerge media-video/vlc
    rm -rf /var/tmp/portage/net-misc/libao-*
    rm -rf /var/tmp/portage/net-misc/yt-dlp-*
    rm -rf /var/tmp/portage/media-libs/libopus-*
    rm -rf /var/tmp/portage/media-video/vlc-*
    eclean-dist -d
}
run_checkpoint 123 "sudo -E emerge vlc" checkpoint_123

checkpoint_124() {
    sudo -E emerge media-libs/libva
    libva-intel-media-driver
    rm -rf /var/tmp/portage/media-libs/libva-*
    eclean-dist -d
}
run_checkpoint 124 "sudo -E emerge media-libs/libva" checkpoint_124

checkpoint_125() {
    detect_intel_gpu() {
        if [ -f "/sys/class/drm/card0/gt_max_freq_mhz" ]; then
            GPU_MAX_FREQ=$(cat /sys/class/drm/card0/gt_max_freq_mhz)
            GPU_TYPE="intel"
            echo "[*] Detected Intel GPU: max freq ${GPU_MAX_FREQ} MHz"
            return 0
        else
            GPU_TYPE="unknown"
            echo "[*] No Intel GPU detected, skipping this checkpoint"
            return 1
        fi
    }

    if detect_intel_gpu; then
        echo "[*] Installing libva-intel-media-driver for Gen9+ Intel GPU"
        echo "media-libs/libva-intel-media-driver no-source-code" | sudo tee -a /etc/portage/package.license
        sudo -E emerge media-libs/libva-intel-media-driver
        rm -rf /var/tmp/portage/media-libs/libva-intel-media-driver-*
        eclean-dist -d
    else
        echo "[*] Skipping Intel driver installation"
    fi
}
run_checkpoint 125 "sudo -E emerge media-libs/libva-intel-media-driver" checkpoint_125

checkpoint_126() {
    echo "media-plugins/alsa-plugins pulseaudio" | sudo tee -a /etc/portage/package.use/firefox-bin
    sudo -E emerge --autounmask-write firefox-bin
    sudo -E emerge firefox-bin
    rm -rf /var/tmp/portage/www-client/firefox-bin-*
    eclean-dist -d
}
run_checkpoint 126 "sudo -E emerge firefox" checkpoint_126

checkpoint_127() {
    sudo chown -R 1000:1000 ~/
    sudo -E emerge dev-util/vulkan-tools
    sudo -E emerge app-eselect/eselect-repository
    sudo -E eselect repository enable another-brave-overlay
    sudo -E emerge --sync another-brave-overlay
    sudo -E emerge www-client/brave-browser::another-brave-overlay
    rm -rf /var/tmp/portage/dev-util/vulkan-tools-*
    rm -rf /var/tmp/portage/eselect-repository dev-vcs/git-*
    rm -rf /var/tmp/portage/www-client/brave-browser-*
    eclean-dist -d
}
run_checkpoint 127 "sudo -E emerge www-client/brave-browser::another-brave-overlay" checkpoint_127

checkpoint_128() {
    echo "app-arch/lha lha" | sudo tee -a /etc/portage/package.license
    echo "app-arch/unrar unRAR" | sudo tee -a /etc/portage/package.license
    echo "app-arch/rar RAR" | sudo tee -a /etc/portage/package.license
    sudo -E emerge app-arch/p7zip app-arch/arj app-arch/lha app-arch/lzop app-arch/unrar app-arch/rar app-arch/unzip app-arch/zip app-arch/xarchiver
    rm -rf /var/tmp/portage/app-arch/p7zip-*
    rm -rf /var/tmp/portage/app-arch/arj-*
    rm -rf /var/tmp/portage/app-arch/lha-*
    rm -rf /var/tmp/portage/app-arch/lzop-*
    rm -rf /var/tmp/portage/app-arch/unrar-*
    rm -rf /var/tmp/portage/app-arch/rar-*
    rm -rf /var/tmp/portage/app-arch/unzip-*
    rm -rf /var/tmp/portage/app-arch/zip-*
    rm -rf /var/tmp/portage/app-arch/xarchiver-*
    eclean-dist -d
}
run_checkpoint 128 "xarchiver" checkpoint_128

checkpoint_129() {
    sudo -E emerge app-editors/vscodium
    rm -rf /var/tmp/portage/app-editors/vscodium-*
    eclean-dist -d
}
run_checkpoint 129 "sudo -E emerge app-editors/vscodium" checkpoint_129

checkpoint_130() {
    sudo -E emerge games-util/gamemode
    sudo -E emerge games-action/prismlauncher
    rm -rf /var/tmp/portage/games-util/gamemode-*
    rm -rf /var/tmp/portage/games-action/prismlauncher-*
    eclean-dist -d
}
run_checkpoint 130 "sudo -E emerge games-action/prismlauncher" checkpoint_130

checkpoint_131() {
    sudo -E emerge media-gfx/gimp
    rm -rf /var/tmp/portage/media-gfx/gimp-*
    eclean-dist -d
}
run_checkpoint 131 "sudo -E emerge media-gfx/gimp" checkpoint_131

checkpoint_132() {
    cd /usr/share/xkeyboard-config-2/symbols/inet
    sudo cp inet ~/.inet.backup
    sudo sed -i -E 's/^\s*key <I(360|362|368|370|373|374|376|377|381|384|385|386|387|388|389|391|392|393|394|395|396|398|417|421|570|598|599)>/\/\/ &/' "/usr/share/xkeyboard-config-2/symbols/inet"
}
run_checkpoint 132 "Keyboard error spam fix" checkpoint_132

checkpoint_133() {
    sudo -E emerge app-office/libreoffice-bin
    rm -rf /var/tmp/portage/app-office/libreoffice-bin-*
    eclean-dist -d
}
run_checkpoint 133 "sudo -E emerge app-office/libreoffice-bin" checkpoint_133

sudo -E emerge app-office/libreoffice-bin

checkpoint_134() {
    echo "media-video/obs-studio" | sudo tee -a /etc/portage/package.use/obs
    sudo -E emerge media-plugins/obs-vkcapture
    sudo -E emerge media-video/obs-studio
    rm -rf /var/tmp/portage/media-video/obs-studio-*
    eclean-dist -d
}
run_checkpoint 134 "sudo -E emerge media-video/obs-studio" checkpoint_131

checkpoint_135() {
    USE="ruby_targets_ruby34" sudo -E emerge dev-lang/ruby
    rm -rf /var/tmp/portage/dev-lang/ruby-*
    eclean-dist -d
}
run_checkpoint 135 "sudo -E emerge dev-lang/ruby" checkpoint_135

checkpoint_136() {
sudo chown -R 1000:1000 ~/
}
run_checkpoint 136 "sudo chown -R $USER:$USER $HOME" checkpoint_136

# dolphin
# echo "games-emulation/dolphin ~amd64" | sudo tee -a /etc/portage/package.accept_keywords
# echo "games-emulation/dolphin FatFs" | sudo tee -a /etc/portage/package.license
# sudo -E emerge games-emulation/dolphin

#checkpoint_118() {
#    sudo -E emerge sys-apps/flatpak
#    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
#    flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
#    rm -rf /var/tmp/portage/sys-apps/flatpak-*
#    chown -R 1000:1000 /home/chronos/.local/share/flatpak
#    eclean-dist -d
#}
#run_checkpoint 118 "sudo -E emerge sys-apps/flatpak" checkpoint_118

checkpoint_137() {
    sudo -E emerge games-util/heroic-bin
    sudo chown root:root /opt/heroic-2.18.1/chrome-sandbox
    sudo chmod 4755 /opt/heroic-2.18.1/chrome-sandbox
    sudo chown -R 1000:1000 ~/.config/heroic
    rm -rf /var/tmp/portage/games-util/heroic-bin-*
    eclean-dist -d
}
run_checkpoint 137 "sudo -E emerge games-util/heroic-bin" checkpoint_137

checkpoint_138() {
    sudo -E emerge sys-block/gparted
    sudo -E emerge sys-fs/exfatprogs sys-fs/dosfstools sys-fs/ntfs3g
    sudo -E emerge sys-fs/mtools
    rm -rf /var/tmp/portage/sys-block/gparted-*
    rm -rf /var/tmp/portage/emerge sys-fs/exfatprogs-*
    rm -rf /var/tmp/portage/sys-fs/dosfstools-*
    rm -rf /var/tmp/portage/sys-fs/ntfs3g-*
    rm -rf /var/tmp/portage/sys-fs/mtools-*
    eclean-dist -d
}
run_checkpoint 138 "sudo -E emerge sys-block/gparted" checkpoint_138

checkpoint_139() {
    sudo curl -L -o /usr/local/bin/unetbootin https://github.com/unetbootin/unetbootin/releases/download/702/unetbootin-linux64-702.bin
    sudo chmod +x /usr/local/bin/unetbootin
}
run_checkpoint 139 "unetbootin" checkpoint_139

checkpoint_140() {
    sudo -E emerge app-emulation/qemu
    sudo -E emerge qemu-init-scripts
    sudo -E emerge sys-apps/usermode-utilities
    rm -rf /var/tmp/app-emulation/qemu*
    rm -rf /var/tmp/qemu-init-scripts*
    rm -rf /var/tmp/sys-apps/usermode-utilities*
    eclean-dist -d
}
run_checkpoint 140 "sudo -E emerge app-emulation/qemu" checkpoint_140

checkpoint_141() {
    cd ~/
    rm -rf bubblepatch 2>/dev/null
    git clone https://github.com/shadowed1/bubblepatch.git
    cd bubblepatch
    sudo mkdir -p /usr/local/bubblepatch
    meson setup -Dprefix=/usr/local/bubblepatch build
    ninja -C build
    sudo ninja -C build install
    cd ~/
    rm -rf bubblepatch 2>/dev/null

    sudo tee /bin/chard_firefox-bin >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
HOME=/$CHARD_HOME
USER=$CHARD_USER
PATH=/usr/local/bubblepatch/bin:$PATH
xhost +SI:localuser:root
source ~/.bashrc
sudo -u $CHARD_USER /usr/bin/firefox-bin
EOF
    sudo chmod +x /bin/chard_firefox-bin

sudo tee /bin/chard_flatpak >/dev/null <<'EOF'
#!/bin/bash
export PATH=/usr/local/bubblepatch/bin:$PATH
xhost +SI:localuser:root
sudo setfacl -Rm u:root:rwx /run/chrome 2>/dev/null
sudo setfacl -Rm u:1000:rwx /run/chrome 2>/dev/null
sudo -E /usr/bin/env bash -c '
  exec /usr/bin/flatpak "$@"
' -- "$@"
sudo setfacl -Rb /run/chrome 2>/dev/null
EOF
    sudo chmod +x /bin/chard_flatpak
}
run_checkpoint 141 "Chard Bubblepatch" checkpoint_141

checkpoint_142() {
    sudo -E emerge gedit
    eclean-dist -d
}
run_checkpoint 142 "sudo -E emerge gedit" checkpoint_142

checkpoint_143() {
    ARCH=$(uname -m)
    sudo rm /etc/pipewire/pipewire.conf.d/crostini-audio.conf 2>/dev/null
    rm -rf ~/.config/pulse 2>/dev/null
    rm -rf ~/.pulse 2>/dev/null
    rm -rf ~/.cache/pulse 2>/dev/null
    cd ~/
    sudo -E emerge media-sound/pulseaudio-ctl
    git clone --depth 1 https://github.com/shadowed1/alsa-ucm-conf-cros
    cd alsa-ucm-conf-cros
    sudo mkdir -p /usr/share/alsa
    sudo cp -r ucm2 /usr/share/alsa
    sudo cp -r overrides /usr/share/alsa/ucm2/conf.d
    cd ~/
    rm -rf alsa-ucm-conf-cros
    sleep 1
    sudo rm -rf ~/.cache/bazel 2>/dev/null
    if [[ "$ARCH" == "x86_64" ]]; then
        BAZEL_URL="https://github.com/bazelbuild/bazel/releases/download/6.5.0/bazel-6.5.0-linux-x86_64"
        echo "Downloading Bazel from: $BAZEL_URL"
        sudo curl -L "$BAZEL_URL" -o /usr/bin/bazel65
        sudo chmod +x /usr/bin/bazel65
        rm -rf ~/adhd
        cd ~/
        git clone https://chromium.googlesource.com/chromiumos/third_party/adhd
        cd adhd/
        sudo -E /usr/bin/bazel65 build //dist:alsa_lib
        sleep 1
        sudo mkdir -p /usr/lib64/alsa-lib/
        sudo cp ~/adhd/bazel-bin/cras/src/alsa_plugin/libasound_module_ctl_cras.so /usr/lib64/alsa-lib/
        sudo cp ~/adhd/bazel-bin/cras/src/alsa_plugin/libasound_module_pcm_cras.so /usr/lib64/alsa-lib/
        sudo cp ~/adhd/bazel-bin/cras/src/libcras/libcras.so /usr/lib64/
        sudo mkdir -p /etc/pipewire/pipewire.conf.d
        cd ~/
        rm -rf ~/adhd
    elif [[ "$ARCH" == "aarch64" ]]; then
        BAZEL_URL="https://github.com/bazelbuild/bazel/releases/download/6.5.0/bazel-6.5.0-linux-arm64"
        echo "Downloading Bazel from: $BAZEL_URL"
        sudo curl -L "$BAZEL_URL" -o /usr/bin/bazel65
        sudo chmod +x /usr/bin/bazel65
        cd ~/
        git clone https://chromium.googlesource.com/chromiumos/third_party/adhd
        cd adhd/
        sudo -E /usr/bin/bazel65 build //dist:alsa_lib
        sleep 1
        sudo mkdir -p /usr/lib64/alsa-lib/
        sudo cp ~/adhd/bazel-bin/cras/src/alsa_plugin/libasound_module_ctl_cras.so /usr/lib64/alsa-lib/
        sudo cp ~/adhd/bazel-bin/cras/src/alsa_plugin/libasound_module_pcm_cras.so /usr/lib64/alsa-lib/
        sudo cp ~/adhd/bazel-bin/cras/src/libcras/libcras.so /usr/lib64/
        sudo mkdir -p /etc/pipewire/pipewire.conf.d
        cd ~/
        rm -rf ~/adhd
    else
        echo "Unsupported architecture: $ARCH"
    fi
}
run_checkpoint 143 "xkbcomp" checkpoint_143

checkpoint_144() {
    sudo -E emerge xkbcomp
    eclean-dist -d
}
run_checkpoint 144 "xkbcomp" checkpoint_144

checkpoint_145() {
    sudo -E emerge coreutils
    eclean-dist -d
}
run_checkpoint 145 "coreutils" checkpoint_145

checkpoint_146() {
     sudo -E emerge media-libs/libpulse
     sudo -E emerge media-sound/pulseaudio-daemon
     sudo -E emerge media-sound/alsa-utils
     sudo -E emerge pavucontrol
     mv ~/.config/pulse/default.pa ~/.config/pulse/default.pa.bak 2>/dev/null
     eclean-dist -d
}
run_checkpoint 146 "pulseaudio" checkpoint_146

checkpoint_147() {
     gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
mkdir -p ~/.config/gtk-3.0
tee ~/.config/gtk-3.0/settings.ini >/dev/null <<'EOF'
[Settings]
gtk-theme-name=Adwaita-dark
gtk-application-prefer-dark-theme=1
EOF
mkdir -p ~/.config/gtk-4.0
tee ~/.config/gtk-4.0/settings.ini >/dev/null <<'EOF'
[Settings]
gtk-theme-name=Adwaita-dark
gtk-application-prefer-dark-theme=1
EOF
}
run_checkpoint 147 "Dark Theme" checkpoint_147

sudo -E chown -R $USER:$USER $HOME
echo "Chard Root is Ready! ${RESET}"
show_progress

case "$1" in
    reset)
        reset
        ;;
    ''|*[!0-9]*)
        if [[ -f "$CHECKPOINT_FILE" ]]; then
            CURRENT_CHECKPOINT=$(cat "$CHECKPOINT_FILE")
        else
            echo "0" | sudo tee "$CHECKPOINT_FILE" >/dev/null
            CURRENT_CHECKPOINT=0
        fi
        ;;
    [0-9]*)
        if ! $SINGLE_STEP; then
            CHECKPOINT_OVERRIDE=$1
            echo "${MAGENTA}Setting checkpoint to $CHECKPOINT_OVERRIDE ${RESET}"
            echo "$CHECKPOINT_OVERRIDE" | sudo tee "$CHECKPOINT_FILE" >/dev/null
            CURRENT_CHECKPOINT=$CHECKPOINT_OVERRIDE
        fi
        ;;
esac
