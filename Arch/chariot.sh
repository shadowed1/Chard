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

ARCH=$(uname -m)
CHROME_VER=$(cat /.chard_chrome)
FREE_SPACE=$(cat /.chard_free_space)
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
echo "${GREEN}"
detect_gpu_freq() {
    GPU_FREQ_PATH=""
    GPU_MAX_FREQ=""
    GPU_TYPE="unknown"
    
    # Intel Xe
    # This might be culprit
    if [ -f /sys/class/drm/card0/gt_max_freq_mhz ]; then
        GPU_TYPE="intel"
        GPU_FREQ_PATH="/sys/class/drm/card0/gt_max_freq_mhz"
        GPU_MAX_FREQ=$(sudo cat "$GPU_FREQ_PATH" 2>/dev/null)
    
    # AMD
    elif [ -f /sys/class/drm/card0/device/pp_od_clk_voltage ]; then
        GPU_TYPE="amd"
        PP_OD_FILE="/sys/class/drm/card0/device/pp_od_clk_voltage"
    
        mapfile -t SCLK_LINES < <(sudo grep -i '^sclk' "$PP_OD_FILE" 2>/dev/null)
    
        if [[ ${#SCLK_LINES[@]} -gt 0 ]]; then
            GPU_MAX_FREQ=$(printf '%s\n' "${SCLK_LINES[@]}" \
                | sed -n 's/.*\([0-9]\{1,\}\)[Mm][Hh][Zz].*/\1/p' \
                | sort -nr | head -n1)
        fi
    
        GPU_FREQ_PATH="$PP_OD_FILE"
        GPU_MAX_FREQ=${GPU_MAX_FREQ:-0}
    
    # Mali
    else
        for d in /sys/class/devfreq/*; do
            if echo "$d" | grep -qiE 'mali|gpu'; then
                if [ -f "$d/max_freq" ]; then
                    GPU_TYPE="mali"
                    GPU_FREQ_PATH="$d/max_freq"
                    GPU_MAX_FREQ=$(sudo cat "$GPU_FREQ_PATH" 2>/dev/null)
                    break
                elif [ -f "$d/available_frequencies" ]; then
                    GPU_TYPE="mali"
                    GPU_FREQ_PATH="$d/available_frequencies"
                    GPU_MAX_FREQ=$(sudo tr ' ' '\n' < "$GPU_FREQ_PATH" 2>/dev/null | sort -nr | head -n1)
                    break
                fi
            fi
        done
    
        # Adreno
        if [ "$GPU_TYPE" = "unknown" ] && [ -d /sys/class/kgsl/kgsl-3d0 ]; then
            if [ -f /sys/class/kgsl/kgsl-3d0/max_gpuclk ]; then
                GPU_TYPE="adreno"
                GPU_FREQ_PATH="/sys/class/kgsl/kgsl-3d0/max_gpuclk"
                GPU_MAX_FREQ=$(sudo cat "$GPU_FREQ_PATH" 2>/dev/null)
            elif [ -f /sys/class/kgsl/kgsl-3d0/gpuclk ]; then
                GPU_TYPE="adreno"
                GPU_FREQ_PATH="/sys/class/kgsl/kgsl-3d0/gpuclk"
                GPU_MAX_FREQ=$(sudo cat "$GPU_FREQ_PATH" 2>/dev/null)
            fi
        fi
    fi
    echo "${MAGENTA}GPU_TYPE=$GPU_TYPE"
    echo "GPU_FREQ_PATH=$GPU_FREQ_PATH"
    echo "GPU_MAX_FREQ=$GPU_MAX_FREQ ${RESET}"
}

detect_gpu_freq
GPU_VENDOR="$GPU_TYPE"
    
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
echo "${RESET}${YELLOW}Example to resume from a specific checkpoint: ${RESET}${YELLOW}${BOLD}chariot 137${RESET}"
echo "${RESET}${YELLOW}Example to run a checkpoint and stop after: ${RESET}${YELLOW}${BOLD} chariot -s 73${RESET}"
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
        echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}>${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${GREEN}${BOLD}Checkpoint $step / 157 ($desc) Starting ${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${GREEN}"
        echo

        "$@"
        local ret=$?

        if (( ret != 0 )); then
            echo
            echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}>${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${RED}${BOLD}Checkpoint $step / 157 ($desc) DNF ${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${GREEN}${RESET}${GREEN}"
            echo
            return $ret
        fi

        echo "$step" | sudo tee "$CHECKPOINT_FILE" >/dev/null
        sync
        CURRENT_CHECKPOINT=$step
        echo
        echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}>${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${CYAN}${BOLD}Checkpoint $step / 157 ($desc) Finished ${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${GREEN}${RESET}${GREEN}"
        echo

        if $SINGLE_STEP && (( step == REQUESTED_STEP )); then
            echo "${GREEN}Single-step completed: exiting after checkpoint $step${RESET}"
            exit 0
        fi

    else
        echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}>${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${CYAN}${BOLD}Checkpoint $step / 157 ($desc) Completed ${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${GREEN}${RESET}${GREEN}"
        echo
    fi
}

refresh_mirrors() {
    echo "${CYAN}Attempting to refresh mirror list...${RESET}"
    sudo -E pacman -Syy --noconfirm 2>&1 | tee -a "$LOG_FILE"
    
    if command -v reflector &> /dev/null; then
        echo "${CYAN}Running reflector to find fastest mirrors...${RESET}"
        sudo -E reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist 2>&1 | tee -a "$LOG_FILE"
        sudo -E pacman -Syy --noconfirm 2>&1 | tee -a "$LOG_FILE"
    fi
}

cleanup_arch() {
    printf "y\nn\n" | sudo pacman -Scc
    printf "y\nn\ny\nn\n" | yay -Sc
}

retry_pacman() {
    local max_retries=10
    local retry_count=0
    local wait_time=5
    local cmd="$@"
    
    while [ $retry_count -lt $max_retries ]; do
        echo "${CYAN}Attempt $((retry_count + 1)) / $max_retries: ${RESET}"
        
        if eval "$cmd"; then
            echo "${GREEN}Package operation succeeded${RESET}"
            return 0
        else
            retry_count=$((retry_count + 1))
            
            if [ $retry_count -lt $max_retries ]; then
                echo "${YELLOW}Attempt $retry_count failed. Waiting ${wait_time}s before retry...${RESET}"
                sleep $wait_time
                
                wait_time=$((wait_time * 2))
                if [ $wait_time -gt 60 ]; then
                    wait_time=60
                fi
                
                echo "${CYAN}Refreshing package database...${RESET}"
                sudo -E pacman -Syy --noconfirm 2>/dev/null || true
                sudo -E pacman -Fy --noconfirm 2>/dev/null
            else
                echo "${RED}$max_retries attempts failed. Skipping this package.${RESET}"
                return 1
            fi
        fi
    done
    
    return 1
}

checkpoint_1() {
    sudo chown -R 1000:1000 ~/
}
run_checkpoint 1 "sudo chown -R 1000:1000 ~/" checkpoint_1

checkpoint_2() {
    retry_pacman "sudo -E pacman -S --noconfirm cmake"
}
run_checkpoint 2 "sudo -E pacman -S --noconfirm cmake" checkpoint_2

checkpoint_3() {
    retry_pacman "sudo -E pacman -S --noconfirm gmp"
}
run_checkpoint 3 "sudo -E pacman -S --noconfirm gmp" checkpoint_3

checkpoint_4() {
    retry_pacman "sudo -E pacman -S --noconfirm mpfr"
}
run_checkpoint 4 "sudo -E pacman -S --noconfirm mpfr" checkpoint_4

checkpoint_5() {
    retry_pacman "sudo -E pacman -S --noconfirm binutils"
}
run_checkpoint 5 "sudo -E pacman -S --noconfirm binutils" checkpoint_5

checkpoint_6() {
    retry_pacman "sudo -E pacman -S --noconfirm diffutils nano"
}
run_checkpoint 6 "sudo -E pacman -S --noconfirm diffutils and nano" checkpoint_6

checkpoint_7() {
    retry_pacman "sudo -E pacman -S --noconfirm openssl"
}
run_checkpoint 7 "sudo -E pacman -S --noconfirm openssl" checkpoint_7

checkpoint_8() {
    retry_pacman "sudo -E pacman -S --noconfirm curl ca-certificates"
    retry_pacman "sudo -E pacman -S --noconfirm reflector"
    refresh_mirrors
}
run_checkpoint 8 "sudo -E pacman -S --noconfirm curl" checkpoint_8

checkpoint_9() {
    retry_pacman "sudo -E pacman -S --noconfirm git"
    cd ~/
    rm -rf yay 2>/dev/null
    git clone https://aur.archlinux.org/yay.git
    cd yay
    yes | makepkg -si
    cd ~/
    rm -rf yay
}
run_checkpoint 9 "sudo -E pacman -S --noconfirm git + yay" checkpoint_9

checkpoint_10() {
    retry_pacman "sudo -E pacman -S --noconfirm coreutils"
}
run_checkpoint 10 "sudo -E pacman -S --noconfirm coreutils" checkpoint_10

checkpoint_11() {
    retry_pacman "sudo -E pacman -S --noconfirm fastfetch"
}
run_checkpoint 12 "sudo -E pacman -S --noconfirm fastfetch" checkpoint_12

checkpoint_12() {
    retry_pacman "sudo -E pacman -S --noconfirm perl"
}
run_checkpoint 12 "sudo -E pacman -S --noconfirm perl" checkpoint_12

checkpoint_13() {
    retry_pacman "sudo -E pacman -S --noconfirm perl-capture-tiny"
}
run_checkpoint 13 "sudo -E pacman -S --noconfirm perl-capture-tiny" checkpoint_13

checkpoint_14() {
    retry_pacman "sudo -E pacman -S --noconfirm perl-try-tiny"
}
run_checkpoint 14 "sudo -E pacman -S --noconfirm perl-try-tiny" checkpoint_14

checkpoint_15() {
    retry_pacman "sudo -E pacman -S --noconfirm perl-config-autoconf"
}
run_checkpoint 15 "sudo -E pacman -S --noconfirm perl-config-autoconf" checkpoint_15

checkpoint_16() {
    retry_pacman "sudo -E pacman -S --noconfirm perl-test-fatal"
}
run_checkpoint 16 "sudo -E pacman -S --noconfirm perl-test-fatal" checkpoint_16

checkpoint_17() {
    retry_pacman "sudo -E pacman -S --noconfirm findutils"
}
run_checkpoint 17 "sudo -E pacman -S --noconfirm findutils" checkpoint_17

checkpoint_18() {
    retry_pacman "sudo -E pacman -S --noconfirm elfutils"
}
run_checkpoint 18 "sudo -E pacman -S elfutils" checkpoint_18

checkpoint_19() {
     sudo bash -c '
        if [ "$(uname -m)" = "aarch64" ]; then
            export ARCH=arm64
        fi

        cd /usr/src/linux

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
run_checkpoint 19 "build and install kernel + modules" checkpoint_19

checkpoint_20() {
    retry_pacman "sudo -E pacman -S --noconfirm python python3 python-jinja"
}
run_checkpoint 20 "sudo -E pacman -S python" checkpoint_20

checkpoint_21() {
    retry_pacman "sudo -E pacman -S --noconfirm meson"
}
run_checkpoint 21 "sudo -E pacman -S meson" checkpoint_21

checkpoint_22() {
    retry_pacman "sudo -E pacman -S --noconfirm libwebp python-pillow"
}
run_checkpoint 22 "sudo -E pacman -S libwebp python-pillow" checkpoint_22

checkpoint_23() {
    retry_pacman "sudo -E pacman -S --noconfirm harfbuzz"
}
run_checkpoint 23 "sudo -E pacman -S harfbuzz" checkpoint_23

checkpoint_24() {
    retry_pacman "sudo -E pacman -S --noconfirm glib2"
}
run_checkpoint 24 "sudo -E pacman -S glib2" checkpoint_24

checkpoint_25() {
    retry_pacman "sudo -E pacman -S --noconfirm pkgconf"
}
run_checkpoint 25 "sudo -E pacman -S pkgconf" checkpoint_25

checkpoint_26() {
    retry_pacman "yay -S --noconfirm gtest"
}
run_checkpoint 26 "yay -S gtest" checkpoint_26

checkpoint_28() {
    retry_pacman "sudo -E pacman -S --noconfirm re2c"
}
run_checkpoint 28 "sudo -E pacman -S re2c" checkpoint_28

checkpoint_29() {
    retry_pacman "sudo -E pacman -S --noconfirm ninja"
}
run_checkpoint 29 "sudo -E pacman -S ninja" checkpoint_29

checkpoint_30() {
    retry_pacman "sudo -E pacman -S --noconfirm docbook2x"
}
run_checkpoint 30 "sudo -E pacman -S docbook2x" checkpoint_30

checkpoint_31() {
    retry_pacman "sudo -E pacman -S --noconfirm docbook-xml docbook-xsl docbook-utils"
}
run_checkpoint 31 "sudo -E pacman -S build-docbook-catalog" checkpoint_31

checkpoint_32() {
    retry_pacman "sudo -E pacman -S --noconfirm gtk-doc"
}
run_checkpoint 32 "sudo -E pacman -S gtk-doc" checkpoint_32

checkpoint_33() {
    retry_pacman "sudo -E pacman -S --noconfirm zlib"
}
run_checkpoint 33 "sudo -E pacman -S zlib" checkpoint_33

checkpoint_34() {
    retry_pacman "sudo -E pacman -S --noconfirm libunistring"
}
run_checkpoint 34 "sudo -E pacman -S libunistring" checkpoint_34

checkpoint_35() {
    retry_pacman "sudo -E pacman -S --noconfirm file"
}
run_checkpoint 35 "sudo -E pacman -S file" checkpoint_35

checkpoint_36() {
    retry_pacman "sudo -E pacman -S --noconfirm extra-cmake-modules"
}
run_checkpoint 36 "sudo -E pacman -S extra-cmake-modules" checkpoint_36

checkpoint_37() {
    retry_pacman "sudo -E pacman -S --noconfirm perl-file-libmagic"
}
run_checkpoint 37 "sudo -E pacman -S perl-file-libmagic" checkpoint_37

checkpoint_38() {
    retry_pacman "sudo -E pacman -S --noconfirm libpsl"
}
run_checkpoint 38 "sudo -E pacman -S libpsl" checkpoint_38

checkpoint_39() {
    retry_pacman "sudo -E pacman -S --noconfirm expat"
}
run_checkpoint 39 "sudo -E pacman -S expat" checkpoint_39

checkpoint_40() {
    retry_pacman "sudo -E pacman -S --noconfirm duktape"
}
run_checkpoint 40 "sudo -E pacman -S duktape" checkpoint_40

checkpoint_41() {
    retry_pacman "sudo -E pacman -S --noconfirm brotli"
}
run_checkpoint 41 "sudo -E pacman -S brotli" checkpoint_41

checkpoint_42() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}
run_checkpoint 42 "install rustup" checkpoint_42

checkpoint_43() {
    retry_pacman "sudo -E pacman -S --noconfirm gc"
}
run_checkpoint 43 "sudo -E pacman -S boehm-gc" checkpoint_43

checkpoint_44() {
    retry_pacman "sudo -E pacman -S --noconfirm polkit"
}
run_checkpoint 44 "sudo -E pacman -S polkit" checkpoint_44

checkpoint_45() {
    retry_pacman "sudo -E pacman -S --noconfirm bubblewrap"
}
run_checkpoint 45 "sudo -E pacman -S bubblewrap" checkpoint_45

checkpoint_46() {
    retry_pacman "sudo -E pacman -S --noconfirm libclc"
}
run_checkpoint 46 "sudo -E pacman -S libclc" checkpoint_46

checkpoint_47() {
    retry_pacman "sudo -E pacman -S --noconfirm xorg-drivers"
}
run_checkpoint 47 "sudo -E pacman -S xorg-drivers" checkpoint_47

checkpoint_48() {
    retry_pacman "sudo -E pacman -S --noconfirm xorg-server"
}
run_checkpoint 48 "sudo -E pacman -S xorg-server" checkpoint_48

checkpoint_49() {
    retry_pacman "sudo -E pacman -S --noconfirm xorg-apps"
}
run_checkpoint 49 "sudo -E pacman -S xorg-apps" checkpoint_49

checkpoint_50() {
    retry_pacman "sudo -E pacman -S --noconfirm libx11"
}
run_checkpoint 50 "sudo -E pacman -S libx11" checkpoint_50

checkpoint_51() {
    retry_pacman "sudo -E pacman -S --noconfirm libxft"
}
run_checkpoint 51 "sudo -E pacman -S libxft" checkpoint_51

checkpoint_52() {
    retry_pacman "sudo -E pacman -S --noconfirm libxrender"
}
run_checkpoint 52 "sudo -E pacman -S libxrender" checkpoint_52

checkpoint_53() {
    retry_pacman "sudo -E pacman -S --noconfirm libxrandr"
}
run_checkpoint 53 "sudo -E pacman -S libxrandr" checkpoint_53

checkpoint_54() {
    retry_pacman "sudo -E pacman -S --noconfirm libxcursor"
}
run_checkpoint 54 "sudo -E pacman -S libxcursor" checkpoint_54

checkpoint_55() {
    retry_pacman "sudo -E pacman -S --noconfirm libxi"
}
run_checkpoint 55 "sudo -E pacman -S libxi" checkpoint_55

checkpoint_56() {
    retry_pacman "sudo -E pacman -S --noconfirm libxinerama"
}
run_checkpoint 56 "sudo -E pacman -S libxinerama" checkpoint_56

checkpoint_57() {
    retry_pacman "sudo -E pacman -S --noconfirm pango"
}
run_checkpoint 57 "sudo -E pacman -S pango" checkpoint_57

checkpoint_58() {
    retry_pacman "sudo -E pacman -S --noconfirm wayland"
}
run_checkpoint 58 "sudo -E pacman -S wayland" checkpoint_58

checkpoint_63() {
    retry_pacman "sudo -E pacman -S --noconfirm wayland-protocols"
}
run_checkpoint 63 "pacman -S --noconfirm wayland-protocols" checkpoint_63

checkpoint_64() {
    retry_pacman "sudo -E pacman -S --noconfirm xorg-xwayland"
}
run_checkpoint 64 "pacman -S --noconfirm xorg-xwayland" checkpoint_64

checkpoint_65() {
    retry_pacman "sudo -E pacman -S --noconfirm libxkbcommon"
}
run_checkpoint 65 "pacman -S --noconfirm libxkbcommon" checkpoint_65

checkpoint_66() {
    retry_pacman "sudo -E pacman -S --noconfirm gtk4 gtk3"
}
run_checkpoint 66 "pacman -S --noconfirm gtk4 gtk3" checkpoint_66

checkpoint_67() {
    retry_pacman "sudo -E pacman -S --noconfirm libxfce4util"
}
run_checkpoint 67 "pacman -S --noconfirm libxfce4util" checkpoint_67

checkpoint_68() {
    retry_pacman "sudo -E pacman -S --noconfirm xfconf"
}
run_checkpoint 68 "pacman -S --noconfirm xfconf" checkpoint_68

checkpoint_69() {
    retry_pacman "sudo -E pacman -S --noconfirm xdg-desktop-portal"
}
run_checkpoint 69 "pacman -S --noconfirm xdg-desktop-portal" checkpoint_69

checkpoint_70() {
    retry_pacman "sudo -E pacman -S --noconfirm xdg-desktop-portal-wlr"
}
run_checkpoint 70 "pacman -S --noconfirm xdg-desktop-portal-wlr" checkpoint_70

checkpoint_71() {
    retry_pacman "sudo -E pacman -S --noconfirm mesa"
}
run_checkpoint 71 "pacman -S --noconfirm mesa" checkpoint_71

checkpoint_72() {
    retry_pacman "sudo -E pacman -S --noconfirm mesa-demos"
}
run_checkpoint 72 "pacman -S --noconfirm mesa-demos" checkpoint_72

checkpoint_73() {
    retry_pacman "sudo -E pacman -S --noconfirm qt6-tools"
}
run_checkpoint 73 "pacman -S --noconfirm qt6-tools" checkpoint_73

checkpoint_74() {
    retry_pacman "sudo -E pacman -S --noconfirm qt6-base"
}
run_checkpoint 74 "pacman -S --noconfirm qt6-base" checkpoint_74

checkpoint_75() {
    retry_pacman "sudo -E pacman -S --noconfirm qt6-wayland"
}
run_checkpoint 75 "pacman -S --noconfirm qt6-wayland" checkpoint_75

checkpoint_76() {
    retry_pacman "sudo -E pacman -S --noconfirm qt6-5compat"
}
run_checkpoint 76 "pacman -S --noconfirm qt6-5compat" checkpoint_76

checkpoint_77() {
    retry_pacman "sudo -E pacman -S --noconfirm cmake"
}
run_checkpoint 77 "pacman -S --noconfirm cmake" checkpoint_77

checkpoint_79() {
    retry_pacman "sudo -E pacman -S --noconfirm dbus"
}
run_checkpoint 79 "pacman -S --noconfirm dbus" checkpoint_79

checkpoint_80() {
    retry_pacman "sudo -E pacman -S --noconfirm at-spi2-core"
}
run_checkpoint 80 "pacman -S --noconfirm at-spi2-core" checkpoint_80

checkpoint_81() {
    if [[ "$ARCH" == "x86_64" ]]; then
        retry_pacman "sudo -E pacman -S --noconfirm at-spi2-atk"
    else
        echo "Skipping at-spi2-atk upgrade on $ARCH"
    fi
}
run_checkpoint 81 "pacman -S --noconfirm at-spi2-atk" checkpoint_81

checkpoint_82() {
    retry_pacman "sudo -E pacman -S --noconfirm fontconfig"
}
run_checkpoint 82 "pacman -S --noconfirm fontconfig" checkpoint_82

checkpoint_83() {
    retry_pacman "sudo -E pacman -S --noconfirm ttf-dejavu"
}
run_checkpoint 83 "pacman -S --noconfirm ttf-dejavu" checkpoint_83

checkpoint_84() {
    if [[ "$ARCH" == "x86_64" ]]; then
        retry_pacman "yay -S --noconfirm gtk-engines"
    else
        echo "Skipping gtk-engines on $ARCH"
    fi
}
run_checkpoint 84 "yay -S --noconfirm gtk-engines" checkpoint_84

checkpoint_86() {
    retry_pacman "sudo -E pacman -S --noconfirm python python-pip"
}
run_checkpoint 86 "pacman -S --noconfirm python python-pip" checkpoint_86

checkpoint_87() {
    retry_pacman "sudo -E pacman -S --noconfirm libnotify"
}
run_checkpoint 87 "pacman -S --noconfirm libnotify" checkpoint_87

checkpoint_88() {
    retry_pacman "sudo -E pacman -S --noconfirm libdbusmenu-gtk3"
}
run_checkpoint 88 "pacman -S --noconfirm libdbusmenu-gtk3" checkpoint_88

checkpoint_89() {
    retry_pacman "sudo -E pacman -S --noconfirm libsm"
}
run_checkpoint 89 "pacman -S --noconfirm libsm" checkpoint_89

checkpoint_90() {
    retry_pacman "sudo -E pacman -S --noconfirm libice"
}
run_checkpoint 90 "pacman -S --noconfirm libice" checkpoint_90

checkpoint_91() {
    retry_pacman "sudo -E pacman -S --noconfirm libwnck3"
}
run_checkpoint 91 "pacman -S --noconfirm libwnck3" checkpoint_91

checkpoint_92() {
    retry_pacman "sudo -E pacman -S --noconfirm --overwrite '*' cmake"
}
run_checkpoint 92 "pacman -S --noconfirm cmake" checkpoint_92

checkpoint_94() {
    retry_pacman "sudo -E pacman -S --noconfirm exo"
}
run_checkpoint 94 "pacman -S --noconfirm exo" checkpoint_94

checkpoint_95() {
    retry_pacman "sudo -E pacman -S --noconfirm tar"
}
run_checkpoint 95 "pacman -S --noconfirm tar" checkpoint_95

checkpoint_96() {
    retry_pacman "sudo -E pacman -S --noconfirm xz"
}
run_checkpoint 96 "pacman -S --noconfirm xz" checkpoint_96

checkpoint_97() {
    retry_pacman "sudo -E pacman -S --noconfirm gnutls"
}
run_checkpoint 97 "pacman -S --noconfirm gnutls" checkpoint_97

checkpoint_98() {
    retry_pacman "sudo -E pacman -S --noconfirm glib-networking"
}
run_checkpoint 98 "pacman -S --noconfirm glib-networking" checkpoint_98

checkpoint_99() {
    retry_pacman "sudo -E pacman -S --noconfirm libseccomp"
}
run_checkpoint 99 "sudo -E pacman -S --noconfirm libseccomp" checkpoint_99

checkpoint_100() {
    retry_pacman "sudo -E pacman -S --noconfirm appstream-glib"
}
run_checkpoint 100 "sudo -E pacman -S --noconfirm appstream-glib" checkpoint_100

checkpoint_101() {
    retry_pacman "sudo -E pacman -S --noconfirm gpgme"
}
run_checkpoint 101 "sudo -E pacman -S --noconfirm gpgme" checkpoint_101

checkpoint_102() {
    if [[ "$ARCH" == "x86_64" ]]; then
        retry_pacman "sudo -E pacman -S --noconfirm ostree"
    else
        echo "Skipping ostree on $ARCH"
    fi
}
run_checkpoint 102 "sudo -E pacman -S --noconfirm ostree" checkpoint_102

checkpoint_103() {
    retry_pacman "sudo -E pacman -S --noconfirm xdg-dbus-proxy"
}
run_checkpoint 103 "sudo -E pacman -S --noconfirm xdg-dbus-proxy" checkpoint_103

checkpoint_104() {
    retry_pacman "sudo -E pacman -S --noconfirm gdk-pixbuf2"
}
run_checkpoint 104 "sudo -E pacman -S --noconfirm gdk-pixbuf2" checkpoint_104

checkpoint_105() {
    retry_pacman "sudo -E pacman -S --noconfirm fuse3"
}
run_checkpoint 105 "sudo -E pacman -S --noconfirm fuse3" checkpoint_105

checkpoint_106() {
    retry_pacman "sudo -E pacman -S --noconfirm python-gobject"
}
run_checkpoint 106 "sudo -E pacman -S --noconfirm python-gobject" checkpoint_106

checkpoint_107() {
    retry_pacman "sudo -E pacman -S --noconfirm dconf"
}
run_checkpoint 107 "sudo -E pacman -S --noconfirm dconf" checkpoint_107

checkpoint_108() {
    retry_pacman "sudo -E pacman -S --noconfirm xdg-utils"
}
run_checkpoint 108 "sudo -E pacman -S --noconfirm xdg-utils" checkpoint_108

checkpoint_109() {
    retry_pacman "sudo -E pacman -S --noconfirm xorg-xinit"
}
run_checkpoint 109 "sudo -E pacman -S --noconfirm xinit" checkpoint_109

checkpoint_110() {
    retry_pacman "sudo -E pacman -S --noconfirm xterm"
}
run_checkpoint 110 "sudo -E pacman -S --noconfirm xterm" checkpoint_110

checkpoint_111() {
    retry_pacman "sudo -E pacman -S --noconfirm xorg-twm"
}
run_checkpoint 111 "sudo -E pacman -S --noconfirm twm" checkpoint_111

checkpoint_112() {
    retry_pacman "sudo -E pacman -S --noconfirm python-pillow fastfetch"
}
run_checkpoint 112 "sudo -E pacman -S --noconfirm python-pillow fastfetch" checkpoint_112

checkpoint_113() {
    retry_pacman "sudo -E pacman -S --noconfirm chafa"
}
run_checkpoint 113 "sudo -E pacman -S --noconfirm chafa" checkpoint_113

checkpoint_114() {
    retry_pacman "sudo -E pacman -S --noconfirm doxygen"
}
run_checkpoint 114 "sudo -E pacman -S --noconfirm doxygen" checkpoint_114

checkpoint_115() {
    retry_pacman "sudo -E pacman -S --noconfirm libclc egl-gbm"
}
run_checkpoint 115 "sudo -E pacman -S --noconfirm libclc egl-gbm" checkpoint_115

checkpoint_116() {
    cd /tmp
    git clone https://chromium.googlesource.com/chromiumos/platform2
    cd platform2/vm_tools/sommelier
    meson setup build
    ninja -C build
    sudo -E ninja -C build install
    cd /tmp
    sudo rm -rf /tmp/platform2

}
run_checkpoint 116 "Build Sommelier" checkpoint_116

checkpoint_117() {
    retry_pacman "sudo -E pacman -S --noconfirm flatpak"
    #sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo chown -R 1000:1000 ~/.local/share/flatpak
sudo tee /bin/chard_flatpak >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
HOME=/$CHARD_HOME
USER=$CHARD_USER
xhost +SI:localuser:$CHARD_USER
sudo setfacl -Rm u:$USER:rwx /run/chrome 2>/dev/null
sudo setfacl -Rm u:root:rwx /run/chrome 2>/dev/null
source /$CHARD_HOME/.bashrc
DBUS_ADDR="$(grep "export DBUS_SESSION_BUS_ADDRESS=" /.chard_dbus | cut -d"'" -f2)"
DBUS_PID="$(grep "export DBUS_SESSION_BUS_PID=" /.chard_dbus | cut -d"'" -f2)"
WRAPPED_PATH="/usr/local/bubblepatch/bin:$PATH"
LWJGL_TMPDIR="/$CHARD_HOME/.local/tmp"
mkdir -p "$LWJGL_TMPDIR"
chown $CHARD_USER:$CHARD_USER "$LWJGL_TMPDIR"
sudo -u $CHARD_USER \
  env HOME=/$CHARD_HOME \
      PULSE_SERVER=unix:/run/chrome/pulse/native \
      DISPLAY="${DISPLAY:-:0}" \
      WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}" \
      XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/chrome}" \
      DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" \
      DBUS_SESSION_BUS_PID="$DBUS_PID" \
      PATH="$WRAPPED_PATH" \
      LD_LIBRARY_PATH="$LD_LIBRARY_PATH" \
      LIBGL_DRIVERS_PATH="$LIBGL_DRIVERS_PATH" \
      LIBEGL_DRIVERS_PATH="$LIBEGL_DRIVERS_PATH" \
      LIBGL_ALWAYS_INDIRECT=0 \
      GDK_BACKEND="wayland" \
      EGL_PLATFORM=wayland \
      GDK_SCALE="${GDK_SCALE:-1.25}" \
      XDG_DATA_DIRS="$XDG_DATA_DIRS" \
  /usr/bin/flatpak "$@"
sudo setfacl -Rb /run/chrome 2>/dev/null
EOF

sudo chmod +x /bin/chard_flatpak
}
run_checkpoint 117 "sudo -E pacman -S --noconfirm flatpak" checkpoint_117

checkpoint_118() {
    retry_pacman "sudo -E pacman -S --noconfirm thunar"
}
run_checkpoint 118 "sudo -E pacman -S --noconfirm thunar" checkpoint_118

checkpoint_119() {
    retry_pacman "sudo -E pacman -S --noconfirm gvfs"
}
run_checkpoint 119 "sudo -E pacman -S --noconfirm gvfs" checkpoint_119

checkpoint_120() {
    retry_pacman "sudo -E pacman -S --noconfirm xfce4"
}
run_checkpoint 120 "sudo -E pacman -S --noconfirm xfce4" checkpoint_120

checkpoint_121() { 
    retry_pacman "sudo -E pacman -S --noconfirm pulseaudio"
}
run_checkpoint 121 "pulse audio" checkpoint_121

checkpoint_122() {
    retry_pacman "sudo -E pacman -S --noconfirm libva"
}
run_checkpoint 122 "sudo -E pacman -S --noconfirm libva" checkpoint_122

checkpoint_123() {
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
        echo "[*] Installing intel-media-driver for Gen9+ Intel GPU"
        retry_pacman "sudo -E pacman -S --noconfirm libva-intel-driver intel-media-driver intel-media-sdk"
    else
        echo "[*] Skipping Intel driver installation"
    fi
}
run_checkpoint 123 "sudo -E pacman -S --noconfirm intel-media-driver" checkpoint_123

checkpoint_124() {
    retry_pacman "sudo -E pacman -S --noconfirm ffmpeg"
    retry_pacman "sudo -E pacman -S --noconfirm gst-plugins-base"
    retry_pacman "sudo -E pacman -S --noconfirm gst-plugins-good"
    retry_pacman "sudo -E pacman -S --noconfirm gst-plugins-bad"
    retry_pacman "sudo -E pacman -S --noconfirm gst-plugins-ugly"
    if [[ "$ARCH" == "x86_64" ]]; then
        retry_pacman "sudo -E pacman -S --noconfirm lib32-gst-plugins-base"
        retry_pacman "sudo -E pacman -S --noconfirm lib32-gst-plugins-good"
    else
        echo "Skipping lib32-gst on $ARCH"
    fi
    retry_pacman "sudo -E pacman -S --noconfirm libao yt-dlp opus vlc"
}
run_checkpoint 124 "sudo -E pacman -S --noconfirm yt-dlp + vlc" checkpoint_124

checkpoint_125() {
    retry_pacman "sudo -E pacman -S --noconfirm vulkan-tools"
}
run_checkpoint 125 "sudo -E pacman -S --noconfirm vulkan-tools" checkpoint_125

checkpoint_126() {
    retry_pacman "sudo -E pacman -S --noconfirm p7zip arj lha lzop unrar unzip zip xarchiver"
}
run_checkpoint 126 "sudo -E pacman -S --noconfirm xarchiver + archivers" checkpoint_126
#checkpoint_127() {
#    sudo -E pacman -S --noconfirm gimp
#}
#run_checkpoint 127 "sudo -E pacman -S --noconfirm gimp" checkpoint_127

checkpoint_128() {
    cd /usr/share/X11/xkb/symbols
    sudo cp inet ~/.inet.backup
    sudo sed -i -E 's/^\s*key <I(360|362|368|370|373|374|376|377|381|384|385|386|387|388|389|391|392|393|394|395|396|398|417|421|570|598|599)>/\/\/ &/' inet
}
run_checkpoint 128 "Keyboard error spam fix" checkpoint_128

#checkpoint_129() {
#    sudo -E pacman -S --noconfirm libreoffice-fresh
#}
#run_checkpoint 129 "sudo -E pacman -S --noconfirm libreoffice" checkpoint_129

#checkpoint_130() {
#    if [[ "$ARCH" == "x86_64" ]]; then
#        sudo -E pacman -S --noconfirm obs-studio
#        yay -S --noconfirm obs-vkcapture
#    else
#        echo "Skipping OBS on $ARCH"
#    fi
#}
#run_checkpoint 130 "sudo -E pacman -S --noconfirm obs-studio" checkpoint_130

checkpoint_131() {
    retry_pacman "sudo -E pacman -S --noconfirm ruby"
}
run_checkpoint 131 "sudo -E pacman -S --noconfirm ruby" checkpoint_131

checkpoint_132() {
    retry_pacman "sudo -E pacman -S --noconfirm gparted"
    retry_pacman "sudo -E pacman -S --noconfirm exfatprogs"
    retry_pacman "sudo -E pacman -S --noconfirm dosfstools"
    retry_pacman "sudo -E pacman -S --noconfirm ntfs-3g"
    retry_pacman "sudo -E pacman -S --noconfirm mtools"
    retry_pacman "yay -S --noconfirm balena-etcher"
}
run_checkpoint 132 "sudo -E pacman -S --noconfirm gparted and balena etcher" checkpoint_132

checkpoint_134() {
    retry_pacman "sudo -E pacman -S --noconfirm qemu-desktop"
}
run_checkpoint 134 "sudo -E pacman -S --noconfirm qemu" checkpoint_134

checkpoint_135() {
    if [[ "$ARCH" == "x86_64" ]]; then
        retry_pacman "sudo -E pacman -S --noconfirm lib32-libxtst"
        retry_pacman "sudo -E pacman -S --noconfirm lib32-libxrandr"
        retry_pacman "sudo -E pacman -S --noconfirm lib32-libxrender"
        retry_pacman "sudo -E pacman -S --noconfirm lib32-libxi"
        retry_pacman "sudo -E pacman -S --noconfirm lib32-gdk-pixbuf2"
        retry_pacman "sudo -E pacman -S --noconfirm lib32-pulseaudio"
        retry_pacman "yay -S --noconfirm lib32-gtk2"
    else
        echo "Skipping lib32 audio on $ARCH"
    fi
}
run_checkpoint 135 "sudo -E pacman -S --noconfirm lib32gpu" checkpoint_135

checkpoint_136() {
    curl -fsS https://dl.brave.com/install.sh | sh
}
run_checkpoint 136 "curl -fsS https://dl.brave.com/install.sh | sh" checkpoint_136

checkpoint_137() {
    detect_gpu_freq() {
    GPU_FREQ_PATH=""
    GPU_MAX_FREQ=""
    GPU_TYPE="unknown"
    
    # Intel Xe
    # This might be culprit
    if [ -f /sys/class/drm/card0/gt_max_freq_mhz ]; then
        GPU_TYPE="intel"
        GPU_FREQ_PATH="/sys/class/drm/card0/gt_max_freq_mhz"
        GPU_MAX_FREQ=$(sudo cat "$GPU_FREQ_PATH" 2>/dev/null)
    
    # AMD
    elif [ -f /sys/class/drm/card0/device/pp_od_clk_voltage ]; then
        GPU_TYPE="amd"
        PP_OD_FILE="/sys/class/drm/card0/device/pp_od_clk_voltage"
    
        mapfile -t SCLK_LINES < <(sudo grep -i '^sclk' "$PP_OD_FILE" 2>/dev/null)
    
        if [[ ${#SCLK_LINES[@]} -gt 0 ]]; then
            GPU_MAX_FREQ=$(printf '%s\n' "${SCLK_LINES[@]}" \
                | sed -n 's/.*\([0-9]\{1,\}\)[Mm][Hh][Zz].*/\1/p' \
                | sort -nr | head -n1)
        fi
    
        GPU_FREQ_PATH="$PP_OD_FILE"
        GPU_MAX_FREQ=${GPU_MAX_FREQ:-0}
    
    # Mali
    else
        for d in /sys/class/devfreq/*; do
            if echo "$d" | grep -qiE 'mali|gpu'; then
                if [ -f "$d/max_freq" ]; then
                    GPU_TYPE="mali"
                    GPU_FREQ_PATH="$d/max_freq"
                    GPU_MAX_FREQ=$(sudo cat "$GPU_FREQ_PATH" 2>/dev/null)
                    break
                elif [ -f "$d/available_frequencies" ]; then
                    GPU_TYPE="mali"
                    GPU_FREQ_PATH="$d/available_frequencies"
                    GPU_MAX_FREQ=$(sudo tr ' ' '\n' < "$GPU_FREQ_PATH" 2>/dev/null | sort -nr | head -n1)
                    break
                fi
            fi
        done
    
        # Adreno
        if [ "$GPU_TYPE" = "unknown" ] && [ -d /sys/class/kgsl/kgsl-3d0 ]; then
            if [ -f /sys/class/kgsl/kgsl-3d0/max_gpuclk ]; then
                GPU_TYPE="adreno"
                GPU_FREQ_PATH="/sys/class/kgsl/kgsl-3d0/max_gpuclk"
                GPU_MAX_FREQ=$(sudo cat "$GPU_FREQ_PATH" 2>/dev/null)
            elif [ -f /sys/class/kgsl/kgsl-3d0/gpuclk ]; then
                GPU_TYPE="adreno"
                GPU_FREQ_PATH="/sys/class/kgsl/kgsl-3d0/gpuclk"
                GPU_MAX_FREQ=$(sudo cat "$GPU_FREQ_PATH" 2>/dev/null)
            fi
        fi
    fi
    echo "${MAGENTA}GPU_TYPE=$GPU_TYPE"
    echo "GPU_FREQ_PATH=$GPU_FREQ_PATH"
    echo "GPU_MAX_FREQ=$GPU_MAX_FREQ ${RESET}"
}
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        retry_pacman "sudo -E pacman -S --needed --noconfirm lib32-libvdpau 2>/dev/null"
        retry_pacman "yay -S --noconfirm lib32-gtk2 2>/dev/null"
        retry_pacman "sudo -E pacman -S --noconfirm meson ninja pkgconf libcap libcap-ng glib2 git 2>/dev/null"
        retry_pacman "sudo -E pacman -S --noconfirm bubblewrap 2>/dev/null"
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
        sudo -E pacman -Rns --noconfirm steam 2>/dev/null 
        sudo -E pacman -Rns --noconfirm lib32-vulkan-intel 2>/dev/null 
        sudo -E pacman -Rns --noconfirm vulkan-intel 2>/dev/null 
        sudo -E pacman -Rns --noconfirm lib32-vulkan-nouveau 2>/dev/null 
        sudo -E pacman -Rns --noconfirm vulkan-nouveau 2>/dev/null 
        sudo -E pacman -Rns --noconfirm lib32-vulkan-radeon 2>/dev/null 
        sudo -E pacman -Rns --noconfirm vulkan-radeon 2>/dev/null 
        sudo -E pacman -Rns --noconfirm lib32-vulkan-swrast 2>/dev/null 
        sudo -E pacman -Rns --noconfirm vulkan-swrast 2>/dev/null 
        sudo -E pacman -Rns --noconfirm lib32-vulkan-asahi 2>/dev/null 
        sudo -E pacman -Rns --noconfirm vulkan-asahi 2>/dev/null 
        sudo -E pacman -Rns --noconfirm lib32-vulkan-dzn 2>/dev/null 
        sudo -E pacman -Rns --noconfirm vulkan-dzn 2>/dev/null 
        sudo -E pacman -Rns --noconfirm lib32-vulkan-gfxstream 2>/dev/null 
        sudo -E pacman -Rns --noconfirm vulkan-gfxstream 2>/dev/null 
        sudo -E pacman -Rns --noconfirm lib32-nvidia-utils 2>/dev/null 
        sudo -E pacman -Rns --noconfirm nvidia-utils 2>/dev/null 
        sudo rm /usr/share/vulkan/implicit_layer.d/nvidia_layers.json 2>/dev/null 
        sudo rm /usr/share/vulkan/implicit_layer.d/VkLayer_MESA_device_select.json 2>/dev/null 
        sudo rm /usr/lib/libvulkan_intel.so 2>/dev/null 
        sudo rm /usr/share/vulkan/icd.d/intel_hasvk_icd.x86_64.json 2>/dev/null 
        sudo rm /usr/share/vulkan/icd.d/intel_icd.x86_64.json 2>/dev/null 
        sudo rm /usr/share/vulkan/icd.d/intel_hasvk_icd.i686.json 2>/dev/null 
        sudo rm /usr/share/vulkan/icd.d/intel_icd.i686.json 2>/dev/null 
        sudo rm /usr/share/vulkan/icd.d/intel_hasvk_icd.i686.json 2>/dev/null 
        detect_gpu_freq
        GPU_VENDOR="$GPU_TYPE"
            detect_gpu_freq
            GPU_VENDOR="$GPU_TYPE"
            echo "[*] GPU vendor detected: $GPU_VENDOR"
            case "$GPU_VENDOR" in
                intel)
                    DRIVER="6"
                    ;;
                amd)
                    DRIVER="8"
                    ;;
                nvidia)
                    DRIVER="1"
                    ;;
                mali|panfrost)
                    DRIVER="4"
                    ;;
                adreno)
                    DRIVER="4"
                    ;;
                asahi)
                    DRIVER="2"
                    ;;
                mediatek|vivante)
                    DRIVER="4"
                    ;;
                *)
                    DRIVER="9"
                    ;;
            esac
    
        echo "[*] Selecting provider number: $DRIVER"
        printf "%s\n%s\ny\n" "$DRIVER" "$DRIVER" | sudo -E pacman -S steam

        STEAM_SCRIPT="/usr/lib/steam/steam"
        sudo sed -i.bak -E '/if \[ "\$\(id -u\)" == "0" \]; then/,/fi/ s/^/#/' "$STEAM_SCRIPT"

        sudo tee /bin/chard_steam >/dev/null <<'EOF'
#!/bin/bash
export PATH=/usr/local/bubblepatch/bin:$PATH
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export QT_QPA_PLATFORM=xcb
STEAM_USER_HOME=$CHARD_HOME/.local/share/Steam
xhost +SI:localuser:$USER
sudo setfacl -Rm u:$USER:rwx /run/chrome 2>/dev/null
sudo setfacl -Rm u:root:rwx /run/chrome 2>/dev/null
/usr/bin/steam
sudo setfacl -Rb /run/chrome 2>/dev/null
EOF
        sudo chmod +x /bin/chard_steam
      
mkdir -p ~/.local/share/applications
tee ~/.local/share/applications/steam-chard.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Steam (Chard)
Comment=Wrapper to allow Steam to run on ChromeOS
Exec=chard_steam
Icon=steam
Type=Application
Categories=Game;
Terminal=false
StartupNotify=true
EOF

elif [[ "$ARCH" == "aarch64" ]]; then
    sudo -E pacman -S --needed --noconfirm meson ninja pkgconf libcap libcap-ng glib2 git bubblewrap
    cd ~/
    rm -rf bubblewrap
    git clone https://github.com/shadowed1/bubblewrap.git
    cd bubblewrap
    mkdir -p /usr/local/bubblepatch
    meson setup -Dprefix=/usr/local/bubblepatch build
    ninja -C build
    sudo ninja -C build install
    cd ~/
    rm -rf bubblewrap
else
    echo "Unsupported architecture: $ARCH"
fi
}
run_checkpoint 137 "Steam" checkpoint_137

checkpoint_138() {
    sudo mv /usr/share/libalpm/hooks/90-packagekit-refresh.hook /usr/share/libalpm/hooks/90-packagekit-refresh.hook.disabled 2>/dev/null
    detect_gpu_freq() {
    GPU_FREQ_PATH=""
    GPU_MAX_FREQ=""
    GPU_TYPE="unknown"

    if [ -f "/sys/class/drm/card0/gt_max_freq_mhz" ]; then
        GPU_FREQ_PATH="/sys/class/drm/card0/gt_max_freq_mhz"
        GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
        GPU_TYPE="intel"
        echo "[*] Detected Intel GPU: max freq ${GPU_MAX_FREQ} MHz"
        return
    fi

    if [ -f "/sys/class/drm/card0/device/pp_dpm_sclk" ]; then
        GPU_TYPE="nvidia"
        PP_DPM_SCLK="/sys/class/drm/card0/device/pp_dpm_sclk"
        MAX_MHZ=$(grep -o '[0-9]\+' "$PP_DPM_SCLK" | sort -nr | head -n1)
        GPU_MAX_FREQ="$MAX_MHZ"
        GPU_FREQ_PATH="$PP_DPM_SCLK"
        echo "[*] Detected NVIDIA GPU: max freq ${GPU_MAX_FREQ} MHz"
        return
    fi

    if [ -f "/sys/class/drm/card0/device/pp_od_clk_voltage" ]; then
        GPU_TYPE="amd"
        PP_OD_FILE="/sys/class/drm/card0/device/pp_od_clk_voltage"
        mapfile -t SCLK_LINES < <(grep -i '^sclk' "$PP_OD_FILE")
        if [[ ${#SCLK_LINES[@]} -gt 0 ]]; then
            MAX_MHZ=$(printf '%s\n' "${SCLK_LINES[@]}" | sed -n 's/.*\([0-9]\{1,\}\)[Mm][Hh][Zz].*/\1/p' | sort -nr | head -n1)
            GPU_MAX_FREQ="$MAX_MHZ"
        fi
        GPU_FREQ_PATH="$PP_OD_FILE"
        echo "[*] Detected AMD GPU: max freq ${GPU_MAX_FREQ} MHz"
        return
    fi

    if [[ -d /sys/class/drm ]]; then
        if grep -qi "mediatek" /sys/class/drm/*/device/uevent 2>/dev/null; then
            GPU_TYPE="mediatek"
            echo "[*] Detected MediaTek GPU"
            return
        elif grep -qi "vivante" /sys/class/drm/*/device/uevent 2>/dev/null; then
            GPU_TYPE="vivante"
            echo "[*] Detected Vivante GPU"
            return
        elif grep -qi "asahi" /sys/class/drm/*/device/uevent 2>/dev/null; then
            GPU_TYPE="asahi"
            echo "[*] Detected Asahi GPU"
            return
        elif grep -qi "panfrost" /sys/class/drm/*/device/uevent 2>/dev/null; then
            GPU_TYPE="mali"
            echo "[*] Detected Mali/Panfrost GPU"
            return
        fi
    fi

    for d in /sys/class/devfreq/*; do
        if grep -qi 'mali' <<< "$d" || grep -qi 'gpu' <<< "$d"; then
            if [ -f "$d/max_freq" ]; then
                GPU_FREQ_PATH="$d/max_freq"
                GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
                GPU_TYPE="mali"
                echo "[*] Detected Mali GPU via devfreq: max freq ${GPU_MAX_FREQ} Hz"
                return
            elif [ -f "$d/available_frequencies" ]; then
                GPU_FREQ_PATH="$d/available_frequencies"
                GPU_MAX_FREQ=$(tr ' ' '\n' < "$GPU_FREQ_PATH" | sort -nr | head -n1)
                GPU_TYPE="mali"
                echo "[*] Detected Mali GPU via devfreq: max freq ${GPU_MAX_FREQ} Hz"
                return
            fi
        fi
    done

    if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
        if [ -f "/sys/class/kgsl/kgsl-3d0/max_gpuclk" ]; then
            GPU_FREQ_PATH="/sys/class/kgsl/kgsl-3d0/max_gpuclk"
            GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
            GPU_TYPE="adreno"
            echo "[*] Detected Adreno GPU: max freq ${GPU_MAX_FREQ} Hz"
            return
        elif [ -f "/sys/class/kgsl/kgsl-3d0/gpuclk" ]; then
            GPU_FREQ_PATH="/sys/class/kgsl/kgsl-3d0/gpuclk"
            GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
            GPU_TYPE="adreno"
            echo "[*] Detected Adreno GPU: max freq ${GPU_MAX_FREQ} Hz"
            return
        fi
    fi

    GPU_TYPE="unknown"
}

detect_gpu_freq
GPU_VENDOR="$GPU_TYPE"
   echo "[*] Installing Vulkan driver packages for GPU type: $GPU_TYPE"
    case "$GPU_TYPE" in
        intel)
            echo "[+] Installing Intel Vulkan drivers..."
            retry_pacman "sudo -E pacman -S --noconfirm mesa lib32-mesa vulkan-intel lib32-vulkan-intel mesa-utils 2>/dev/null"
            retry_pacman "sudo -E pacman -R --noconfirm lib32-vulkan-mesa-implicit-layers"
            retry_pacman "sudo -E pacman -R --noconfirm vulkan-mesa-implicit-layers" 
            retry_pacman "sudo -E pacman -R --noconfirm vulkan-mesa-layers"
            retry_pacman "sudo -E pacman -R --noconfirm lib32-vulkan-intel"
            retry_pacman "sudo -E pacman -R --noconfirm vulkan-intel"
            retry_pacman "sudo -E pacman -S --noconfirm vulkan-mesa-device-select"    
            rm -rf ~/intel_vulkan 2>/dev/null
            rm -rf ~/intel_vulkan_271.zip 2>/dev/null
            curl -L -o ~/intel_vulkan_271.zip https://raw.githubusercontent.com/shadowed1/Chard/main/Arch/intel_vulkan_271.zip
            mkdir -p ~/intel_vulkan 2>/dev/null
            unzip ~/intel_vulkan_271.zip -d ~/intel_vulkan
            sudo cp -r ~/intel_vulkan/vulkantest/vulkan /usr/share/ 
            sudo cp ~/intel_vulkan/vulkantest/libvulkan_intel.so /usr/lib/
            rm -rf ~/intel_vulkan ~/intel_vulkan_271.zip 2>/dev/null
            ;;
        amd)
            echo "[+] Installing AMD Vulkan drivers..."
            retry_pacman "sudo -E pacman -S --noconfirm mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon mesa-utils 2>/dev/null"
            ;;

        nvidia)
            echo "[+] Installing NVIDIA Vulkan drivers..."
            KVER=$(uname -r)
            if [[ "$KVER" == *"lts"* ]]; then
                DRIVER="nvidia-lts"
            else
                DRIVER="nvidia"
            fi
            retry_pacman "sudo -E pacman -S --noconfirm $DRIVER nvidia-utils lib32-nvidia-utils vulkan-icd-loader lib32-vulkan-icd-loader mesa-utils lib32-vulkan-driver 2>/dev/null"
            ;;

        mali|panfrost|mediatek|vivante|asahi)
            echo "[+] Installing Mesa ARM Vulkan drivers..."
            retry_pacman "sudo -E pacman -S --noconfirm mesa mesa-utils 2>/dev/null"
            ;;

        adreno)
            echo "[+] Installing Adreno Vulkan drivers..."
            retry_pacman "sudo -E pacman -S --noconfirm mesa mesa-utils  2>/dev/null"
            ;;

        *)
            echo "[!] Unknown GPU type. Installing generic Vulkan support..."
            retry_pacman "sudo -E pacman -S --noconfirm mesa vulkan-icd-loaderc mesa-utils 2>/dev/null"
            ;;
    esac
}
run_checkpoint 138 "vulkan" checkpoint_138

checkpoint_139() {
    sudo rm /etc/pipewire/pipewire.conf.d/crostini-audio.conf 2>/dev/null
    sudo -E pacman -R --noconfirm cros-container-guest-tools-git 2>/dev/null
    sudo -E pacman -S --noconfirm pulseaudio 2>/dev/null
    rm -rf ~/.config/pulse 2>/dev/null
    rm -rf ~/.pulse 2>/dev/null
    rm -rf ~/.cache/pulse 2>/dev/null
    sudo -E pacman -S --noconfirm pipewire-libcamera 2>/dev/null
    sudo -E pacman -S --noconfirm alsa-lib alsa-utils alsa-plugins 2>/dev/null
    sudo rm -rf ~/.cache/bazel 2>/dev/null
    cd ~/
    git clone --depth 1 https://github.com/shadowed1/alsa-ucm-conf-cros
    cd alsa-ucm-conf-cros
    sudo mkdir -p /usr/share/alsa
    sudo cp -r ucm2 /usr/share/alsa
    sudo cp -r overrides /usr/share/alsa/ucm2/conf.d
    cd ~/
    rm -rf alsa-ucm-conf-cros
    sleep 1
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        sudo rm /etc/pipewire/pipewire.conf.d/crostini-audio.conf 2>/dev/null
        sudo -E pacman -R --noconfirm cros-container-guest-tools-git 2>/dev/null
        sudo -E pacman -R --noconfirm pipewire-pulse 2>/dev/null
        rm -rf ~/.config/pulse 2>/dev/null
        rm -rf ~/.pulse 2>/dev/null
        rm -rf ~/.cache/pulse 2>/dev/null
        retry_pacman "sudo -E pacman -S --noconfirm pulseaudio 2>/dev/null"
        retry_pacman "sudo -E pacman -S --noconfirm pipewire-libcamera 2>/dev/null"
        retry_pacman "sudo -E pacman -S --noconfirm alsa-lib alsa-utils alsa-plugins 2>/dev/null"
        sudo rm -rf ~/.cache/bazel 2>/dev/null
        rm -rf ~/adhd 2>/dev/null
        BAZEL_URL="https://github.com/bazelbuild/bazel/releases/download/6.5.0/bazel-6.5.0-linux-x86_64"
        echo "Downloading Bazel from: $BAZEL_URL"
        sudo curl -L "$BAZEL_URL" -o /usr/bin/bazel65
        sudo chmod +x /usr/bin/bazel65
        cd ~/
        git clone https://chromium.googlesource.com/chromiumos/third_party/adhd
        cd adhd/
        sudo -E /usr/bin/bazel65 build //dist:alsa_lib
        sleep 1
        sudo mkdir -p /usr/lib64/alsa-lib/
        sudo mkdir -p /usr/lib/alsa-lib/
        sudo cp ~/adhd/bazel-bin/cras/src/alsa_plugin/libasound_module_ctl_cras.so /usr/lib64/alsa-lib/
        sudo cp ~/adhd/bazel-bin/cras/src/alsa_plugin/libasound_module_pcm_cras.so /usr/lib64/alsa-lib/
        sudo cp ~/adhd/bazel-bin/cras/src/alsa_plugin/libasound_module_ctl_cras.so /usr/lib/alsa-lib/
        sudo cp ~/adhd/bazel-bin/cras/src/alsa_plugin/libasound_module_pcm_cras.so /usr/lib/alsa-lib/
        sudo cp ~/adhd/bazel-bin/cras/src/libcras/libcras.so /usr/lib/
        sudo cp ~/adhd/bazel-bin/cras/src/libcras/libcras.so /usr/lib64/
        sudo mkdir -p /etc/pipewire/pipewire.conf.d
        cd ~/
        rm -rf ~/adhd 2>/dev/null
    elif [[ "$ARCH" == "aarch64" ]]; then
        sudo -E pacman -R --noconfirm pipewire-pulse 2>/dev/null
        sudo -E pacman -S --noconfirm pulseaudio 2>/dev/null
        sudo -E pacman -S --noconfirm alsa-lib alsa-utils alsa-plugins 2>/dev/null
        sudo rm -rf ~/.cache/bazel 2>/dev/null
        rm -rf ~/adhd 2>/dev/null
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
        sudo mkdir -p /usr/lib/alsa-lib/
        sudo cp ~/adhd/bazel-bin/cras/src/alsa_plugin/libasound_module_ctl_cras.so /usr/lib64/alsa-lib/
        sudo cp ~/adhd/bazel-bin/cras/src/alsa_plugin/libasound_module_pcm_cras.so /usr/lib64/alsa-lib/
        sudo cp ~/adhd/bazel-bin/cras/src/alsa_plugin/libasound_module_ctl_cras.so /usr/lib/alsa-lib/
        sudo cp ~/adhd/bazel-bin/cras/src/alsa_plugin/libasound_module_pcm_cras.so /usr/lib/alsa-lib/
        sudo cp ~/adhd/bazel-bin/cras/src/libcras/libcras.so /usr/lib/
        sudo cp ~/adhd/bazel-bin/cras/src/libcras/libcras.so /usr/lib64/
        retry_pacman "yay -S --noconfirm cros-container-guest-tools-git 2>/dev/null"
        sudo mkdir -p /etc/pipewire/pipewire.conf.d
        cd ~/
        rm -rf ~/adhd
    else
        echo "Unsupported architecture: $ARCH"
    fi   
}
run_checkpoint 139 "Pipewire + Alsa UCM" checkpoint_139

checkpoint_140() {
    sudo mv /usr/share/libalpm/hooks/90-packagekit-refresh.hook /usr/share/libalpm/hooks/90-packagekit-refresh.hook.disabled 2>/dev/null
    for f in /etc/machine-id /var/lib/dbus/machine-id; do
        if [ -f "$f" ]; then
            sudo rm "$f" 2>/dev/null
        fi
    done
    sudo dbus-uuidgen --ensure=/etc/machine-id 2>/dev/null
    sudo dbus-uuidgen --ensure=/var/lib/dbus/machine-id 2>/dev/null
    file=/usr/share/libalpm/hooks/90-packagekit-refresh.hook
    if [ -e "$file" ]; then
        sudo mv "$file" "$file.disabled" 2>/dev/null
    fi
    retry_pacman "sudo pacman -Rdd --noconfirm xfce4-notifyd xfce4-power-manager"
    PANEL_CFG="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
    if [[ -f "$PANEL_CFG" ]]; then
        sed -i 's/<property name="position-locked" type="bool" value="true"\/>/<property name="position-locked" type="bool" value="false"\/>/' "$PANEL_CFG"
    fi  
}
run_checkpoint 140 "Fix machine-id" checkpoint_140

checkpoint_141() {
retry_pacman "yay -S --noconfirm prismlauncher"
retry_pacman "sudo -E pacman -S --noconfirm gamemode"
retry_pacman "sudo -E pacman -S --noconfirm flite"
sudo tee /bin/chard_prismlauncher >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
HOME=/$CHARD_HOME
USER=$CHARD_USER
source ~/.bashrc
export QT_QPA_PLATFORM=xcb
export ALSOFT_DRIVERS=alsa
/usr/bin/prismlauncher "$@" &
EOF
sudo chmod +x /bin/chard_prismlauncher
    
}
run_checkpoint 141 "Prism Launcher" checkpoint_141

checkpoint_142() {
retry_pacman "sudo -E pacman -S --noconfirm firefox"

sudo tee "/bin/chard_firefox" >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export PATH=/usr/local/bubblepatch/bin:$PATH
xhost +SI:localuser:root >/dev/null 2>&1
exec sudo -u "$CHARD_USER" /bin/bash -c '
  export PULSE_SERVER=unix:/run/chrome/pulse/native
  export MOZ_CUBEB_FORCE_PULSE=1
  export MOZ_ENABLE_WAYLAND=1
  export MOZ_GTK_TITLEBAR_DECORATION=client
  exec /usr/bin/firefox "$@"
' bash "$@"
EOF

sudo chmod +x "/bin/chard_firefox"

sudo tee "/bin/chard_tor" >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export PATH=/usr/local/bubblepatch/bin:$PATH
xhost +SI:localuser:root >/dev/null 2>&1
exec sudo -u "$CHARD_USER" /bin/bash -c '
  export PULSE_SERVER=unix:/run/chrome/pulse/native
  export MOZ_CUBEB_FORCE_PULSE=1
  export MOZ_ENABLE_WAYLAND=1
  export MOZ_GTK_TITLEBAR_DECORATION=client
  exec /usr/bin/torbrowser-launcher "$@"
' bash "$@"
EOF

sudo chmod +x "/bin/chard_tor"

sudo tee "/bin/chard_thunderbird" >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export PATH=/usr/local/bubblepatch/bin:$PATH
xhost +SI:localuser:root >/dev/null 2>&1
exec sudo -u "$CHARD_USER" /bin/bash -c '
  export PULSE_SERVER=unix:/run/chrome/pulse/native
  export MOZ_CUBEB_FORCE_PULSE=1
  export MOZ_ENABLE_WAYLAND=1
  export MOZ_GTK_TITLEBAR_DECORATION=client
  exec /usr/bin/thunderbird "$@"
' bash "$@"
EOF

sudo chmod +x "/bin/chard_thunderbird"

mkdir -p ~/.local/share/applications

tee ~/.local/share/applications/firefox-chard.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Firefox (Chard)
Comment=Wrapper to run Firefox on ChromeOS
Exec=chard_firefox %u
Icon=firefox
Type=Application
Categories=Network;WebBrowser;
Terminal=false
StartupNotify=true
EOF
}
run_checkpoint 142 "Firefox" checkpoint_142

checkpoint_143() {
cd ~/
XA="$HOME/.Xauthority"
if [[ -f "$XA" ]]; then
    rm "$XA"
fi
touch ~/.Xauthority 2>/dev/null
retry_pacman "sudo -E pacman -S --noconfirm gedit 2>/dev/null"
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
run_checkpoint 143 "X Authority & gedit" checkpoint_143

#checkpoint_144() {
#ARCH="$(uname -m)"
#if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
#    echo "Skipping pamac install on ARM ($ARCH)"
#else
#    sudo -E pacman -R --noconfirm pamac-full 2>/dev/null
#    yay -S --noconfirm pamac 2>/dev/null
#fi
#}
#run_checkpoint 144 "pamac" checkpoint_144

checkpoint_145() {
ARCH="$(uname -m)"
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    echo "Skipping Heroic install on ARM ($ARCH)"
else
    retry_pacman "yay -S --noconfirm heroic-games-launcher-bin 2>/dev/null"
    sudo chown root:root /opt/Heroic/chrome-sandbox
    sudo chmod 4755 /opt/Heroic/chrome-sandbox
fi
}
run_checkpoint 145 "Heroic" checkpoint_145

checkpoint_146() {
    retry_pacman "yay -S --noconfirm kvantum 2>/dev/null"
    #sudo -E pacman -S --noconfirm dolphin 2>/dev/null
}
run_checkpoint 146 "kvantum" checkpoint_146

checkpoint_147() {
   retry_pacman "sudo -E pacman -S --noconfirm pavucontrol 2>/dev/null"
   gpg --batch --pinentry-mode loopback --passphrase '' --quick-gen-key "dummy-kde-wallet" default default never
}
run_checkpoint 147 "pavucontrol" checkpoint_147

checkpoint_148() {
   retry_pacman "sudo -E pacman -S --noconfirm strace 2>/dev/null"
}
run_checkpoint 148 "pavucontrol" checkpoint_148

#checkpoint_149() {
#yay -S --noconfirm vscodium-bin
#}
#run_checkpoint 149 "VSCodium" checkpoint_149

#checkpoint_150() {
#   yay -S --noconfirm libreoffice 2>/dev/null
#}
#run_checkpoint 150 "LibreOffice" checkpoint_150

#checkpoint_151() {
#    ARCH=$(uname -m)
#        if [[ "$ARCH" == "x86_64" ]]; then
#            yay -S --noconfirm winegui
#        elif [[ "$ARCH" == "aarch64" ]]; then
#            echo "Unsupported architecture: $ARCH"
#        else
#            echo "Unsupported architecture: $ARCH"
#        fi   
#}
#run_checkpoint 151 "winegui" checkpoint_151

# Day's Garcon
checkpoint_152() {
    retry_pacman "yay -S --noconfirm inotify-tools"
}
run_checkpoint 152 "inotify-tools" checkpoint_152

checkpoint_153() {
    retry_pacman "sudo -E pacman -S --noconfirm gwenview"
}
run_checkpoint 153 "gwenview" checkpoint_153

checkpoint_154() {
    retry_pacman "sudo -E pacman -S --noconfirm handbrake"
}
run_checkpoint 154 "handbrake" checkpoint_154

checkpoint_155() {
    retry_pacman "sudo pacman -S  --noconfirm --overwrite "/usr/include/*" linux-api-headers"
}
run_checkpoint 155 "linux-api-header fix" checkpoint_155

#checkpoint_156() {
#    printf "y\nn\n" | sudo pacman -Scc
#    printf "y\nn\ny\nn\n" | yay -Sc
#}
run_checkpoint 156 "Clear Cache" checkpoint_156

checkpoint_157() {
    sudo -E gcc /tmp/virtm.c -o /bin/virtm -lm 2>/dev/null
    sudo -E gcc /tmp/autoclicker.c -o /bin/autoclicker 2>/dev/null
    sudo chmod +x /bin/autoclicker
    sudo chmod +x /bin/virtm 2>/dev/null
    sudo rm /tmp/virtm.c 2>/dev/null
    sudo rm /tmp/autoclicker.c 2>/dev/null
}
run_checkpoint 157 "VIRTM - Virtual Touch Mouse and Autoclicker" checkpoint_157

checkpoint_158() {
    retry_pacman "sudo -E pacman -S --noconfirm noto-fonts-emoji"
    fc-cache -f 2>/dev/null
}
run_checkpoint 158 "Emoji Support" checkpoint_157

cleanup_arch

sudo chown -R 1000:1000 ~/
sudo setfacl -Rb /run/chrome 2>/dev/null
echo "Chard Root is Ready! Open a new shell and run: chard root${RESET}"
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
