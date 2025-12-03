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
                                                                                              

CHECKPOINT_FILE="/.chard_checkpoint"
echo
echo "${CYAN}${BOLD}Chariot is an install assistant for Chard which implements a checkpoint system to resume if interrupted! Run:${RESET}${BLUE}${BOLD}"
echo
echo "chariot${RESET}${YELLOW} inside chard root to resume at anytime. Run:"
echo
echo "${RESET}${BLUE}${BOLD}chariot reset${RESET}${RED} to reset build progress.${RESET}${GREEN}"
echo
sleep 5

if [[ -f "$CHECKPOINT_FILE" ]]; then
    CURRENT_CHECKPOINT=$(cat "$CHECKPOINT_FILE")
else
    echo "0" | sudo tee "$CHECKPOINT_FILE" >/dev/null
    CURRENT_CHECKPOINT=0
fi

trap 'echo; echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${RED}Exiting${RESET}"; exit 1' SIGINT

run_checkpoint() {
    local step=$1
    local desc=$2
    shift 2

    if (( CURRENT_CHECKPOINT < step )); then
        echo
        echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}>${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${GREEN}${BOLD}Checkpoint $step / 144 ($desc) Starting ${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${GREEN}"
        echo

        "$@"
        local ret=$?

        if (( ret != 0 )); then
            echo
            echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}>${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${RED}${BOLD}Checkpoint $step / 144 ($desc) DNF ${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${GREEN}${RESET}${GREEN}"
            echo
            exit $ret
        fi

        echo "$step" | sudo tee "$CHECKPOINT_FILE" >/dev/null
        sync
        CURRENT_CHECKPOINT=$step
        echo
        echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}>${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${CYAN}${BOLD}Checkpoint $step / 144 ($desc) Finished ${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${GREEN}${RESET}${GREEN}"
        echo
    else
        echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}>${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${CYAN}${BOLD}Checkpoint $step / 144 ($desc) Completed ${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${GREEN}${RESET}${GREEN}"
        echo
    fi
}

checkpoint_1() {
    sudo chown -R 1000:1000 ~/
}
run_checkpoint 1 "sudo chown -R 1000:1000 ~/" checkpoint_1

checkpoint_2() {
    sudo -E pacman -Syu --noconfirm cmake
}
run_checkpoint 2 "sudo -E pacman -Syu --noconfirm cmake" checkpoint_2

checkpoint_3() {
    sudo -E pacman -Syu --noconfirm gmp
}
run_checkpoint 3 "sudo -E pacman -Syu --noconfirm gmp" checkpoint_3

checkpoint_4() {
    sudo -E pacman -Syu --noconfirm mpfr
}
run_checkpoint 4 "sudo -E pacman -Syu --noconfirm mpfr" checkpoint_4

checkpoint_5() {
    sudo -E pacman -Syu --noconfirm binutils
}
run_checkpoint 5 "sudo -E pacman -Syu --noconfirm binutils" checkpoint_5

checkpoint_6() {
    sudo -E pacman -Syu --noconfirm diffutils
    sudo -E pacman -Syu --noconfirm nano
}
run_checkpoint 6 "sudo -E pacman -Syu --noconfirm diffutils and nano" checkpoint_6

checkpoint_7() {
    sudo -E pacman -Syu --noconfirm openssl
}
run_checkpoint 7 "sudo -E pacman -Syu --noconfirm openssl" checkpoint_7

checkpoint_8() {
    sudo -E pacman -Syu --noconfirm curl ca-certificates

}
run_checkpoint 8 "sudo -E pacman -Syu --noconfirm curl" checkpoint_8

checkpoint_9() {
    sudo -E pacman -Syu --noconfirm git
    cd ~/
    git clone https://aur.archlinux.org/yay.git
    cd yay
    yes | makepkg -si
}
run_checkpoint 9 "sudo -E pacman -Syu --noconfirm git + yay" checkpoint_9

checkpoint_10() {
    sudo -E pacman -Syu --noconfirm coreutils
}
run_checkpoint 10 "sudo -E pacman -Syu --noconfirm coreutils" checkpoint_10

checkpoint_11() {
    sudo -E pacman -Syu --noconfirm fastfetch
}
run_checkpoint 11 "sudo -E pacman -Syu --noconfirm fastfetch" checkpoint_11

checkpoint_12() {
    sudo -E pacman -Syu --noconfirm perl
}
run_checkpoint 12 "sudo -E pacman -Syu --noconfirm perl" checkpoint_12

checkpoint_13() {
    sudo -E pacman -Syu --noconfirm perl-capture-tiny
}
run_checkpoint 13 "sudo -E pacman -Syu --noconfirm perl-capture-tiny" checkpoint_13

checkpoint_14() {
    sudo -E pacman -Syu --noconfirm perl-try-tiny
}
run_checkpoint 14 "sudo -E pacman -Syu --noconfirm perl-try-tiny" checkpoint_14

checkpoint_15() {
    sudo -E pacman -Syu --noconfirm perl-config-autoconf
}
run_checkpoint 15 "sudo -E pacman -Syu --noconfirm perl-config-autoconf" checkpoint_15

checkpoint_16() {
    sudo -E pacman -Syu --noconfirm perl-test-fatal
}
run_checkpoint 16 "sudo -E pacman -Syu --noconfirm perl-test-fatal" checkpoint_16

checkpoint_17() {
    sudo -E pacman -Syu --noconfirm findutils
}
run_checkpoint 17 "sudo -E pacman -Syu --noconfirm findutils" checkpoint_17

checkpoint_18() {
    sudo -E pacman -Syu --noconfirm elfutils
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
    sudo -E pacman -Syu --noconfirm python python3 python-jinja
}
run_checkpoint 20 "sudo -E pacman -S python" checkpoint_20


checkpoint_21() {
    sudo -E pacman -Syu --noconfirm meson
}
run_checkpoint 21 "sudo -E pacman -S meson" checkpoint_21

checkpoint_22() {
    sudo -E pacman -Syu --noconfirm libwebp
    sudo -E pacman -Syu --noconfirm python-pillow
}
run_checkpoint 22 "sudo -E pacman -S libwebp python-pillow" checkpoint_22

checkpoint_23() {
    sudo -E pacman -Syu --noconfirm harfbuzz
}
run_checkpoint 23 "sudo -E pacman -S harfbuzz" checkpoint_23

checkpoint_24() {
    sudo -E pacman -Syu --noconfirm glib2
}
run_checkpoint 24 "sudo -E pacman -S glib2" checkpoint_24

checkpoint_25() {
    sudo -E pacman -Syu --noconfirm pkgconf
}
run_checkpoint 25 "sudo -E pacman -S pkgconf" checkpoint_25

checkpoint_26() {
    yay -S --noconfirm gtest
}
run_checkpoint 26 "yay-S gtest" checkpoint_26

checkpoint_28() {
    sudo -E pacman -Syu --noconfirm re2c
}
run_checkpoint 28 "sudo -E pacman -S re2c" checkpoint_28

checkpoint_29() {
    sudo -E pacman -Syu --noconfirm ninja
}
run_checkpoint 29 "sudo -E pacman -S ninja" checkpoint_29

checkpoint_30() {
    sudo -E pacman -Syu --noconfirm docbook2x
}
run_checkpoint 30 "sudo -E pacman -S docbook2x" checkpoint_30

checkpoint_31() {
    sudo -E pacman -Syu --noconfirm docbook-xml docbook-xsl docbook-utils
}
run_checkpoint 31 "sudo -E pacman -S build-docbook-catalog" checkpoint_31

checkpoint_32() {
    sudo -E pacman -Syu --noconfirm gtk-doc
}
run_checkpoint 32 "sudo -E pacman -S gtk-doc" checkpoint_32

checkpoint_33() {
    sudo -E pacman -Syu --noconfirm zlib
}
run_checkpoint 33 "sudo -E pacman -S zlib" checkpoint_33

checkpoint_34() {
    sudo -E pacman -Syu --noconfirm libunistring
}
run_checkpoint 34 "sudo -E pacman -S libunistring" checkpoint_34

checkpoint_35() {
    sudo -E pacman -Syu --noconfirm file
}
run_checkpoint 35 "sudo -E pacman -S file" checkpoint_35

checkpoint_36() {
    sudo -E pacman -Syu --noconfirm extra-cmake-modules
}
run_checkpoint 36 "sudo -E pacman -S extra-cmake-modules" checkpoint_36

checkpoint_37() {
    sudo -E pacman -Syu --noconfirm perl-file-libmagic
}
run_checkpoint 37 "sudo -E pacman -S perl-file-libmagic" checkpoint_37

checkpoint_38() {
    sudo -E pacman -Syu --noconfirm libpsl
}
run_checkpoint 38 "sudo -E pacman -S libpsl" checkpoint_38

checkpoint_39() {
    sudo -E pacman -Syu --noconfirm expat
}
run_checkpoint 39 "sudo -E pacman -S expat" checkpoint_39

checkpoint_40() {
    sudo -E pacman -Syu --noconfirm duktape
}
run_checkpoint 40 "sudo -E pacman -S duktape" checkpoint_40

checkpoint_41() {
    sudo -E pacman -Syu --noconfirm brotli
    
}
run_checkpoint 41 "sudo -E pacman -S brotli" checkpoint_41

checkpoint_42() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}
run_checkpoint 42 "install rustup" checkpoint_42

checkpoint_43() {
    sudo -E pacman -Syu --noconfirm gc
}
run_checkpoint 43 "sudo -E pacman -S boehm-gc" checkpoint_43

checkpoint_44() {
    sudo -E pacman -Syu --noconfirm polkit
}
run_checkpoint 44 "sudo -E pacman -S polkit" checkpoint_44

checkpoint_45() {
    sudo -E pacman -Syu --noconfirm bubblewrap
}
run_checkpoint 45 "sudo -E pacman -S bubblewrap" checkpoint_45

checkpoint_46() {
    sudo -E pacman -Syu --noconfirm libclc
}
run_checkpoint 46 "sudo -E pacman -S libclc" checkpoint_46

checkpoint_47() {
    sudo -E pacman -Syu --noconfirm xorg-drivers
}
run_checkpoint 47 "sudo -E pacman -S xorg-drivers" checkpoint_47

checkpoint_48() {
    sudo -E pacman -Syu --noconfirm xorg-server
}
run_checkpoint 48 "sudo -E pacman -S xorg-server" checkpoint_48

checkpoint_49() {
    sudo -E pacman -Syu --noconfirm xorg-apps
}
run_checkpoint 49 "sudo -E pacman -S xorg-apps" checkpoint_49

checkpoint_50() {
    sudo -E pacman -Syu --noconfirm libx11
}
run_checkpoint 50 "sudo -E pacman -S libx11" checkpoint_50

checkpoint_51() {
    sudo -E pacman -Syu --noconfirm libxft
}
run_checkpoint 51 "sudo -E pacman -S libxft" checkpoint_51

checkpoint_52() {
    sudo -E pacman -Syu --noconfirm libxrender
}
run_checkpoint 52 "sudo -E pacman -S libxrender" checkpoint_52

checkpoint_53() {
    sudo -E pacman -Syu --noconfirm libxrandr
}
run_checkpoint 53 "sudo -E pacman -S libxrandr" checkpoint_53

checkpoint_54() {
    sudo -E pacman -Syu --noconfirm libxcursor
}
run_checkpoint 54 "sudo -E pacman -S libxcursor" checkpoint_54

checkpoint_55() {
    sudo -E pacman -Syu --noconfirm libxi
}
run_checkpoint 55 "sudo -E pacman -S libxi" checkpoint_55

checkpoint_56() {
    sudo -E pacman -Syu --noconfirm libxinerama
}
run_checkpoint 56 "sudo -E pacman -S libxinerama" checkpoint_56

checkpoint_57() {
    sudo -E pacman -Syu --noconfirm pango
}
run_checkpoint 57 "sudo -E pacman -S pango" checkpoint_57

checkpoint_58() {
    sudo -E pacman -Syu --noconfirm wayland
}
run_checkpoint 58 "sudo -E pacman -S wayland" checkpoint_58

checkpoint_63() {
    sudo -E pacman -Syu --noconfirm wayland-protocols
}
run_checkpoint 63 "pacman -Syu --noconfirm wayland-protocols" checkpoint_63

checkpoint_64() {
    sudo -E pacman -Syu --noconfirm xorg-xwayland
}
run_checkpoint 64 "pacman -Syu --noconfirm xorg-xwayland" checkpoint_64

checkpoint_65() {
    sudo -E pacman -Syu --noconfirm libxkbcommon
}
run_checkpoint 65 "pacman -Syu --noconfirm libxkbcommon" checkpoint_65

checkpoint_66() {
    sudo -E pacman -Syu --noconfirm gtk4 gtk3
}
run_checkpoint 66 "pacman -Syu --noconfirm gtk4 gtk3" checkpoint_66

checkpoint_67() {
    sudo -E pacman -Syu --noconfirm libxfce4util
}
run_checkpoint 67 "pacman -Syu --noconfirm libxfce4util" checkpoint_67

checkpoint_68() {
    sudo -E pacman -Syu --noconfirm xfconf
}
run_checkpoint 68 "pacman -Syu --noconfirm xfconf" checkpoint_68

checkpoint_69() {
    sudo -E pacman -Syu --noconfirm xdg-desktop-portal
}
run_checkpoint 69 "pacman -Syu --noconfirm xdg-desktop-portal" checkpoint_69

checkpoint_70() {
    sudo -E pacman -Syu --noconfirm xdg-desktop-portal-wlr
}
run_checkpoint 70 "pacman -Syu --noconfirm xdg-desktop-portal-wlr" checkpoint_70

checkpoint_71() {
    sudo -E pacman -Syu --noconfirm mesa
}
run_checkpoint 71 "pacman -Syu --noconfirm mesa" checkpoint_71

checkpoint_72() {
    sudo -E pacman -Syu --noconfirm mesa-demos
}
run_checkpoint 72 "pacman -Syu --noconfirm mesa-demos" checkpoint_72

checkpoint_73() {
    sudo -E pacman -Syu --noconfirm qt6-tools
}
run_checkpoint 73 "pacman -Syu --noconfirm qt6-tools" checkpoint_73

checkpoint_74() {
    sudo -E pacman -Syu --noconfirm qt6-base
}
run_checkpoint 74 "pacman -Syu --noconfirm qt6-base" checkpoint_74

checkpoint_75() {
    sudo -E pacman -Syu --noconfirm qt6-wayland
}
run_checkpoint 75 "pacman -Syu --noconfirm qt6-wayland" checkpoint_75

checkpoint_76() {
    sudo -E pacman -Syu --noconfirm qt6-5compat
}
run_checkpoint 76 "pacman -Syu --noconfirm qt6-5compat" checkpoint_76

checkpoint_77() {
    sudo -E pacman -Syu --noconfirm cmake
}
run_checkpoint 77 "pacman -Syu --noconfirm cmake" checkpoint_77

checkpoint_79() {
    sudo -E pacman -Syu --noconfirm dbus
}
run_checkpoint 79 "pacman -Syu --noconfirm dbus" checkpoint_79

checkpoint_80() {
    sudo -E pacman -Syu --noconfirm at-spi2-core
}
run_checkpoint 80 "pacman -Syu --noconfirm at-spi2-core" checkpoint_80

checkpoint_81() {
    if [[ "$ARCH" == "x86_64" ]]; then
        sudo -E pacman -Syu --noconfirm at-spi2-atk
    else
        echo "Skipping at-spi2-atk upgrade on $ARCH"
    fi
}
run_checkpoint 81 "pacman -Syu --noconfirm at-spi2-atk" checkpoint_81

checkpoint_82() {
    sudo -E pacman -Syu --noconfirm fontconfig
}
run_checkpoint 82 "pacman -Syu --noconfirm fontconfig" checkpoint_82

checkpoint_83() {
    sudo -E pacman -Syu --noconfirm ttf-dejavu
}
run_checkpoint 83 "pacman -Syu --noconfirm ttf-dejavu" checkpoint_83

checkpoint_84() {
    if [[ "$ARCH" == "x86_64" ]]; then
        yay -S --noconfirm gtk-engines
    else
        echo "Skipping gtk-engines on $ARCH"
    fi
}
run_checkpoint 84 "yay -S --noconfirm gtk-engines" checkpoint_84

checkpoint_86() {
    sudo -E pacman -Syu --noconfirm python python-pip
}
run_checkpoint 86 "pacman -Syu --noconfirm python python-pip" checkpoint_86

checkpoint_87() {
    sudo -E pacman -Syu --noconfirm libnotify
}
run_checkpoint 87 "pacman -Syu --noconfirm libnotify" checkpoint_87

checkpoint_88() {
    sudo -E pacman -Syu --noconfirm libdbusmenu-gtk3
}
run_checkpoint 88 "pacman -Syu --noconfirm libdbusmenu-gtk3" checkpoint_88

checkpoint_89() {
    sudo -E pacman -Syu --noconfirm libsm
}
run_checkpoint 89 "pacman -Syu --noconfirm libsm" checkpoint_89

checkpoint_90() {
    sudo -E pacman -Syu --noconfirm libice
}
run_checkpoint 90 "pacman -Syu --noconfirm libice" checkpoint_90

checkpoint_91() {
    sudo -E pacman -Syu --noconfirm libwnck3
}
run_checkpoint 91 "pacman -Syu --noconfirm libwnck3" checkpoint_91

checkpoint_92() {
    sudo pacman -S --noconfirm --overwrite '*' cmake
}
run_checkpoint 92 "pacman -Syu --noconfirm cmake" checkpoint_92

checkpoint_94() {
    sudo -E pacman -Syu --noconfirm exo
}
run_checkpoint 94 "pacman -Syu --noconfirm exo" checkpoint_94

checkpoint_95() {
    sudo -E pacman -Syu --noconfirm tar
}
run_checkpoint 95 "pacman -Syu --noconfirm tar" checkpoint_95

checkpoint_96() {
    sudo -E pacman -Syu --noconfirm xz
}
run_checkpoint 96 "pacman -Syu --noconfirm xz" checkpoint_96

checkpoint_97() {
    sudo -E pacman -Syu --noconfirm gnutls
}
run_checkpoint 97 "pacman -Syu --noconfirm gnutls" checkpoint_97

checkpoint_98() {
    sudo -E pacman -Syu --noconfirm glib-networking
}
run_checkpoint 98 "pacman -Syu --noconfirm glib-networking" checkpoint_98

checkpoint_99() {
    sudo -E pacman -Syu --noconfirm libseccomp
}
run_checkpoint 99 "sudo -E pacman -Syu --noconfirm libseccomp" checkpoint_99

checkpoint_100() {
    sudo -E pacman -Syu --noconfirm appstream-glib
}
run_checkpoint 100 "sudo -E pacman -Syu --noconfirm appstream-glib" checkpoint_100

checkpoint_101() {
    sudo -E pacman -Syu --noconfirm gpgme
}
run_checkpoint 101 "sudo -E pacman -Syu --noconfirm gpgme" checkpoint_101

checkpoint_102() {
    if [[ "$ARCH" == "x86_64" ]]; then
        sudo -E pacman -Syu --noconfirm ostree
    else
        echo "Skipping ostree on $ARCH"
    fi
}
run_checkpoint 102 "sudo -E pacman -Syu --noconfirm ostree" checkpoint_102

checkpoint_103() {
    sudo -E pacman -Syu --noconfirm xdg-dbus-proxy
}
run_checkpoint 103 "sudo -E pacman -Syu --noconfirm xdg-dbus-proxy" checkpoint_103

checkpoint_104() {
    sudo -E pacman -Syu --noconfirm gdk-pixbuf2
}
run_checkpoint 104 "sudo -E pacman -Syu --noconfirm gdk-pixbuf2" checkpoint_104

checkpoint_105() {
    sudo -E pacman -Syu --noconfirm fuse3
}
run_checkpoint 105 "sudo -E pacman -Syu --noconfirm fuse3" checkpoint_105

checkpoint_106() {
    sudo -E pacman -Syu --noconfirm python-gobject
}
run_checkpoint 106 "sudo -E pacman -Syu --noconfirm python-gobject" checkpoint_106

checkpoint_107() {
    sudo -E pacman -Syu --noconfirm dconf
}
run_checkpoint 107 "sudo -E pacman -Syu --noconfirm dconf" checkpoint_107

checkpoint_108() {
    sudo -E pacman -Syu --noconfirm xdg-utils
}
run_checkpoint 108 "sudo -E pacman -Syu --noconfirm xdg-utils" checkpoint_108

checkpoint_109() {
    sudo -E pacman -Syu --noconfirm xorg-xinit
}
run_checkpoint 109 "sudo -E pacman -Syu --noconfirm xinit" checkpoint_109

checkpoint_110() {
    sudo -E pacman -Syu --noconfirm xterm
}
run_checkpoint 110 "sudo -E pacman -Syu --noconfirm xterm" checkpoint_110

checkpoint_111() {
    sudo -E pacman -Syu --noconfirm xorg-twm
}
run_checkpoint 111 "sudo -E pacman -Syu --noconfirm twm" checkpoint_111

checkpoint_112() {
    sudo -E pacman -Syu --noconfirm python-pillow fastfetch
}
run_checkpoint 112 "sudo -E pacman -Syu --noconfirm python-pillow fastfetch" checkpoint_112

checkpoint_113() {
    sudo -E pacman -Syu --noconfirm chafa
}
run_checkpoint 113 "sudo -E pacman -Syu --noconfirm chafa" checkpoint_113

checkpoint_114() {
    sudo -E pacman -Syu --noconfirm doxygen
}
run_checkpoint 114 "sudo -E pacman -Syu --noconfirm doxygen" checkpoint_114

checkpoint_115() {
    sudo -E pacman -Syu --noconfirm libclc egl-gbm
}
run_checkpoint 115 "sudo -E pacman -Syu --noconfirm libclc egl-gbm" checkpoint_115

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
if [ ! -f "/.chard_chrome" ]; then
    CHROME_VER=139
else
    CHROME_VER=$(cat /.chard_chrome)
fi
if [ "$CHROME_VER" -le 139 ]; then
    sudo -E pacman -Syu --noconfirm flatpak
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo chown -R 1000:1000 ~/.local/share/flatpak
else
    sudo -E pacman -Syu --noconfirm flatpak
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo chown -R 1000:1000 ~/.local/share/flatpak
    sudo tee /bin/chard_flatpak >/dev/null <<'EOF'
#!/bin/bash
export PATH=/usr/local/bubblepatch/bin:$PATH
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
USER_ID=1000
GROUP_ID=1000
export STEAM_USER_HOME="$HOME/.local/share/Steam"

source ~/.bashrc
xhost +SI:localuser:root

sudo setfacl -Rm u:root:rwx /run/chrome 2>/dev/null
sudo setfacl -Rm u:1000:rwx /run/chrome 2>/dev/null

sudo -i /usr/bin/env bash -c 'exec /usr/bin/flatpak "$@"' _ "$@"
sudo setfacl -Rb /run/chrome 2>/dev/null
EOF

sudo chmod +x /bin/chard_flatpak
fi
}
run_checkpoint 117 "sudo -E pacman -Syu --noconfirm flatpak" checkpoint_117

checkpoint_118() {
    sudo -E pacman -Syu --noconfirm thunar
}
run_checkpoint 118 "sudo -E pacman -Syu --noconfirm thunar" checkpoint_118

checkpoint_119() {
    sudo -E pacman -Syu --noconfirm gvfs
}
run_checkpoint 119 "sudo -E pacman -Syu --noconfirm gvfs" checkpoint_119

checkpoint_120() {
    sudo -E pacman -Syu --noconfirm xfce4
}
run_checkpoint 120 "sudo -E pacman -Syu --noconfirm xfce4" checkpoint_120

checkpoint_121() { 
    sudo -E pacman -Syu --noconfirm pulseaudio
}
run_checkpoint 121 "pulse audio" checkpoint_121

checkpoint_122() {
    sudo -E pacman -Syu --noconfirm libva
}
run_checkpoint 122 "sudo -E pacman -Syu --noconfirm libva" checkpoint_122

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
        sudo -E pacman -Syu --noconfirm libva-intel-driver intel-media-driver
    else
        echo "[*] Skipping Intel driver installation"
    fi
}
run_checkpoint 123 "sudo -E pacman -Syu --noconfirm intel-media-driver" checkpoint_123

checkpoint_124() {
    sudo -E pacman -Syu --noconfirm ffmpeg
    sudo -E pacman -Syu --noconfirm gst-plugins-base
    sudo -E pacman -Syu --noconfirm gst-plugins-good
    sudo -E pacman -Syu --noconfirm gst-plugins-bad
    sudo -E pacman -Syu --noconfirm gst-plugins-ugly
    if [[ "$ARCH" == "x86_64" ]]; then
        sudo -E pacman -Syu --noconfirm lib32-gst-plugins-base
        sudo -E pacman -Syu --noconfirm lib32-gst-plugins-good
    else
        echo "Skipping lib32-gst on $ARCH"
    fi
    sudo -E pacman -Syu --noconfirm libao yt-dlp opus ffmpeg vlc
}
run_checkpoint 124 "sudo -E pacman -Syu --noconfirm yt-dlp + vlc" checkpoint_124

checkpoint_125() {
    sudo -E pacman -Syu --noconfirm vulkan-tools
}
run_checkpoint 125 "sudo -E pacman -Syu --noconfirm vulkan-tools" checkpoint_125

checkpoint_126() {
    sudo -E pacman -Syu --noconfirm p7zip arj lha lzop unrar unzip zip xarchiver
}
run_checkpoint 126 "sudo -E pacman -Syu --noconfirm xarchiver + archivers" checkpoint_126

checkpoint_127() {
    sudo -E pacman -Syu --noconfirm gimp
}
run_checkpoint 127 "sudo -E pacman -Syu --noconfirm gimp" checkpoint_127

checkpoint_128() {
    cd /usr/share/X11/xkb/symbols
    sudo cp inet ~/.inet.backup
    sudo sed -i -E 's/^\s*key <I(360|362|368|370|373|374|376|377|381|384|385|386|387|388|389|391|392|393|394|395|396|398|417|421|570|598|599)>/\/\/ &/' inet
}
run_checkpoint 128 "Keyboard error spam fix" checkpoint_128

#checkpoint_129() {
#    sudo -E pacman -Syu --noconfirm libreoffice-fresh
#}
#run_checkpoint 129 "sudo -E pacman -Syu --noconfirm libreoffice" checkpoint_129

checkpoint_130() {
    if [[ "$ARCH" == "x86_64" ]]; then
        sudo -E pacman -Syu --noconfirm obs-studio
        yay -S --noconfirm obs-vkcapture
    else
        echo "Skipping OBS on $ARCH"
    fi
}
run_checkpoint 130 "sudo -E pacman -Syu --noconfirm obs-studio" checkpoint_130

checkpoint_131() {
    sudo -E pacman -Syu --noconfirm ruby
}
run_checkpoint 131 "sudo -E pacman -Syu --noconfirm ruby" checkpoint_131

checkpoint_132() {
    sudo -E pacman -Syu --noconfirm gparted
    sudo -E pacman -Syu --noconfirm exfatprogs
    sudo -E pacman -Syu --noconfirm dosfstools
    sudo -E pacman -Syu --noconfirm ntfs-3g 
    sudo -E pacman -Syu --noconfirm mtools
}
run_checkpoint 132 "sudo -E pacman -Syu --noconfirm gparted" checkpoint_132

#checkpoint_133() {
#    yay -S --noconfirm balena-etcher
#}
#run_checkpoint 133 "balena-etcher" checkpoint_133

checkpoint_134() {
    sudo -E pacman -Syu --noconfirm qemu-desktop
}
run_checkpoint 134 "sudo -E pacman -Syu --noconfirm qemu" checkpoint_134

checkpoint_135() {
    if [[ "$ARCH" == "x86_64" ]]; then
        sudo -E pacman -Syu --noconfirm lib32-libxtst
        sudo -E pacman -Syu --noconfirm lib32-libxrandr
        sudo -E pacman -Syu --noconfirm lib32-libxrender
        sudo -E pacman -Syu --noconfirm lib32-libxi
        sudo -E pacman -Syu --noconfirm lib32-gdk-pixbuf2
        sudo -E pacman -Syu --noconfirm lib32-pulseaudio
        yay -S --noconfirm lib32-gtk2
    else
        echo "Skipping lib32 audio on $ARCH"
    fi
}
run_checkpoint 135 "sudo -E pacman -Syu --noconfirm lib32gpu" checkpoint_135

checkpoint_136() {
    curl -fsS https://dl.brave.com/install.sh | sh
}
run_checkpoint 136 "curl -fsS https://dl.brave.com/install.sh | sh" checkpoint_136

checkpoint_137() {
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        sudo -E pacman -Syu --needed --noconfirm lib32-libvdpau
        yay -S --noconfirm lib32-gtk2
        sudo -E pacman -Syu --noconfirm meson ninja pkgconf libcap libcap-ng glib2 git
        sudo -E pacman -Syu --noconfirm bubblewrap
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

        sudo -E pacman -Syu --noconfirm steam

        STEAM_SCRIPT="/usr/lib/steam/steam"
        sudo sed -i.bak -E '/if \[ "\$\(id -u\)" == "0" \]; then/,/fi/ s/^/#/' "$STEAM_SCRIPT"

        sudo tee /bin/chard_steam >/dev/null <<'EOF'
#!/bin/bash
export PATH=/usr/local/bubblepatch/bin:$PATH
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
STEAM_USER_HOME=$CHARD_HOME/.local/share/Steam
xhost +SI:localuser:$USER
sudo setfacl -Rm u:$USER:rwx /run/chrome 2>/dev/null
sudo setfacl -Rm u:root:rwx /run/chrome 2>/dev/null
/usr/bin/steam
sudo setfacl -Rb /run/chrome 2>/dev/null
EOF
        sudo chmod +x /bin/chard_steam
elif [[ "$ARCH" == "aarch64" ]]; then
    sudo -E pacman -Syu --needed --noconfirm meson ninja pkgconf libcap libcap-ng glib2 git bubblewrap
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
            sudo -E pacman -Syu --noconfirm \
                mesa mesa-vdpau lib32-mesa \
                vulkan-intel lib32-vulkan-intel
            ;;
        amd)
            echo "[+] Installing AMD Vulkan drivers..."
            sudo -E pacman -Syu --noconfirm \
                mesa mesa-vdpau lib32-mesa \
                vulkan-radeon lib32-vulkan-radeon
            ;;

        nvidia)
            echo "[+] Installing NVIDIA Vulkan drivers..."
            KVER=$(uname -r)
            if [[ "$KVER" == *"lts"* ]]; then
                DRIVER="nvidia-lts"
            else
                DRIVER="nvidia"
            fi

            sudo -E pacman -Syu --noconfirm \
                $DRIVER nvidia-utils lib32-nvidia-utils \
                vulkan-icd-loader lib32-vulkan-icd-loader
            ;;

        mali|panfrost|mediatek|vivante|asahi)
            echo "[+] Installing Mesa ARM Vulkan drivers..."
            sudo -E pacman -Syu --noconfirm mesa mesa-vdpau 2>/dev/null
            ;;

        adreno)
            echo "[+] Installing Adreno Vulkan drivers..."
            sudo -E pacman -Syu --noconfirm mesa mesa-vdpau 2>/dev/null
            ;;

        *)
            echo "[!] Unknown GPU type. Installing generic Vulkan support..."
            sudo -E pacman -Syu --noconfirm \
                mesa mesa-vdpau vulkan-icd-loader
            ;;
    esac
}
run_checkpoint 138 "vulkan" checkpoint_138

