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

LOG_FILE="/chariot.log"
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
    CURRENT_CHECKPOINT=0
fi

trap 'echo; echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${RED}Exiting${RESET}"; exit 1' SIGINT

run_checkpoint() {
    local step=$1
    local desc=$2
    shift 2

    if (( CURRENT_CHECKPOINT < step )); then
        echo
        echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}>${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${GREEN}${BOLD}Checkpoint $step ($desc) Starting ${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${GREEN}"
        echo

        "$@"
        local ret=$?

        if (( ret != 0 )); then
            echo
            echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}>${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${RED}${BOLD}Checkpoint $step ($desc) DNF ${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${GREEN}${RESET}${GREEN}"
            echo
            exit $ret
        fi

        echo $step > "$CHECKPOINT_FILE"
        sync
        CURRENT_CHECKPOINT=$step
        echo
        echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}>${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${GREEN}${BOLD}Checkpoint $step ($desc) Finished ${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${GREEN}${RESET}${GREEN}"
        echo
    else
        echo "${RESET}${YELLOW}>${RED}>${RESET}${GREEN}>${RESET}${YELLOW}>${RED}>${RESET}${GREEN}> ${RESET}${CYAN}${BOLD}Checkpoint $step ($desc) Completed ${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${YELLOW}<${RED}<${RESET}${GREEN}<${RESET}${GREEN}${RESET}${GREEN}"
        echo
    fi
}

checkpoint_1() {
    emerge dev-build/make
    rm -rf /var/tmp/portage/dev-build/make-*
}
run_checkpoint 1 "emerge dev-build/make" checkpoint_1

checkpoint_2() {
    emerge app-portage/gentoolkit
    rm -rf /var/tmp/portage/app-portage/gentoolkit-*
    eclean-dist -d
}
run_checkpoint 2 "emerge app-portage/gentoolkit" checkpoint_2

checkpoint_3() {
    USE="-gui" emerge -1 dev-build/cmake
    rm -rf /var/tmp/portage/dev-build/cmake-*
    eclean-dist -d
}
run_checkpoint 3 'USE="-gui" emerge -1 dev-build/cmake' checkpoint_3

checkpoint_4() {
    emerge app-misc/resolve-march-native
    TARGET_FILE="$HOME/.bashrc"
    BACKUP_FILE="$TARGET_FILE.bak"
    [[ -f "$TARGET_FILE" ]] || { echo "File not found: $TARGET_FILE"; exit 1; }
    cp "$TARGET_FILE" "$BACKUP_FILE"
    NATIVE_FLAGS=$(resolve-march-native)
    CLEAN_FLAGS=$(echo "$NATIVE_FLAGS" | sed -E 's/\+crc//g; s/\+crypto//g')
    APPEND_FLAGS="$CLEAN_FLAGS"

    read -r -d '' NEW_BLOCK << EOM
# <<< CHARD_MARCH_NATIVE >>>
CFLAGS="-march=native -O2 -pipe $APPEND_FLAGS"
[[ -d "\$ROOT/usr/include" ]] && CFLAGS+="-I\$ROOT/usr/include "
[[ -d "\$ROOT/include" ]] && CFLAGS+="-I\$ROOT/include "
export CFLAGS

COMMON_FLAGS="-march=native -O2 -pipe $APPEND_FLAGS"
FCFLAGS="\$COMMON_FLAGS"
FFLAGS="\$COMMON_FLAGS"

CXXFLAGS="\$CFLAGS"
# <<< END CHARD_MARCH_NATIVE >>>
EOM

    awk -v newblock="$NEW_BLOCK" '
BEGIN { inside=0 }
/# <<< CHARD_MARCH_NATIVE >>>/ { 
    print newblock; inside=1; next 
}
/# <<< END CHARD_MARCH_NATIVE >>>/ { inside=0; next }
!inside { print }
    ' "$BACKUP_FILE" > "$TARGET_FILE"

    #source ~/.bashrc
    #emerge sys-devel/gcc
    #rm -rf /var/tmp/portage/sys-devel/gcc-*
    rm -rf /var/tmp/portage/app-misc/resolve-march-native-*
    eclean-dist -d
}
run_checkpoint 4 "emerge resolve-march-native" checkpoint_4

checkpoint_5() {
    emerge dev-libs/gmp
    rm -rf /var/tmp/portage/dev-libs/gmp-*
    eclean-dist -d
}
run_checkpoint 5 "emerge dev-libs/gmp" checkpoint_5

checkpoint_6() {
    emerge dev-libs/mpfr
    rm -rf /var/tmp/portage/dev-libs/mpfr-*
    eclean-dist -d
}
run_checkpoint 6 "emerge dev-libs/mpfr" checkpoint_6

checkpoint_7() {
    emerge sys-devel/binutils
    rm -rf /var/tmp/portage/sys-devel/binutils-*
    eclean-dist -d
}
run_checkpoint 7 "emerge sys-devel/binutils" checkpoint_7

checkpoint_8() {
    emerge sys-apps/diffutils
    rm -rf /var/tmp/portage/sys-apps/diffutils-*
    eclean-dist -d
}
run_checkpoint 8 "emerge sys-apps/diffutils" checkpoint_8

checkpoint_9() {
    emerge dev-libs/openssl
    rm -rf /var/tmp/portage/dev-libs/openssl-*
    eclean-dist -d
}
run_checkpoint 9 "emerge dev-libs/openssl" checkpoint_9

checkpoint_10() {
    emerge net-misc/curl
    rm -rf /var/tmp/portage/net-misc/curl-*
    eclean-dist -d
}
run_checkpoint 10 "emerge net-misc/curl" checkpoint_10

checkpoint_11() {
    emerge dev-vcs/git
    rm -rf /var/tmp/portage/dev-vcs/git-*
    eclean-dist -d
}
run_checkpoint 11 "emerge dev-vcs/git" checkpoint_11

checkpoint_12() {
    emerge sys-apps/coreutils
    rm -rf /var/tmp/portage/sys-apps/coreutils-*
    eclean-dist -d
}
run_checkpoint 12 "emerge sys-apps/coreutils" checkpoint_12

checkpoint_13() {
    emerge app-misc/fastfetch
    rm -rf /var/tmp/portage/app-misc/fastfetch-*
    eclean-dist -d
}
run_checkpoint 13 "emerge app-misc/fastfetch" checkpoint_13

checkpoint_14() {
    emerge dev-lang/perl
    rm -rf /var/tmp/portage/dev-lang/perl-*
    eclean-dist -d
}
run_checkpoint 14 "emerge dev-lang/perl" checkpoint_14

checkpoint_15() {
    emerge dev-perl/Capture-Tiny
    rm -rf /var/tmp/portage/dev-perl/Capture-Tiny-*
    eclean-dist -d
}
run_checkpoint 15 "emerge dev-perl/Capture-Tiny" checkpoint_15

checkpoint_16() {
    emerge dev-perl/Try-Tiny
    rm -rf /var/tmp/portage/dev-perl/Try-Tiny-*
    eclean-dist -d
}
run_checkpoint 16 "emerge dev-perl/Try-Tiny" checkpoint_16

checkpoint_17() {
    emerge dev-perl/Config-AutoConf
    rm -rf /var/tmp/portage/dev-perl/Config-AutoConf-*
    eclean-dist -d
}
run_checkpoint 17 "emerge dev-perl/Config-AutoConf" checkpoint_17

checkpoint_18() {
    emerge dev-perl/Test-Fatal
    rm -rf /var/tmp/portage/dev-perl/Test-Fatal-*
    eclean-dist -d
}
run_checkpoint 18 "emerge dev-perl/Test-Fatal" checkpoint_18

checkpoint_19() {
    emerge sys-apps/findutils
    rm -rf /var/tmp/portage/sys-apps/findutils-*
    eclean-dist -d
}
run_checkpoint 19 "emerge sys-apps/findutils" checkpoint_19

checkpoint_20() {
    emerge dev-libs/elfutils
    rm -rf /var/tmp/portage/dev-libs/elfutils-*
    eclean-dist -d
}
run_checkpoint 20 "emerge dev-libs/elfutils" checkpoint_20

checkpoint_21() {
    if [ $(uname -m) = aarch64 ]; then
        export ARCH=arm64
    fi
    cd /usr/src/linux
    scripts/kconfig/merge_config.sh -m .config enable_features.cfg
    make olddefconfig
    make -j$(nproc) tools/objtool
    make -j$(nproc)
    make modules_install
    make INSTALL_PATH=/boot install
    if [ $(uname -m) = aarch64 ]; then
        export ARCH=aarch64
    fi
}
run_checkpoint 21 "build and install kernel + modules" checkpoint_21

checkpoint_22() {
    emerge dev-lang/python
    rm -rf /var/tmp/portage/dev-lang/python-*
    eclean-dist -d
}
run_checkpoint 22 "emerge dev-lang/python" checkpoint_22

checkpoint_23() {
    emerge dev-build/meson
    rm -rf /var/tmp/portage/dev-build/meson-*
    eclean-dist -d
}
run_checkpoint 23 "emerge dev-build/meson" checkpoint_23

checkpoint_24() {
    USE="-truetype" emerge -1 dev-python/pillow
    rm -rf /var/tmp/portage/dev-python/pillow-*
    eclean-dist -d
}
run_checkpoint 24 "emerge dev-python/pillow" checkpoint_24

checkpoint_25() {
    emerge media-libs/harfbuzz
    rm -rf /var/tmp/portage/media-libs/harfbuzz-*
    eclean-dist -d
}
run_checkpoint 25 "emerge media-libs/harfbuzz" checkpoint_25

checkpoint_26() {
    emerge dev-libs/glib
    rm -rf /var/tmp/portage/dev-libs/glib-*
    eclean-dist -d
}
run_checkpoint 26 "emerge dev-libs/glib" checkpoint_26

checkpoint_27() {
    emerge dev-util/pkgcon
    rm -rf /var/tmp/portage/dev-util/pkgcon-*
    eclean-dist -d
}
run_checkpoint 27 "emerge dev-util/pkgcon" checkpoint_27

checkpoint_28() {
    emerge dev-cpp/gtest
    rm -rf /var/tmp/portage/dev-cpp/gtest-*
    eclean-dist -d
}
run_checkpoint 28 "emerge dev-cpp/gtest" checkpoint_28

checkpoint_29() {
    emerge dev-util/gtest-parallel
    rm -rf /var/tmp/portage/dev-util/gtest-parallel-*
    eclean-dist -d
}
run_checkpoint 29 "emerge dev-util/gtest-parallel" checkpoint_29

checkpoint_30() {
    emerge dev-util/re2c
    rm -rf /var/tmp/portage/dev-util/re2c-*
    eclean-dist -d
}
run_checkpoint 30 "emerge dev-util/re2c" checkpoint_30

checkpoint_31() {
    emerge dev-build/ninja
    rm -rf /var/tmp/portage/dev-build/ninja-*
    eclean-dist -d
}
run_checkpoint 31 "emerge dev-build/ninja" checkpoint_31

checkpoint_32() {
    emerge app-text/docbook2X
    rm -rf /var/tmp/portage/app-text/docbook2X-*
    eclean-dist -d
}
run_checkpoint 32 "emerge app-text/docbook2X" checkpoint_32

checkpoint_33() {
    emerge app-text/build-docbook-catalog
    rm -rf /var/tmp/portage/app-text/build-docbook-catalog-*
    eclean-dist -d
}
run_checkpoint 33 "emerge app-text/build-docbook-catalog" checkpoint_33

checkpoint_34() {
    emerge dev-util/gtk-doc
    rm -rf /var/tmp/portage/dev-util/gtk-doc-*
    eclean-dist -d
}
run_checkpoint 34 "emerge dev-util/gtk-doc" checkpoint_34

checkpoint_35() {
    emerge sys-libs/zlib
    rm -rf /var/tmp/portage/sys-libs/zlib-*
    eclean-dist -d
}
run_checkpoint 35 "emerge sys-libs/zlib" checkpoint_35

checkpoint_36() {
    emerge dev-libs/libunistring
    rm -rf /var/tmp/portage/dev-libs/libunistring-*
    eclean-dist -d
}
run_checkpoint 36 "emerge dev-libs/libunistring" checkpoint_36

checkpoint_37() {
    emerge sys-apps/file
    rm -rf /var/tmp/portage/sys-apps/file-*
    eclean-dist -d
}
run_checkpoint 37 "emerge sys-apps/file" checkpoint_37

checkpoint_38() {
    emerge kde-frameworks/extra-cmake-modules
    rm -rf /var/tmp/portage/kde-frameworks/extra-cmake-modules-*
    eclean-dist -d
}
run_checkpoint 38 "emerge kde-frameworks/extra-cmake-modules" checkpoint_38

checkpoint_39() {
    emerge -j$(nproc) dev-perl/File-LibMagic
    rm -rf /var/tmp/portage/dev-perl/File-LibMagic-*
    eclean-dist -d
}
run_checkpoint 39 "emerge dev-perl/File-LibMagic" checkpoint_39

checkpoint_40() {
    emerge net-libs/libpsl
    rm -rf /var/tmp/portage/net-libs/libpsl-*
    eclean-dist -d
}
run_checkpoint 40 "emerge net-libs/libpsl" checkpoint_40

checkpoint_41() {
    emerge dev-libs/expat
    rm -rf /var/tmp/portage/dev-libs/expat-*
    eclean-dist -d
}
run_checkpoint 41 "emerge dev-libs/expat" checkpoint_41

checkpoint_42() {
    emerge dev-lang/duktape
    rm -rf /var/tmp/portage/dev-lang/duktape-*
    eclean-dist -d
}
run_checkpoint 42 "emerge dev-lang/duktape" checkpoint_42

checkpoint_43() {
    emerge app-arch/brotli
    rm -rf /var/tmp/portage/app-arch/brotli-*
    eclean-dist -d
}
run_checkpoint 43 "emerge app-arch/brotli" checkpoint_43

checkpoint_44() {
    mv /usr/lib/libcrypt.so /usr/lib/libcrypt.so.bak || true
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}
run_checkpoint 44 "backup libcrypt + install rustup" checkpoint_44

checkpoint_45() {
    emerge -j$(nproc) dev-libs/boehm-gc
    rm -rf /var/tmp/portage/dev-libs/boehm-gc-*
    eclean-dist -d
}
run_checkpoint 45 "emerge dev-libs/boehm-gc" checkpoint_45

checkpoint_46() {
    emerge sys-auth/polkit
    rm -rf /var/tmp/portage/sys-auth/polkit-*
    eclean-dist -d
}
run_checkpoint 46 "emerge sys-auth/polkit" checkpoint_46

checkpoint_47() {
    emerge sys-apps/bubblewrap
    rm -rf /var/tmp/portage/sys-apps/bubblewrap-*
    eclean-dist -d
}
run_checkpoint 47 "emerge sys-apps/bubblewrap" checkpoint_47
# Fix for long term
checkpoint_48() {
    emerge -v =llvm-core/libclc-20*
    rm -rf /var/tmp/portage/llvm-core/libclc-*
    eclean-dist -d
}
run_checkpoint 48 "emerge llvm-core/libclc-20" checkpoint_48


checkpoint_60() {
    emerge dev-libs/wayland
    rm -rf /var/tmp/portage/dev-libs/wayland-*
    eclean-dist -d
}
run_checkpoint 60 "emerge dev-libs/wayland" checkpoint_60

checkpoint_61() {
    emerge dev-libs/wayland-protocols
    rm -rf /var/tmp/portage/dev-libs/wayland-protocols-*
    eclean-dist -d
}
run_checkpoint 61 "emerge dev-libs/wayland-protocols" checkpoint_61

checkpoint_64() {
    emerge gui-libs/gtk
    rm -rf /var/tmp/portage/gui-libs/gtk-*
    eclean-dist -d
}
run_checkpoint 64 "emerge gui-libs/gtk" checkpoint_64

checkpoint_65() {
    emerge xfce-base/libxfce4util
    rm -rf /var/tmp/portage/xfce-base/libxfce4util-*
    eclean-dist -d
}
run_checkpoint 65 "emerge xfce-base/libxfce4util" checkpoint_65

checkpoint_66() {
    emerge xfce-base/xfconf
    rm -rf /var/tmp/portage/xfce-base/xfconf-*
    eclean-dist -d
}
run_checkpoint 66 "emerge xfce-base/xfconf" checkpoint_66

checkpoint_67() {
    emerge sys-apps/xdg-desktop-portal
    rm -rf /var/tmp/portage/sys-apps/xdg-desktop-portal-*
    eclean-dist -d
}
run_checkpoint 67 "emerge sys-apps/xdg-desktop-portal" checkpoint_67

checkpoint_68() {
    emerge gui-libs/xdg-desktop-portal-wlr
    rm -rf /var/tmp/portage/gui-libs/xdg-desktop-portal-wlr-*
    eclean-dist -d
}
run_checkpoint 68 "emerge gui-libs/xdg-desktop-portal-wlr" checkpoint_68

checkpoint_69() {
    emerge media-libs/mesa
    rm -rf /var/tmp/portage/media-libs/mesa-*
    eclean-dist -d
}
run_checkpoint 69 "emerge media-libs/mesa" checkpoint_69

checkpoint_71() {
    emerge dev-qt/qtbase
    rm -rf /var/tmp/portage/dev-qt/qtbase-*
    eclean-dist -d
}
run_checkpoint 71 "emerge dev-qt/qtbase" checkpoint_71

checkpoint_72() {
    emerge dev-qt/qttools
    rm -rf /var/tmp/portage/dev-qt/qttools-*
    eclean-dist -d
}
run_checkpoint 72 "emerge dev-qt/qttools" checkpoint_72

checkpoint_73() {
    emerge dev-qt/qtnetwork
    rm -rf /var/tmp/portage/dev-qt/qtnetwork-*
    eclean-dist -d
}
run_checkpoint 73 "emerge dev-qt/qtnetwork" checkpoint_73

checkpoint_74() {
    emerge dev-qt/qtconcurrent
    rm -rf /var/tmp/portage/dev-qt/qtconcurrent-*
    eclean-dist -d
}
run_checkpoint 74 "emerge dev-qt/qtconcurrent" checkpoint_74

checkpoint_75() {
    emerge dev-qt/qtxml
    rm -rf /var/tmp/portage/dev-qt/qtxml-*
    eclean-dist -d
}
run_checkpoint 75 "emerge dev-qt/qtxml" checkpoint_75

checkpoint_76() {
    emerge dev-qt/qtgui
    rm -rf /var/tmp/portage/dev-qt/qtgui-*
    eclean-dist -d
}
run_checkpoint 76 "emerge dev-qt/qtgui" checkpoint_76

checkpoint_77() {
    emerge dev-qt/qtcore
    rm -rf /var/tmp/portage/dev-qt/qtcore-*
    eclean-dist -d
}
run_checkpoint 77 "emerge dev-qt/qtcore" checkpoint_77

checkpoint_78() {
    emerge dev-build/cmake
    rm -rf /var/tmp/portage/dev-build/cmake-*
    eclean-dist -d
}
run_checkpoint 78 "emerge dev-build/cmake" checkpoint_78

checkpoint_79() {
    emerge sys-apps/dbus
    rm -rf /var/tmp/portage/sys-apps/dbus-*
    eclean-dist -d
}
run_checkpoint 79 "emerge sys-apps/dbus" checkpoint_79

checkpoint_80() {
    emerge app-accessibility/at-spi2-core
    rm -rf /var/tmp/portage/app-accessibility/at-spi2-core-*
    eclean-dist -d
}
run_checkpoint 80 "emerge app-accessibility/at-spi2-core" checkpoint_80

checkpoint_81() {
    emerge app-accessibility/at-spi2-atk
    rm -rf /var/tmp/portage/app-accessibility/at-spi2-atk-*
    eclean-dist -d
}
run_checkpoint 81 "emerge app-accessibility/at-spi2-atk" checkpoint_81

checkpoint_82() {
    emerge media-libs/fontconfig
    rm -rf /var/tmp/portage/media-libs/fontconfig-*
    eclean-dist -d
}
run_checkpoint 82 "emerge media-libs/fontconfig" checkpoint_82

checkpoint_83() {
    emerge media-fonts/dejavu
    rm -rf /var/tmp/portage/media-fonts/dejavu-*
    eclean-dist -d
}
run_checkpoint 83 "emerge media-fonts/dejavu" checkpoint_83

checkpoint_86() {
    emerge dev-lang/python
    rm -rf /var/tmp/portage/dev-lang/python-*
    eclean-dist -d
}
run_checkpoint 86 "emerge dev-lang/python" checkpoint_86

checkpoint_88() {
    emerge dev-libs/libdbusmenu
    rm -rf /var/tmp/portage/dev-libs/libdbusmenu-*
    eclean-dist -d
}
run_checkpoint 88 "emerge dev-libs/libdbusmenu" checkpoint_88

checkpoint_92() {
    emerge dev-build/cmake
    rm -rf /var/tmp/portage/dev-build/cmake-*
    eclean-dist -d
}
run_checkpoint 92 "emerge dev-build/cmake" checkpoint_92

checkpoint_93() {
    emerge xfce-base/exo
    rm -rf /var/tmp/portage/xfce-base/exo-*
    eclean-dist -d
}
run_checkpoint 93 "emerge xfce-base/exo" checkpoint_93

checkpoint_94() {
    emerge app-admin/exo
    rm -rf /var/tmp/portage/app-admin/exo-*
    eclean-dist -d
}
run_checkpoint 94 "emerge app-admin/exo" checkpoint_94

checkpoint_95() {
    emerge app-arch/tar
    rm -rf /var/tmp/portage/app-arch/tar-*
    eclean-dist -d
}
run_checkpoint 95 "emerge app-arch/tar" checkpoint_95

checkpoint_96() {
    emerge app-arch/xz-utils
    rm -rf /var/tmp/portage/app-arch/xz-utils-*
    eclean-dist -d
}
run_checkpoint 96 "emerge app-arch/xz-utils" checkpoint_96

checkpoint_97() {
    emerge net-libs/gnutls
    rm -rf /var/tmp/portage/net-libs/gnutls-*
    eclean-dist -d
}
run_checkpoint 97 "emerge net-libs/gnutls" checkpoint_97

checkpoint_98() {
    emerge net-libs/glib-networking
    rm -rf /var/tmp/portage/net-libs/glib-networking-*
    eclean-dist -d
}
run_checkpoint 98 "emerge net-libs/glib-networking" checkpoint_98

checkpoint_99() {
    emerge sys-libs/libseccomp
    rm -rf /var/tmp/portage/sys-libs/libseccomp-*
    eclean-dist -d
}
run_checkpoint 99 "emerge sys-libs/libseccomp" checkpoint_99

checkpoint_100() {
    emerge app-eselect/eselect-repository
    rm -rf /var/tmp/portage/app-eselect/eselect-repository-*
    eclean-dist -d
}
run_checkpoint 100 "emerge app-eselect/eselect-repository" checkpoint_100

checkpoint_101() {
    emerge dev-libs/appstream-glib
    rm -rf /var/tmp/portage/dev-libs/appstream-glib-*
    eclean-dist -d
}
run_checkpoint 101 "emerge dev-libs/appstream-glib" checkpoint_101

checkpoint_102() {
    emerge app-crypt/gpgme
    rm -rf /var/tmp/portage/app-crypt/gpgme-*
    eclean-dist -d
}
run_checkpoint 102 "emerge app-crypt/gpgme" checkpoint_102

checkpoint_103() {
    emerge dev-util/ostree
    rm -rf /var/tmp/portage/dev-util/ostree-*
    eclean-dist -d
}
run_checkpoint 103 "emerge dev-util/ostree" checkpoint_103

checkpoint_104() {
    emerge sys-apps/xdg-dbus-proxy
    rm -rf /var/tmp/portage/sys-apps/xdg-dbus-proxy-*
    eclean-dist -d
}
run_checkpoint 104 "emerge sys-apps/xdg-dbus-proxy" checkpoint_104

checkpoint_106() {
    emerge sys-fs/fuse
    rm -rf /var/tmp/portage/sys-fs/fuse-*
    eclean-dist -d
}
run_checkpoint 106 "emerge sys-fs/fuse" checkpoint_106

checkpoint_107() {
    emerge dev-python/pygobject
    rm -rf /var/tmp/portage/dev-python/pygobject-*
    eclean-dist -d
}
run_checkpoint 107 "emerge dev-python/pygobject" checkpoint_107

checkpoint_108() {
    emerge gnome-base/dconf
    rm -rf /var/tmp/portage/gnome-base/dconf-*
    eclean-dist -d
}
run_checkpoint 108 "emerge gnome-base/dconf" checkpoint_108

checkpoint_113() {
    emerge dev-python/pillow
    rm -rf /var/tmp/portage/dev-python/pillow-*
    eclean-dist -d
}
run_checkpoint 113 "emerge dev-python/pillow" checkpoint_113

checkpoint_114() {
    emerge media-gfx/chafa
    rm -rf /var/tmp/portage/media-gfx/chafa-*
    eclean-dist -d
}
run_checkpoint 114 "emerge media-gfx/chafa" checkpoint_114

checkpoint_115() {
    emerge app-text/doxygen
    rm -rf /var/tmp/portage/app-text/doxygen-*
    eclean-dist -d
}
run_checkpoint 115 "emerge app-text/doxygen" checkpoint_115

checkpoint_116() {
    emerge -1 =llvm-core/libclc-20*
    emerge gui-libs/egl-gbm
    rm -rf /var/tmp/portage/gui-libs/egl-gbm-*
    eclean-dist -d
}
run_checkpoint 116 "emerge gui-libs/egl-gbm" checkpoint_116

checkpoint_117() {
    cd /tmp
    git clone https://chromium.googlesource.com/chromiumos/platform2
    cd platform2/vm_tools/sommelier
    meson setup build
    ninja -C build
    ninja -C build install
}
run_checkpoint 117 "Build Sommelier" checkpoint_117

checkpoint_118() {
    emerge sys-apps/flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    rm -rf /var/tmp/portage/sys-apps/flatpak-*
    eclean-dist -d
}
run_checkpoint 118 "emerge sys-apps/flatpak" checkpoint_118

checkpoint_119() {
    emerge app-admin/sudo
    rm -rf /var/tmp/portage/app-admin/sudo-*
    eclean-dist -d
}
run_checkpoint 119 "emerge app-admin/sudo" checkpoint_119

checkpoint_120() {
    echo "media-plugins/alsa-plugins pulseaudio" >> /etc/portage/package.use/firefox-bin
    emerge --autounmask-write firefox-bin
    rm -rf /var/tmp/portage/www-client/firefox-bin-*
    eclean-dist -d
}
run_checkpoint 120 "emerge firefox-bin" checkpoint_120

checkpoint_121() {
    emerge net-misc/yt-dlp
    emerge media-libs/libopus
    emerge media-video/vlc
    rm -rf /var/tmp/portage/net-misc/yt-dlp-*
    rm -rf /var/tmp/portage/media-libs/libopus-*
    rm -rf /var/tmp/portage/media-video/vlc-*
    eclean-dist -d
}
run_checkpoint 121 "emerge yt-dlp + vlc" checkpoint_121

echo "Chard Root is ready (soon tm)${RESET}"
show_progress

case "$1" in
    reset) reset ;;
    *) run_checkpoint ;;
esac