checkpoint_139() {
    ARCH=$(uname -m)
    sudo rm /etc/pipewire/pipewire.conf.d/crostini-audio.conf 2>/dev/null
    sudo -E pacman -R --noconfirm cros-container-guest-tools-git 2>/dev/null
    sudo -E pacman -R --noconfirm pulseaudio 2>/dev/null
    rm -rf ~/.config/pulse 2>/dev/null
    rm -rf ~/.pulse 2>/dev/null
    rm -rf ~/.cache/pulse 2>/dev/null
    sudo -E pacman -Syu --noconfirm pipewire-pulse
    sudo -E pacman -Syu --noconfirm alsa-lib alsa-utils alsa-plugins
    sudo rm -rf ~/.cache/bazel 2>/dev/null
    if [[ "$ARCH" == "x86_64" ]]; then
        BAZEL_URL="https://github.com/bazelbuild/bazel/releases/download/6.5.0/bazel-6.5.0-linux-x86_64"
    elif [[ "$ARCH" == "aarch64" ]]; then
        BAZEL_URL="https://github.com/bazelbuild/bazel/releases/download/6.5.0/bazel-6.5.0-linux-arm64"
    else
        echo "Unsupported architecture: $ARCH"
    fi
    echo "Downloading Bazel from: $BAZEL_URL"
    sudo curl -L "$BAZEL_URL" -o /usr/bin/bazel65
    sudo chmod +x /usr/bin/bazel65
    cd ~/
    git clone https://chromium.googlesource.com/chromiumos/third_party/adhd
    cd adhd/
    sudo -E /usr/bin/bazel65 build //dist:alsa_lib
    sleep 1
    sudo mkdir -p /usr/lib/alsa-lib/
    sudo cp ~/adhd/bazel-bin/cras/src/alsa_plugin/libasound_module_ctl_cras.so /usr/lib/alsa-lib/
    sudo cp ~/adhd/bazel-bin/cras/src/alsa_plugin/libasound_module_pcm_cras.so /usr/lib/alsa-lib/
    sudo cp ~/adhd/bazel-bin/cras/src/libcras/libcras.so /usr/lib/
    sudo mkdir -p /etc/pipewire/pipewire.conf.d
    cd ~/
    rm -rf ~/adhd
    sudo tee /etc/pipewire/pipewire.conf.d/crostini-audio.conf >/dev/null << 'EOF'
context.objects = [
    { factory = adapter
      args = {
        factory.name           = api.alsa.pcm.sink
        node.name              = "Virtio Soundcard Sink"
        media.class            = "Audio/Sink"
        api.alsa.path          = "hw:0,0"
        audio.channels         = 2
        audio.position         = "FL,FR"
      }
    }
    { factory = adapter
      args = {
        factory.name           = api.alsa.pcm.source
        node.name              = "Virtio Soundcard Source"
        media.class            = "Audio/Source"
        api.alsa.path          = "hw:0,1"
        audio.channels         = 2
        audio.position         = "FL,FR"
      }
    }
]
EOF
pactl set-default-sink "Virtio Soundcard Sink"
pactl set-default-source "Virtio Soundcard Source"
}
run_checkpoint 139 "CRAS" checkpoint_139

checkpoint_140() {
    for f in /etc/machine-id /var/lib/dbus/machine-id; do
        if [ -f "$f" ]; then
            sudo rm "$f"
        fi
    done
    sudo dbus-uuidgen --ensure=/etc/machine-id
    sudo dbus-uuidgen --ensure=/var/lib/dbus/machine-id
    file=/usr/share/libalpm/hooks/90-packagekit-refresh.hook
    if [ -e "$file" ]; then
        sudo mv "$file" "$file.disabled"
    fi
    sudo pacman -Rdd --noconfirm xfce4-notifyd xfce4-power-manager
    PANEL_CFG="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
    if [[ -f "$PANEL_CFG" ]]; then
        sed -i 's/<property name="position-locked" type="bool" value="true"\/>/<property name="position-locked" type="bool" value="false"\/>/' "$PANEL_CFG"
    fi  
}
run_checkpoint 140 "Fix machine-id" checkpoint_140

checkpoint_141() {
yay -S --noconfirm prismlauncher
sudo -E pacman -Syu --noconfirm gamemode
sudo pacman -Syu --noconfirm flite
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
sudo -E pacman -Syu --noconfirm firefox
sudo tee /bin/chard_firefox >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
HOME=/$CHARD_HOME
USER=$CHARD_USER
PATH=/usr/local/bubblepatch/bin:$PATH
xhost +SI:localuser:root
source ~/.bashrc
sudo -u $CHARD_USER /usr/bin/firefox
EOF
sudo chmod +x /bin/chard_firefox
}
run_checkpoint 142 "Firefox" checkpoint_142

checkpoint_143() {
cd ~/
XA="$HOME/.Xauthority"
if [[ -f "$XA" ]]; then
    rm "$XA"
fi
touch ~/.Xauthority 2>/dev/null
sudo -E pacman -Syu --noconfirm gedit 2>/dev/null
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
}
run_checkpoint 143 "X Authority & gedit" checkpoint_143

checkpoint_144() {
yay -S --noconfirm pamac
}
run_checkpoint 144 "pamac" checkpoint_144

#checkpoint_135() {
#    printf "A\nN\ny\ny\ny\n" | yay -S --noconfirm heroic-games-launcher
#}
#run_checkpoint 135 "yay -S --noconfirm heroic-games-launcher" checkpoint_135

#checkpoint_136() {
#    printf "A\nN\ny\ny\ny\n" | yay -S --noconfirm vscodium
#}
#run_checkpoint 136 "yay -S --noconfirm vscodium" checkpoint_136

#checkpoint_137() {
#    yay -S --noconfirm prismlauncher
#}
#run_checkpoint 137 "sudo -E pacman -Syu --noconfirm prismlauncher" checkpoint_137

# yay -S --noconfirm libselinux
# yay -S --noconfirm bash-completion

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
        CHECKPOINT_OVERRIDE=$1
        echo "${MAGENTA}Setting checkpoint to $CHECKPOINT_OVERRIDE ${RESET}"
        echo "$CHECKPOINT_OVERRIDE" | sudo tee "$CHECKPOINT_FILE" >/dev/null
        CURRENT_CHECKPOINT=$CHECKPOINT_OVERRIDE
        ;;
esac
