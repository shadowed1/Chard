#!/bin/bash
START_TIME=$(date +%s)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
MAX_RETRIES=10
RETRY_DELAY=30


echo "${RESET}${GREEN}"
echo
echo
echo
echo
echo
echo
echo "                                                             AA"
echo "                                                            A${RESET}${RED}::${RESET}${GREEN}A"
echo "        CCCCCCCCCCCCCHHHHHHHHH     HHHHHHHHH               A${RESET}${RED}::::${RESET}${GREEN}A               RRRRRRRRRRRRRRRRR   DDDDDDDDDDDDD" 
echo "     CCC${RESET}${YELLOW}::::::::::::${RESET}${GREEN}CH${RESET}${YELLOW}:::::::${RESET}${GREEN}H     H${RESET}${YELLOW}:::::::${RESET}${GREEN}H              A${RESET}${RED}::::::${RESET}${GREEN}A              R${RESET}${YELLOW}::::::::::::::::${RESET}${GREEN}R  D${RESET}${YELLOW}::::::::::::${RESET}${GREEN}DDD"  
echo "   CC${RESET}${YELLOW}:::::::::::::::${RESET}${GREEN}CH${RESET}${YELLOW}:::::::${RESET}${GREEN}H     H${RESET}${YELLOW}:::::::${RESET}${GREEN}H             A${RESET}${RED}::::::::${RESET}${GREEN}A             R${RESET}${YELLOW}::::::${RESET}${GREEN}RRRRRR${RESET}${YELLOW}:::::${RESET}${GREEN}R D${RESET}${YELLOW}:::::::::::::::${RESET}${GREEN}DD"  
echo "  C${RESET}${YELLOW}:::::${RESET}${GREEN}CCCCCCCC${RESET}${YELLOW}::::${RESET}${GREEN}CHH${RESET}${YELLOW}::::::${RESET}${GREEN}H     H${RESET}${YELLOW}::::::${RESET}${GREEN}HH            A${RESET}${RED}::::::::::${RESET}${GREEN}A            RR${RESET}${YELLOW}:::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}RDDD${RESET}${YELLOW}:::::${RESET}${GREEN}DDDDD${RESET}${YELLOW}:::::${RESET}${GREEN}D"  
echo " C${RESET}${YELLOW}:::::${RESET}${GREEN}C       CCCCCC  H${RESET}${YELLOW}:::::${RESET}${GREEN}H     H${RESET}${YELLOW}:::::${RESET}${GREEN}H             A${RESET}${RED}::::::::::::${RESET}${GREEN}A             R${RESET}${YELLOW}::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}R  D${RESET}${YELLOW}:::::${RESET}${GREEN}D     D${RESET}${YELLOW}:::::${RESET}${GREEN}D"  
echo "C${RESET}${YELLOW}:::::${RESET}${GREEN}C                H${RESET}${YELLOW}:::::${RESET}${GREEN}H     H${RESET}${YELLOW}:::::${RESET}${GREEN}H            A${RESET}${RED}::::::::::::::${RESET}${GREEN}A            R${RESET}${YELLOW}::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}R  D${RESET}${YELLOW}:::::${RESET}${GREEN}D     D${RESET}${YELLOW}:::::${RESET}${GREEN}D"
echo "C${RESET}${YELLOW}:::::${RESET}${GREEN}C                H${RESET}${YELLOW}::::::${RESET}${GREEN}HHHHH${RESET}${YELLOW}::::::${RESET}${GREEN}H           A${RESET}${RED}::            ::${RESET}${GREEN}A           R${RESET}${YELLOW}::::${RESET}${GREEN}RRRRRR${RESET}${YELLOW}:::::${RESET}${GREEN}R   D${RESET}${YELLOW}:::::${RESET}${GREEN}D     D${RESET}${YELLOW}:::::${RESET}${GREEN}D"  
echo "C${RESET}${YELLOW}:::::${RESET}${GREEN}C                H${RESET}${YELLOW}:::::::::::::::::${RESET}${GREEN}H          A${RESET}${RED}:::            :::${RESET}${GREEN}A          R${RESET}${YELLOW}:::::::::::::${RESET}${GREEN}RR    D${RESET}${YELLOW}:::::${RESET}${GREEN}D     D${RESET}${YELLOW}:::::${RESET}${GREEN}D"
echo "C${RESET}${YELLOW}:::::${RESET}${GREEN}C                H${RESET}${YELLOW}:::::::::::::::::${RESET}${GREEN}H         A${RESET}${RED}::::            ::::${RESET}${GREEN}A         R${RESET}${YELLOW}::::${RESET}${GREEN}RRRRRR${RESET}${YELLOW}:::::${RESET}${GREEN}R   D${RESET}${YELLOW}:::::${RESET}${GREEN}D     D${RESET}${YELLOW}:::::${RESET}${GREEN}D"    
echo "C${RESET}${YELLOW}:::::${RESET}${GREEN}C                H${RESET}${YELLOW}::::::${RESET}${GREEN}HHHHH${RESET}${YELLOW}::::::${RESET}${GREEN}H        A${RESET}${RED}:::::            :::::${RESET}${GREEN}A        R${RESET}${YELLOW}::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}R  D${RESET}${YELLOW}:::::${RESET}${GREEN}D     D${RESET}${YELLOW}:::::${RESET}${GREEN}D"    
echo "C${RESET}${YELLOW}:::::${RESET}${GREEN}C                H${RESET}${YELLOW}:::::${RESET}${GREEN}H     H${RESET}${YELLOW}:::::${RESET}${GREEN}H       A${RESET}${RED}::::::            ::::::${RESET}${GREEN}A       R${RESET}${YELLOW}::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}R  D${RESET}${YELLOW}:::::${RESET}${GREEN}D     D${RESET}${YELLOW}:::::${RESET}${GREEN}D"   
echo " C${RESET}${YELLOW}:::::${RESET}${GREEN}C       CCCCCC  H${RESET}${YELLOW}:::::${RESET}${GREEN}H     H${RESET}${YELLOW}:::::${RESET}${GREEN}H      A${RESET}${RED}:::::                :::::${RESET}${GREEN}A      R${RESET}${YELLOW}::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}R  D${RESET}${YELLOW}:::::${RESET}${GREEN}D     D${RESET}${YELLOW}:::::${RESET}${GREEN}D"  
echo "  C${RESET}${YELLOW}:::::${RESET}${GREEN}CCCCCCCC${RESET}${YELLOW}::::${RESET}${GREEN}CHH${RESET}${YELLOW}::::::${RESET}${GREEN}H     H${RESET}${YELLOW}::::::${RESET}${GREEN}HH   A${RESET}${RED}:::::::::          :::::::::${RESET}${GREEN}A   RR${RESET}${YELLOW}:::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}RDDD${RESET}${YELLOW}:::::${RESET}${GREEN}DDDDD${RESET}${YELLOW}:::::${RESET}${GREEN}D" 
echo "   CC${RESET}${YELLOW}:::::::::::::::${RESET}${GREEN}CH${RESET}${YELLOW}:::::::${RESET}${GREEN}H     H${RESET}${YELLOW}:::::::${RESET}${GREEN}H  A${RESET}${RED}:::::::::            :::::::::${RESET}${GREEN}A  R${RESET}${YELLOW}::::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}RD${RESET}${YELLOW}:::::::::::::::${RESET}${GREEN}DD"  
echo "     CCC${RESET}${YELLOW}::::::::::::${RESET}${GREEN}CH${RESET}${YELLOW}:::::::${RESET}${GREEN}H     H${RESET}${YELLOW}:::::::${RESET}${GREEN}H A${RESET}${RED}::::::::                ::::::::${RESET}${GREEN}A R${RESET}${YELLOW}::::::${RESET}${GREEN}R     R${RESET}${YELLOW}:::::${RESET}${GREEN}RD${RESET}${YELLOW}::::::::::::${RESET}${GREEN}DDD"  
echo "        CCCCCCCCCCCCCHHHHHHHHH     HHHHHHHHHA${BOLD}======                      ======${RESET}${GREEN}ARRRRRRRR     RRRRRRRDDDDDDDDDDDDD"   
echo "                                           ${BOLD}A====                            ====A"
echo "                                          A====                              ====A"
echo "${RESET}"

echo               
echo "${RESET}"
echo "${RED}- Chard Installer can take ${BOLD}5-20 minutes${RESET}${RED} depending on your CPU and storage speed. Requires ~8 GB of space. Supports ${BOLD}x86_64${RESET}${RED} and ${BOLD}ARM64${RESET}${RED}! ${RESET}"
echo "${RED}- Chard will be installed in ${RESET}${RED}${BOLD}${CHARD_ROOT}${RESET}${RED} and will not affect ChromeOS system commands.${RESET}"
echo
echo "${YELLOW}- It is ${BOLD}semi-sandboxed within itself${RESET}${YELLOW}, but can rely on Host libraries. Automatically updates itself build and compile with.${RESET}"
echo "${YELLOW}- Chard has ${BOLD}not${RESET}${YELLOW} been tested with Brunch Toolchain or Chromebrew - this project uses a different implementation. It does ${BOLD}NOT${RESET}${YELLOW} require dev_install.${RESET}"
echo
echo "${GREEN}- Does not require altering current state of /usr/local/ during Install and Uninstall.${RESET}"
echo "${GREEN}- Chard is currently in early development. ${BOLD}Bugs will exist${RESET}${GREEN}, so please have a ${BOLD}USB backup${RESET}${GREEN} in case of serious mistakes.${RESET}"
echo

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

   read -rp "${GREEN}${BOLD}Install Chard? (Y/n): ${RESET}" response
response=${response:-Y}

case "$response" in
    y|Y|yes|YES|Yes)
        echo
        echo
        ;;
    *)
        echo "${RED}[EXIT]${RESET}"
        exit 1
        sleep 1
        exit 0
        ;;
esac
    unset LD_PRELOAD

DEFAULT_CHARD_ROOT="/usr/local/chard"

if [ -f "$DEFAULT_CHARD_ROOT/.install_path" ]; then
    CHARD_ROOT=$(sudo cat "$DEFAULT_CHARD_ROOT/.install_path")
    echo -e "${CYAN}Found existing Install Path: ${BOLD}$CHARD_ROOT${RESET}"
else
    CHARD_ROOT="$DEFAULT_CHARD_ROOT"
fi

while true; do
    read -rp "${GREEN}Enter desired Install Path - ${RESET}${GREEN}${BOLD}leave blank for default: $CHARD_ROOT: ${RESET}" choice
    if [ -n "$choice" ]; then
        CHARD_ROOT="${choice}"
    fi
    CHARD_ROOT="${CHARD_ROOT%/}"

    echo -e "\n${CYAN}You entered: ${BOLD}$CHARD_ROOT${RESET}"
    echo
    read -srp "${BLUE}${BOLD}Confirm this install path? Enter key counts as yes! ${RESET}${BOLD} (Y/n): ${RESET}" confirm
    echo ""
    case "$confirm" in
        [Yy]* | "")
            sudo mkdir -p "$CHARD_ROOT"
            break
            ;;
        [Nn]*)
            echo -e "${BLUE}Cancelled.${RESET}\n"
            exit 0
            ;;
        *)
            echo -e "${RED}Please answer Y/n.${RESET}"
            ;;
    esac
done

echo "$CHARD_ROOT" | sudo tee "$CHARD_ROOT/.install_path" >/dev/null
    
CHARD_ROOT="${CHARD_ROOT%/}"
CHARD_RC="$CHARD_ROOT/.chardrc"
BUILD_DIR="$CHARD_ROOT/var/tmp/build"
LOG_FILE="$CHARD_ROOT/chardbuild.log"

echo "${RED}Chard Installs to ${CHARD_ROOT}${RESET}${YELLOW} - Install will eventually chroot into chard. ${BOLD}This means / will be $CHARD_ROOT/ in reality.${RESET}"
echo
echo "${GREEN}[+] Creating ${RESET}${RED}Chard Root${RESET}"

echo "${RESET}${RED}[*] Unmounting active bind mounts...${RESET}"
sudo umount -l "$CHARD_ROOT/dev/shm"        2>/dev/null || true
sudo umount -l "$CHARD_ROOT/dev"            2>/dev/null || true
sudo umount -l "$CHARD_ROOT/sys"            2>/dev/null || true
sudo umount -l "$CHARD_ROOT/proc"           2>/dev/null || true
sudo umount -l "$CHARD_ROOT/etc/ssl"        2>/dev/null || true
sudo umount -l "$CHARD_ROOT/run/dbus"       2>/dev/null || true

echo "${RED}[*] Removing $CHARD_ROOT...${RESET}"
sudo rm -rf "$CHARD_ROOT"
CURRENT_SHELL=$(basename "$SHELL")
CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
DEFAULT_BASHRC="$HOME/.bashrc"
TARGET_FILE=""

if [ -f "$CHROMEOS_BASHRC" ]; then
    TARGET_FILE="$CHROMEOS_BASHRC"
else
    TARGET_FILE="$DEFAULT_BASHRC"
    [ -f "$TARGET_FILE" ] || touch "$TARGET_FILE"
fi

sed -i '/^# <<< CHARD ENV MARKER <<</,/^# <<< END CHARD ENV MARKER <<</d' "$TARGET_FILE"

if ! grep -Fxq "# <<< CHARD ENV MARKER <<<" "$TARGET_FILE"; then
    {
        echo "# <<< CHARD ENV MARKER <<<"
        echo "source \"$CHARD_RC\""
        echo "# <<< END CHARD ENV MARKER <<<"
    } >> "$TARGET_FILE"
fi

echo "${RESET}${RED}Detected .bashrc: ${BOLD}${TARGET_FILE}${RESET}${RED}"

CHARD_HOME="$(dirname "$TARGET_FILE")"
CHARD_HOME="${CHARD_HOME#/}"
sudo mkdir -p "$CHARD_ROOT/$CHARD_HOME"

ARCH=$(uname -m)
case "$ARCH" in
    x86_64) CHOST=x86_64-pc-linux-gnu ;;
    aarch64) CHOST=aarch64-unknown-linux-gnu ;;
    *) echo "Unsupported Architecture: $ARCH" ;;
esac

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        GENTOO_ARCH="amd64"
        CHOST="x86_64-pc-linux-gnu"
        sudo mkdir -p "$CHARD_ROOT/usr/bin"
        sudo chmod -R +x "$CHARD_ROOT/usr/bin"
        ;;
    aarch64|arm64)
        GENTOO_ARCH="arm64"
        CHOST="aarch64-unknown-linux-gnu"
        sudo mkdir -p "$CHARD_ROOT/usr/bin"
        sudo chmod -R +x "$CHARD_ROOT/usr/bin"
        ;;
    *)
        echo "${RED}[!] Unsupported architecture: $ARCH${RESET}"
        exit 1
        ;;
esac

sudo mkdir -p "$CHARD_ROOT/var/tmp"
PORTAGE_DIR="$CHARD_ROOT/usr/portage"
SNAPSHOT_URL="https://gentoo.osuosl.org/snapshots/portage-latest.tar.xz"
TMP_TAR="$CHARD_ROOT/var/tmp/portage-latest.tar.xz"
echo "${RED}[+] Downloading Portage tree snapshot"
sudo curl -L --progress-bar -o "$TMP_TAR" "$SNAPSHOT_URL"
sudo mkdir -p "$PORTAGE_DIR"
sudo tar -xJf "$TMP_TAR" -C "$PORTAGE_DIR" --strip-components=1 \
    --checkpoint=.100 --checkpoint-action=echo="   extracted %u files"
sudo rm -f "$TMP_TAR"

STAGE3_TXT="https://gentoo.osuosl.org/releases/$GENTOO_ARCH/autobuilds/current-stage3-$GENTOO_ARCH-llvm-systemd/latest-stage3-$GENTOO_ARCH-llvm-systemd.txt"

STAGE3_FILENAME=$(curl -fsSL "$STAGE3_TXT" | grep -Eo 'stage3-.*\.tar\.xz' | head -n1)
STAGE3_URL=$(dirname "$STAGE3_TXT")"/$STAGE3_FILENAME"

STAGE3_FILE=$(basename "$STAGE3_URL")
TMP_STAGE3="$CHARD_ROOT/var/tmp/$STAGE3_FILE"

echo "${RESET}${YELLOW}[+] Downloading latest Stage3 tarball: $STAGE3_FILENAME"
sudo curl -L --progress-bar -o "$TMP_STAGE3" "$STAGE3_URL"

echo "${RESET}${YELLOW}[+] Extracting Stage3 tarball"
sudo tar -xJf "$TMP_STAGE3" -C "$CHARD_ROOT" --strip-components=1 \
    --checkpoint=.100 --checkpoint-action=echo="   extracted %u files"

sudo rm -f "$TMP_STAGE3"

PROFILE_DIR="$PORTAGE_DIR/profiles/default/linux/$GENTOO_ARCH/23.0/desktop"
MAKE_PROFILE="$CHARD_ROOT/etc/portage/make.profile"
sudo mkdir -p "$(dirname "$MAKE_PROFILE")"
if [ -d "$PROFILE_DIR" ]; then
    REL_TARGET=$(realpath --relative-to="$CHARD_ROOT/etc/portage" "$PROFILE_DIR")
    sudo ln -sfn "$REL_TARGET" "$MAKE_PROFILE"
    echo "${RESET}${GREEN}[+] Portage profile set to $REL_TARGET"
else
    echo "${YELLOW}[!] Desktop profile not found for $GENTOO_ARCH at $PROFILE_DIR"
fi

sudo curl -fsSL https://raw.githubusercontent.com/shadowed1/Chard/main/chard -o "$CHARD_ROOT/bin/chard"
sudo chmod +x "$CHARD_ROOT/bin/chard"

export PYTHON="$CHARD_ROOT/bin/python3"
export CC="$CHARD_ROOT/usr/bin/gcc"
export CXX="$CHARD_ROOT/usr/bin/g++"
export AR="$CHARD_ROOT/usr/bin/gcc-ar"
export RANLIB="$CHARD_ROOT/usr/bin/gcc-ranlib"
export PATH="$PATH:$CHARD_ROOT/usr/bin"
export CXXFLAGS="$CFLAGS"
export AWK=/usr/bin/mawk
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}/usr/lib64"
export MAKEFLAGS="-j$(nproc)"
export INSTALL_ROOT="$CHARD_ROOT"
export ACLOCAL_PATH="$CHARD_ROOT/usr/share/aclocal"
export PYTHONPATH="$CHARD_ROOT/usr/lib/python3.13/site-packages:$PYTHONPATH"
export PKG_CONFIG_PATH="$CHARD_ROOT/usr/lib64/pkgconfig:$CHARD_ROOT/usr/lib/pkgconfig"
export CFLAGS="-I$CHARD_ROOT/usr/include $CFLAGS"
export LDFLAGS="-L$CHARD_ROOT/usr/lib64 -L$CHARD_ROOT/usr/lib $LDFLAGS"
export GIT_TEMPLATE_DIR="$CHARD_ROOT/usr/share/git-core/templates"

KERNEL_INDEX=$(curl -fsSL https://cdn.kernel.org/pub/linux/kernel/v6.x/ \
    | grep -o 'href="linux-[0-9]\+\.[0-9]\+\.[0-9]\+\.tar\.xz"' \
    | sed 's/href="linux-\(.*\)\.tar\.xz"/\1/' )

KERNEL_VER=$(echo "$KERNEL_INDEX" | sort -V | tail -n2 | head -n1)

KERNEL_TAR="linux-$KERNEL_VER.tar.xz"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/$KERNEL_TAR"
KERNEL_BUILD="$BUILD_DIR/linux-$KERNEL_VER"

echo "Fetching kernel version: $KERNEL_VER"
echo "URL: $KERNEL_URL"

sudo mkdir -p "$BUILD_DIR"

if [ ! -f "$BUILD_DIR/$KERNEL_TAR" ]; then
    echo "${RESET}${GREEN}[+] Fetching $KERNEL_TAR..."
    sudo curl -L --progress-bar -o "$BUILD_DIR/$KERNEL_TAR" "$KERNEL_URL"
else
    echo "${RESET}${RED}[!] Kernel tarball already exists, skipping download."
fi


sudo rm -rf "$KERNEL_BUILD"z
sudo tar -xf "$BUILD_DIR/$KERNEL_TAR" -C "$BUILD_DIR" \
    --checkpoint=.500 --checkpoint-action=echo="   extracted %u files"

echo "${RESET}${CYAN}[+] Installing Linux headers into Chard Root..."

sudo chroot "$CHARD_ROOT" /bin/bash -c "
cd /var/tmp/build/linux-$KERNEL_VER

HOST_ARCH=\$(uname -m)
case \"\$HOST_ARCH\" in
    x86_64) KERNEL_ARCH=x86_64 ;;
    aarch64) KERNEL_ARCH=arm64 ;;
    *) echo \"Unsupported Architecture: \$HOST_ARCH\"; exit 1 ;;
esac

make mrproper
make defconfig

rm -rf /usr/src/linux
cp -a . /usr/src/linux

make INSTALL_HDR_PATH=/usr headers_install

cp .config /usr/src/linux/.config
"

echo "${RESET}${BLUE}[+] Linux headers and sources installed to $CHARD_ROOT/usr/src/linux"
sudo rm -rf "$KERNEL_BUILD"

CONFIG_FILE="$CHARD_ROOT/usr/src/linux/.config"
OPTIONS=(
    "CONFIG_CGROUP_BPF"
    "CONFIG_FANOTIFY"
    "CONFIG_USER_NS"
    "CONFIG_CRYPTO_USER_API_HASH"
    "CONFIG_INPUT_MOUSEDEV"
)

for opt in "${OPTIONS[@]}"; do
    sudo sed -i -E "s/^# $opt is not set/$opt=y/" "$CONFIG_FILE"
done

for opt in "${OPTIONS[@]}"; do
    if ! sudo grep -q "^$opt=" "$CONFIG_FILE"; then
        echo "$opt=y" | sudo tee -a "$CONFIG_FILE" >/dev/null
    fi
done

sudo grep -E "CONFIG_CGROUP_BPF|CONFIG_FANOTIFY|CONFIG_USER_NS|CONFIG_CRYPTO_USER_API_HASH|CONFIG_INPUT_MOUSEDEV" "$CHARD_ROOT/usr/src/linux/.config" | wc -l

sudo mkdir -p "$CHARD_ROOT/etc/portage" \
              "$CHARD_ROOT/etc/sandbox.d" \
              "$CHARD_ROOT/etc/ssl" \
              "$CHARD_ROOT/usr/bin" \
              "$CHARD_ROOT/usr/lib" \
              "$CHARD_ROOT/usr/lib64" \
              "$CHARD_ROOT/usr/include" \
              "$CHARD_ROOT/usr/share" \
              "$CHARD_ROOT/usr/local/bin" \
              "$CHARD_ROOT/usr/local/lib" \
              "$CHARD_ROOT/usr/local/include" \
              "$CHARD_ROOT/var/tmp/build" \
              "$CHARD_ROOT/var/cache/distfiles" \
              "$CHARD_ROOT/var/cache/packages" \
              "$CHARD_ROOT/var/log" \
              "$CHARD_ROOT/var/run" \
              "$CHARD_ROOT/dev/shm" \
              "$CHARD_ROOT/dev/pts" \
              "$CHARD_ROOT/proc" \
              "$CHARD_ROOT/sys" \
              "$CHARD_ROOT/tmp" \
              "$CHARD_ROOT/run" \
              "$CHARD_ROOT/$CHARD_HOME/.cargo" \
              "$CHARD_ROOT/$CHARD_HOME/.rustup" \
              "$CHARD_ROOT/$CHARD_HOME/.local/share" \
              "$CHARD_ROOT/$CHARD_HOME/Desktop" \
              "$CHARD_ROOT/mnt"

sudo mkdir -p "$CHARD_ROOT/usr/local/src/gtest-1.16.0"
sudo mkdir -p "$(dirname "$LOG_FILE")"
sudo mkdir -p "$CHARD_ROOT/etc/portage/repos.conf"

sudo rm -f \
    "$CHARD_ROOT/.chardrc" \
    "$CHARD_ROOT/.chard.env" \
    "$CHARD_ROOT/.chard.logic" \
    "$CHARD_ROOT/bin/SMRT" \
    "$CHARD_ROOT/bin/chard"

sudo mkdir -p "$CHARD_ROOT/bin" "$CHARD_ROOT/usr/bin" "$CHARD_ROOT/usr/lib" "$CHARD_ROOT/usr/lib64"


echo "${BLUE}[*] Downloading Chard components...${RESET}"
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/.chardrc"     -o "$CHARD_ROOT/.chardrc"
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/.chard.env"   -o "$CHARD_ROOT/.chard.env"
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/.chard.logic" -o "$CHARD_ROOT/.chard.logic"
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/SMRT.sh"      -o "$CHARD_ROOT/bin/SMRT"
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/chard"        -o "$CHARD_ROOT/bin/chard"
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/.bashrc"      -o "$CHARD_ROOT/$CHARD_HOME/.bashrc"
sudo curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/.rootrc"      -o "$CHARD_ROOT/bin/.rootrc"

sudo chmod +x "$CHARD_ROOT/bin/.rootrc"

for file in \
    "$CHARD_ROOT/.chardrc" \
    "$CHARD_ROOT/.chard.env" \
    "$CHARD_ROOT/.chard.logic" \
    "$CHARD_ROOT/bin/SMRT" \
    "$CHARD_ROOT/bin/chard"; do

    if [ -f "$file" ]; then
        if sudo grep -q '^# <<< CHARD_ROOT_MARKER >>>' "$file"; then
            sudo sed -i -E "/^# <<< CHARD_ROOT_MARKER >>>/,/^# <<< END_CHARD_ROOT_MARKER >>>/c\
# <<< CHARD_ROOT_MARKER >>>\nCHARD_ROOT=\"$CHARD_ROOT\"\n# <<< END_CHARD_ROOT_MARKER >>>" "$file"
        else
            sudo sed -i "1i # <<< CHARD_ROOT_MARKER >>>\nCHARD_ROOT=\"$CHARD_ROOT\"\n# <<< END_CHARD_ROOT_MARKER >>>\n" "$file"
        fi

        sudo chmod +x "$file"
    else
        echo "${RED}[!] Missing: $file — download failed?${RESET}"
    fi
done


for target in \
    "$CHARD_ROOT/$CHARD_HOME/.bashrc" \
    "$CHARD_ROOT/bin/.rootrc" \
    "$CHARD_ROOT/.chardrc" \
    "$CHARD_ROOT/bin/chard"; do

    if [ -f "$target" ]; then
        if sudo grep -q '^# <<< ROOT_MARKER >>>' "$target"; then
            sudo sed -i -E "/^# <<< ROOT_MARKER >>>/,/^# <<< END_ROOT_MARKER >>>/c\
    # <<< ROOT_MARKER >>>\nCHARD_HOME=\"/$CHARD_HOME\"\n# <<< END_ROOT_MARKER >>>" "$target"
        else
            {
                echo ""
                echo "# <<< ROOT_MARKER >>>"
                echo "CHARD_HOME=\"/$CHARD_HOME\""
                echo "# <<< END_ROOT_MARKER >>>"
            } | sudo tee -a "$target" >/dev/null
        fi
    else
        echo "${RED}[!] Missing: $target — cannot patch ROOT_MARKER${RESET}"
    fi
done

sudo mv "$CHARD_ROOT/bin/.rootrc" "$CHARD_ROOT/.bashrc"


SMRT_ENV_HOST="/usr/local/bin/.smrt_env.sh"
SMRT_ENV_CHARD="$CHARD_ROOT/bin/.smrt_env.sh"
sudo touch "$SMRT_ENV_HOST" "$SMRT_ENV_CHARD"
sudo chown -R 1000:1000 "$SMRT_ENV_HOST" "$SMRT_ENV_CHARD"

CURRENT_SHELL=$(basename "$SHELL")

CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
DEFAULT_BASHRC="$HOME/.bashrc"
TARGET_FILE=""

if [ -f "$CHROMEOS_BASHRC" ]; then
    TARGET_FILE="$CHROMEOS_BASHRC"
else
    TARGET_FILE="$DEFAULT_BASHRC"
    [ -f "$TARGET_FILE" ] || touch "$TARGET_FILE"
fi

add_chard_marker() {
    local FILE="$1"

    sed -i '/^# <<< CHARD ENV MARKER <<</,/^# <<< END CHARD ENV MARKER <<</d' "$FILE"

    if ! grep -Fxq "# <<< CHARD ENV MARKER <<<" "$FILE"; then
        {
            echo "# <<< CHARD ENV MARKER <<<"
            echo "source \"$CHARD_RC\""
            echo "# <<< END CHARD ENV MARKER <<<"
        } >> "$FILE"
        echo "${BLUE}[+] Chard sourced to $FILE"
    else
        echo "${YELLOW}[!] Chard already sourced in $FILE"
    fi
}

add_chard_marker "$TARGET_FILE"

sudo mkdir -p "$CHARD_ROOT/usr/local/src/gtest-1.16.0"
sudo mkdir -p "$(dirname "$LOG_FILE")"
sudo mkdir -p "$CHARD_ROOT/etc/portage/repos.conf"
sudo mkdir -p "$CHARD_ROOT/var/db/repos/gentoo/profiles"
sudo mkdir -p "$CHARD_ROOT/etc/portage/make.profile"
sudo mkdir -p "$CHARD_ROOT/run/user/0"
sudo chmod 700 "$CHARD_ROOT/run/user/0"
sudo mkdir -p "$CHARD_ROOT/run/dbus"
exec > >(sudo tee -a "$LOG_FILE") 2>&1
sudo mkdir -p "$CHARD_ROOT/etc/portage/repos.conf"
sudo mkdir -p "$CHARD_ROOT/etc/portage/package.use"
#sudo mkdir -p "$CHARD_ROOT/tmp/docbook-4.3"
#cd "$CHARD_ROOT/tmp/docbook-4.3"
#sudo curl -L --progress-bar -o docbook-xml-4.3.zip https://www.oasis-open.org/docbook/xml/4.3/docbook-xml-4.3.zip
#sudo mkdir -p "$CHARD_ROOT/usr/share/xml/docbook/4.3"
#sudo mkdir -p "$CHARD_ROOT/etc/xml"
#sudo bsdtar -xf docbook-xml-4.3.zip -C "$CHARD_ROOT/usr/share/xml/docbook/4.3"
#sudo chmod -R 755 "$CHARD_ROOT/usr/share/xml/docbook/4.3"
#sudo touch "$CHARD_ROOT/etc/xml/catalog"


cleanup_chroot() {
    echo "${RED}Unmounting Chard${RESET}"
    sudo umount -l "$CHARD_ROOT/dev/shm"  2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/dev"      2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/sys"      2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/proc"     2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/etc/ssl"  2>/dev/null || true
    sudo umount -l "$CHARD_ROOT/run/dbus" 2>/dev/null || true
    sudo cp "$CHARD_ROOT/chardbuild.log" ~/
    echo "${YELLOW}Copied chardbuild.log to $HOME ${RESET}"
    
}

trap cleanup_chroot EXIT INT TERM

for pkg in "${PACKAGES[@]}"; do
    IFS="|" read -r NAME VERSION EXT URL DIR BUILDSYS <<< "$pkg"
    ARCHIVE="$NAME-$VERSION.$EXT"

    echo "${RESET}${GREEN}[+] Downloading $URL "

    attempt=1
    while true; do
        sudo curl -L --progress-bar -o "$BUILD_DIR/$ARCHIVE" "$URL" && break

        echo "${RED}[!] Download failed for $NAME-$VERSION (attempt $attempt/$MAX_RETRIES), retrying in $RETRY_DELAY seconds..."
        (( attempt++ ))

        if (( attempt > MAX_RETRIES )); then
            echo "${BOLD}${RED}[!] Failed to download $NAME-$VERSION after $MAX_RETRIES attempts. Aborting.${RESET}"
            exit 1
        fi
        sleep $RETRY_DELAY
    done

    echo "${RESET}${YELLOW}[+] Extracting $NAME-$VERSION"
    case "$EXT" in
        tar.gz|tgz)
            sudo tar -xzf "$BUILD_DIR/$ARCHIVE" -C "$BUILD_DIR" \
                --checkpoint=.500 --checkpoint-action=echo="   extracted %u files"
            ;;
        tar.xz)
            sudo tar -xJf "$BUILD_DIR/$ARCHIVE" -C "$BUILD_DIR" \
                --checkpoint=.500 --checkpoint-action=echo="   extracted %u files"
            ;;
        tar.bz2)
            sudo tar -xjf "$BUILD_DIR/$ARCHIVE" -C "$BUILD_DIR" \
                --checkpoint=.500 --checkpoint-action=echo="   extracted %u files"
            ;;
        zip)
            sudo bsdtar -xf "$BUILD_DIR/$ARCHIVE" -C "$BUILD_DIR"
            ;;
        *)
            echo "Unsupported Archive Format: $EXT"
    esac
done

sudo tee "$CHARD_ROOT/bin/emerge" > /dev/null <<'EOF'
#!/usr/bin/env python3
import os
import sys
import errno
import glob
import tokenize

CHROOT_PYTHON = "/usr/sbin/python"
if os.path.exists(CHROOT_PYTHON):
    python_exec = CHROOT_PYTHON
else:
    python_exec = sys.executable

major = sys.version_info.major
minor = sys.version_info.minor
dotver = f"{major}.{minor}"

PYEXEC_BASE = "/usr/lib/python-exec"
if not os.path.isdir(PYEXEC_BASE):
    PYEXEC_BASE = "/usr/lib/python-exec"

exec_dirs = sorted(glob.glob(os.path.join(PYEXEC_BASE, "python[0-9]*.[0-9]*")))
if not exec_dirs:
    exec_dirs = [os.path.join(PYEXEC_BASE, f"python{dotver}")]

python_dir = exec_dirs[-2] if len(exec_dirs) > 1 else exec_dirs[-1]

python_ver = python_dir.split('/')[-1].replace("python", "")
python_underscore = python_ver.replace(".", "_")

os.environ["PYEXEC_DIR"] = python_dir
os.environ["PYTHON_SINGLE_TARGET"] = f"python{python_underscore}"
os.environ["PYTHON_TARGETS"] = f"python{python_underscore}"

python_site = f"/usr/lib/python{python_ver}/site-packages"
if os.environ.get("PYTHONPATH"):
    os.environ["PYTHONPATH"] = f"{python_site}:{os.environ['PYTHONPATH']}"
else:
    os.environ["PYTHONPATH"] = python_site

target_name = os.path.basename(sys.argv[0])
target_path = os.path.join(python_dir, target_name)

data = None
while data is None:
    try:
        kwargs = {}
        with open(target_path, "rb") as f:
            kwargs["encoding"] = tokenize.detect_encoding(f.readline)[0]
        with open(target_path, "r", **kwargs) as f:
            data = f.read()
    except IOError as e:
        if e.errno == errno.EINTR:
            continue
        elif e.errno == errno.ENOENT:
            sys.stderr.write(f"{target_path}: Python implementation not supported: {python_exec}\n")
            sys.exit(127)
        else:
            raise

sys.argv[0] = target_path
new_globals = dict(globals())
new_globals["__file__"] = target_path

exec(data, new_globals)
EOF

sudo chmod +x "$CHARD_ROOT/bin/emerge"

sudo tee "$CHARD_ROOT/etc/portage/repos.conf/gentoo.conf" > /dev/null <<'EOF'
[gentoo]
location = /var/db/repos/gentoo
sync-type = rsync
sync-uri = rsync://rsync.gentoo.org/gentoo-portage
auto-sync = yes
EOF

sudo tee "$CHARD_ROOT/etc/profile.d/display.sh" > /dev/null <<'EOF'
export DISPLAY=:0
EOF
sudo chmod +x "$CHARD_ROOT/etc/profile.d/display.sh"

ARCH=$(uname -m)
MAKECONF_DIR="$CHARD_ROOT/etc/portage"
MAKECONF_FILE="$MAKECONF_DIR/make.conf"

sudo mkdir -p "$MAKECONF_DIR"

case "$ARCH" in
    x86_64)
        CHOST="x86_64-pc-linux-gnu"
        ACCEPT_KEYWORDS="~amd64"
        ;;
    aarch64)
        CHOST="aarch64-unknown-linux-gnu"
        ACCEPT_KEYWORDS="~arm64"
        ;;
    *)
        echo "Unknown architecture: $ARCH"
        exit 1
        ;;
esac

sudo tee "$MAKECONF_FILE" > /dev/null <<EOF
# Chard Portage make.conf
# Generated based on detected architecture ($ARCH)

COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
LC_MESSAGES=C.utf8
DISTDIR="/var/cache/distfiles"
PKGDIR="/var/cache/packages"
PORTAGE_TMPDIR="/var/tmp"
PORTDIR="/usr/portage"
SANDBOX="/usr/bin/sandbox"

CHOST="$CHOST"
CC="/usr/bin/gcc"
CXX="/usr/bin/g++"
AR="/usr/bin/gcc-ar"
RANLIB="/usr/bin/gcc-ranlib"
STRIP="/usr/bin/strip"

FEATURES="assume-digests binpkg-docompress binpkg-dostrip binpkg-logs config-protect-if-modified distlocks ebuild-locks fixlafiles merge-sync multilib-strict news parallel-fetch parallel-install pid-sandbox preserve-libs protect-owned strict unknown-features-warn unmerge-logs unmerge-orphans userfetch usersync xattr -sandbox -usersandbox"
USE="X a52 aac acl acpi alsa bindist -bluetooth branding bzip2 cairo cdda cdr cet crypt dbus dri dts encode exif flac gdbm gif gpm gtk gtk3 gui iconv icu introspection ipv6 jpeg lcms libnotify libtirpc mad mng mp3 mp4 mpeg multilib ncurses nls ogg opengl openmp pam pango pcre pdf png ppds qml qt5 qt6 readline sdl seccomp sound spell ssl startup-notification svg tiff truetype udev -udisks unicode -upower usb -utils vorbis vulkan wayland wxwidgets x264 xattr xcb xft xml xv xvid zlib python_targets_python3_13 systemd -elogind"
PYTHON_TARGETS="python3_13"
ACCEPT_KEYWORDS="$ACCEPT_KEYWORDS"

PKG_CONFIG_PATH="/usr/lib/pkgconfig:/lib/pkgconfig:/usr/share/pkgconfig:/share/pkgconfig:\$PKG_CONFIG_PATH"
PKG_CONFIG="/usr/bin/pkg-config"
PORTAGE_PROFILE_DIR="/usr/local/etc/portage/make.profile"
MESON_NATIVE_FILE="/meson-cross.ini"
PYTHONMULTIPROCESSING_START_METHOD=fork

EOF

echo "${RESET}${BLUE}make.conf generated successfully for $ARCH → $MAKECONF_FILE ${RESET}"
sudo mkdir -p "$CHARD_ROOT/usr/share/sandbox"

sudo tee "$CHARD_ROOT/etc/sandbox.conf" > /dev/null <<'EOF'
SANDBOX_BASHRC="/usr/share/sandbox/sandbox.bashrc"
SANDBOX_D="/etc/sandbox.d"
ns-mount-off
ns-pid-off
ns-ipc-off
ns-net-off
ns-user-off
EOF

sudo tee "$CHARD_ROOT/usr/share/sandbox/sandbox.bashrc" > /dev/null <<'EOF'
export HOME="/$CHARD_HOME/"
export USER="chronos"
export LOGNAME="chronos"
export PATH=/usr/bin:/bin:/usr/local/bin:$HOME/.cargo/bin:$PATH
EOF

ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        sudo tee "$CHARD_ROOT/mesonrust.ini" > /dev/null <<'EOF'
[binaries]
c = '/usr/bin/gcc'
cpp = '/usr/bin/g++'
ar = '/usr/bin/gcc-ar'
ranlib = '/usr/bin/gcc-ranlib'
strip = '/usr/bin/strip'
pkgconfig = 'pkg-config'
cargo = '/$CHARD_HOME/.cargo/bin/cargo'
rust = '/$CHARD_HOME/.cargo/bin/rustc'

[properties]
rust_target = 'x86_64-pc-linux-gnu'

[host_machine]
system = 'linux'
cpu_family = 'x86_64'
cpu = 'x86_64'
endian = 'little'
EOF
        ;;
    aarch64|arm64)
        sudo tee "$CHARD_ROOT/mesonrust.ini" > /dev/null <<'EOF'
[binaries]
c = '/usr/bin/gcc'
cpp = '/usr/bin/g++'
ar = '/usr/bin/gcc-ar'
ranlib = '/usr/bin/gcc-ranlib'
strip = '/usr/bin/strip'
pkgconfig = 'pkg-config'
cargo = '/$CHARD_HOME/.cargo/bin/cargo'
rust = '/$CHARD_HOME/.cargo/bin/rustc'

[properties]
rust_target = 'aarch64-unknown-linux-gnu'

[host_machine]
system = 'linux'
cpu_family = 'aarch64'
cpu = 'aarch64'
endian = 'little'
EOF
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        CHOST=x86_64-pc-linux-gnu
        PROFILE_DIR="$CHARD_ROOT/var/db/repos/gentoo/profiles/default/linux/amd64/17.1"
        ;;
    aarch64)
        CHOST=aarch64-unknown-linux-gnu
        PROFILE_DIR="$CHARD_ROOT/var/db/repos/gentoo/profiles/default/linux/arm64/17.1"
        ;;
    *)
        echo "Unknown architecture: $ARCH"
        exit 1
        ;;
esac

sudo mkdir -p "$CHARD_ROOT/var/db/repos/gentoo/profiles"
sudo mkdir -p "$PROFILE_DIR"

sudo tee "$CHARD_ROOT/var/db/repos/gentoo/profiles/repo_name" > /dev/null <<'EOF'
gentoo
EOF

sudo tee "$CHARD_ROOT/.chard_home" >/dev/null <<EOF
$CHARD_HOME
EOF

echo "${RESET}${BLUE}Created $CHARD_ROOT/mesonrust.ini for $ARCH ${RESET}"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        CHOST=x86_64-pc-linux-gnu
        CPU_FAMILY=x86_64
        ;;
    aarch64)
        CHOST=aarch64-unknown-linux-gnu
        CPU_FAMILY=arm64
        ;;
    *)
        echo "Unknown architecture: $ARCH"
        exit 1
        ;;
esac

MESON_FILE="$CHARD_ROOT/meson-cross.ini"

sudo tee "$MESON_FILE" > /dev/null <<EOF

c = '/usr/bin/gcc'
cpp = '/usr/bin/g++'
ar = '/usr/bin/gcc-ar'
ranlib = '/usr/bin/gcc-ranlib'
strip = '/usr/bin/strip'
pkgconfig = '/usr/bin/pkg-config'
pkg-config = '/usr/bin/pkg-config'
llvm-config = 'llvm-config'
fortran = 'false'
objc = 'false'
objcpp = 'false'
objcopy = '/usr/bin/gcc-objcopy'
windres = '/usr/bin/gcc-windres'
python = '/usr/bin/python3'
ninja = '/usr/bin/ninja'

[built-in options]
c_args = ['-march=native', '-O2', '-pipe', '-fPIC', '-I/usr/include']
c_link_args = ['-march=native', '-L/usr/lib64']
cpp_args = ['-march=native', '-O2', '-pipe', '-fPIC', '-I/usr/include']
cpp_link_args = ['-march=native', '-L/usr/lib64']
fortran_args = []
fortran_link_args = []
objc_args = []
objc_link_args = []
objcpp_args = []
objcpp_link_args = []

[properties]
needs_exe_wrapper = false
pkg_config_libdir = '/usr/lib64/pkgconfig'

[build_machine]
system = 'linux'
cpu_family = '$CPU_FAMILY'
cpu = '$CPU_FAMILY'
endian = 'little'
EOF

echo "${RESET}${BLUE}[+] Meson file created at $MESON_FILE for architecture $ARCH ${RESET}"

sudo mkdir -p "$CHARD_ROOT/etc/X11/xorg.conf.d"

XORG_CONF_DIR="$CHARD_ROOT/etc/X11/xorg.conf.d"
sudo mkdir -p "$XORG_CONF_DIR"

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        CHOST="x86_64-pc-linux-gnu"
        CPU_FAMILY="x86_64"
        ;;
    aarch64)
        CHOST="aarch64-unknown-linux-gnu"
        CPU_FAMILY="arm64"
        ;;
    armv7*|armhf)
        CHOST="armv7a-unknown-linux-gnueabihf"
        CPU_FAMILY="arm"
        ;;
    *)
        echo "${YELLOW}Unknown architecture:${RESET} $ARCH"
        ;;
esac

detect_gpu_freq() {
    GPU_FREQ_PATH=""
    GPU_MAX_FREQ=""
    GPU_TYPE="unknown"

    if [ -f "/sys/class/drm/card0/gt_max_freq_mhz" ]; then
        GPU_FREQ_PATH="/sys/class/drm/card0/gt_max_freq_mhz"
        GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
        GPU_TYPE="intel"
        return
    fi

    if [ -f "/sys/class/drm/card0/device/pp_dpm_sclk" ]; then
        GPU_TYPE="nvidia"
        PP_DPM_SCLK="/sys/class/drm/card0/device/pp_dpm_sclk"
        if [[ -f "$PP_DPM_SCLK" ]]; then
            MAX_MHZ=$(grep -o '[0-9]\+' "$PP_DPM_SCLK" | sort -nr | head -n1)
            if [[ -n "$MAX_MHZ" ]]; then
                GPU_MAX_FREQ="$MAX_MHZ"
            fi
        fi
        GPU_FREQ_PATH="$PP_DPM_SCLK"
        return
    fi

    if [ -f "/sys/class/drm/card0/device/pp_od_clk_voltage" ]; then
        GPU_TYPE="amd"
        PP_OD_FILE="/sys/class/drm/card0/device/pp_od_clk_voltage"
        mapfile -t SCLK_LINES < <(grep -i '^sclk' "$PP_OD_FILE")
        if [[ ${#SCLK_LINES[@]} -gt 0 ]]; then
            MAX_MHZ=$(printf '%s\n' "${SCLK_LINES[@]}" | sed -n 's/.*\([0-9]\{1,\}\)[Mm][Hh][Zz].*/\1/p' | sort -nr | head -n1)
            if [[ -n "$MAX_MHZ" ]]; then
                GPU_MAX_FREQ="$MAX_MHZ"
            fi
        fi
        GPU_FREQ_PATH="$PP_OD_FILE"
        return
    fi

    for d in /sys/class/devfreq/*; do
        if grep -qi 'mali' <<< "$d" || grep -qi 'gpu' <<< "$d"; then
            if [ -f "$d/max_freq" ]; then
                GPU_FREQ_PATH="$d/max_freq"
                GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
                GPU_TYPE="mali"
                return
            elif [ -f "$d/available_frequencies" ]; then
                GPU_FREQ_PATH="$d/available_frequencies"
                GPU_MAX_FREQ=$(tr ' ' '\n' < "$GPU_FREQ_PATH" | sort -nr | head -n1)
                GPU_TYPE="mali"
                return
            fi
        fi
    done

    if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
        if [ -f "/sys/class/kgsl/kgsl-3d0/max_gpuclk" ]; then
            GPU_FREQ_PATH="/sys/class/kgsl/kgsl-3d0/max_gpuclk"
            GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
            GPU_TYPE="adreno"
            return
        elif [ -f "/sys/class/kgsl/kgsl-3d0/gpuclk" ]; then
            GPU_FREQ_PATH="/sys/class/kgsl/kgsl-3d0/gpuclk"
            GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
            GPU_TYPE="adreno"
            return
        fi
    fi

    if [[ -d /sys/class/drm ]]; then
        if grep -qi "mediatek" /sys/class/drm/*/device/uevent 2>/dev/null; then
            GPU_TYPE="mediatek"
        elif grep -qi "vivante" /sys/class/drm/*/device/uevent 2>/dev/null; then
            GPU_TYPE="vivante"
        fi
    fi

    GPU_FREQ_PATH=""
    GPU_MAX_FREQ=""
}

detect_gpu_freq
GPU_VENDOR="$GPU_TYPE"
IDENTIFIER="Generic GPU"
DRIVER="modesetting"
ACCEL="glamor"
# Change Accel to glamor for acceleration soon

case "$GPU_VENDOR" in
    intel)
        IDENTIFIER="Intel Graphics"
        DRIVER="modesetting"
        ;;
    amd)
        IDENTIFIER="AMD Graphics"
        DRIVER="amdgpu"
        ;;
    nvidia)
        IDENTIFIER="NVIDIA Graphics"
        DRIVER="nvidia"
        ACCEL="nouveau"
        ;;
    mali)
        IDENTIFIER="ARM Mali Graphics"
        DRIVER="panfrost"
        ;;
    adreno)
        IDENTIFIER="Qualcomm Adreno Graphics"
        DRIVER="freedreno"
        ;;
    mediatek)
        IDENTIFIER="MediaTek GPU"
        DRIVER="panfrost"
        ;;
    vivante)
        IDENTIFIER="Vivante GPU"
        DRIVER="etnaviv"
        ;;
    *)
        IDENTIFIER="Generic GPU"
        DRIVER="modesetting"
        ;;
esac

sudo tee "$XORG_CONF_DIR/20-glamor.conf" > /dev/null <<EOF
Section "Device"
    Identifier "$IDENTIFIER"
    Driver "$DRIVER"
EOF

if [[ -n "$ACCEL" ]]; then
    echo "    Option \"AccelMethod\" \"$ACCEL\"" | sudo tee -a "$XORG_CONF_DIR/20-glamor.conf" > /dev/null
fi

if [[ -n "$GPU_VENDOR" && "$GPU_VENDOR" != "unknown" ]]; then
    echo "${BLUE}Detected GPU:${RESET}${GREEN} $GPU_VENDOR ($ARCH)${RESET}"
else
    echo "${YELLOW}Warning:${RESET}${RED} GPU not detected. Using generic Xorg configuration.${RESET}"
fi

sudo mkdir -p "$CHARD_ROOT/run/dbus"
sudo mkdir -p "$CHARD_ROOT/tmp/.X11-unix"

echo "${RESET}${BLUE}[+] Mounting Chard Chroot${RESET}"
sudo cp /etc/resolv.conf "$CHARD_ROOT/etc/resolv.conf"

echo "${BLUE}${BOLD}chardbuild.log${RESET}${BLUE} copied to Downloads folder for viewing. ${RESET}"
echo "${RESET}${BLUE}${BOLD}Setting up Emerge!"

sudo chroot "$CHARD_ROOT" /bin/bash -c "

    mountpoint -q /proc     || mount -t proc proc /proc 2>/dev/null
    mountpoint -q /sys      || mount -t sysfs sys /sys 2>/dev/null
    mountpoint -q /dev      || mount -t devtmpfs devtmpfs /dev 2>/dev/null
    mountpoint -q /dev/shm  || mount -t tmpfs tmpfs /dev/shm 2>/dev/null
    mountpoint -q /dev/pts  || mount -t devpts devpts /dev/pts 2>/dev/null
    mountpoint -q /etc/ssl  || mount --bind /etc/ssl /etc/ssl 2>/dev/null
    mountpoint -q /run/dbus || mount --bind /run/dbus /run/dbus 2>/dev/null

    chmod 1777 /tmp /var/tmp
    
    [ -e /dev/null    ] || mknod -m 666 /dev/null c 1 3
    [ -e /dev/tty     ] || mknod -m 666 /dev/tty c 5 0
    [ -e /dev/random  ] || mknod -m 666 /dev/random c 1 8
    [ -e /dev/urandom ] || mknod -m 666 /dev/urandom c 1 9
    
    CHARD_HOME=\$(cat /.chard_home)
    HOME=\$CHARD_HOME
    source \$HOME/.bashrc 2>/dev/null

    emerge --sync

    umount /etc/ssl     2>/dev/null || true
    umount /dev/pts     2>/dev/null || true
    umount /dev/shm     2>/dev/null || true
    umount /dev         2>/dev/null || true
    umount /sys         2>/dev/null || true
    umount /proc        2>/dev/null || true
    umount /run/dbus    2>/dev/null || true

"

sudo mv "$CHARD_ROOT/usr/lib/libcrypt.so" "$CHARD_ROOT/usr/lib/libcrypt.so.bak" 2>/dev/null
sudo umount -l "$CHARD_ROOT/dev/shm"  2>/dev/null || true
sudo umount -l "$CHARD_ROOT/dev"      2>/dev/null || true
sudo umount -l "$CHARD_ROOT/sys"      2>/dev/null || true
sudo umount -l "$CHARD_ROOT/proc"     2>/dev/null || true
sudo umount -l "$CHARD_ROOT/etc/ssl"  2>/dev/null || true
sudo umount -l "$CHARD_ROOT/run/dbus" 2>/dev/null || true


ARCH=$(uname -m)
detect_gpu_freq() {
    GPU_FREQ_PATH=""
    GPU_MAX_FREQ=""
    GPU_TYPE="unknown"

    if [ -f "/sys/class/drm/card0/gt_max_freq_mhz" ]; then
        GPU_FREQ_PATH="/sys/class/drm/card0/gt_max_freq_mhz"
        GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
        GPU_TYPE="intel"
        return
    fi

    if [ -f "/sys/class/drm/card0/device/pp_dpm_sclk" ]; then
        GPU_TYPE="nvidia"
        PP_DPM_SCLK="/sys/class/drm/card0/device/pp_dpm_sclk"
        if [[ -f "$PP_DPM_SCLK" ]]; then
            MAX_MHZ=$(grep -o '[0-9]\+' "$PP_DPM_SCLK" | sort -nr | head -n1)
            if [[ -n "$MAX_MHZ" ]]; then
                GPU_MAX_FREQ="$MAX_MHZ"
            fi
        fi
        GPU_FREQ_PATH="$PP_DPM_SCLK"
        return
    fi

    if [ -f "/sys/class/drm/card0/device/pp_od_clk_voltage" ]; then
        GPU_TYPE="amd"
        PP_OD_FILE="/sys/class/drm/card0/device/pp_od_clk_voltage"
        mapfile -t SCLK_LINES < <(grep -i '^sclk' "$PP_OD_FILE")
        if [[ ${#SCLK_LINES[@]} -gt 0 ]]; then
            MAX_MHZ=$(printf '%s\n' "${SCLK_LINES[@]}" | sed -n 's/.*\([0-9]\{1,\}\)[Mm][Hh][Zz].*/\1/p' | sort -nr | head -n1)
            [[ -n "$MAX_MHZ" ]] && GPU_MAX_FREQ="$MAX_MHZ"
        fi
        GPU_FREQ_PATH="$PP_OD_FILE"
        return
    fi

    for d in /sys/class/devfreq/*; do
        if grep -qi 'mali' <<< "$d" || grep -qi 'gpu' <<< "$d"; then
            if [ -f "$d/max_freq" ]; then
                GPU_FREQ_PATH="$d/max_freq"
                GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
                GPU_TYPE="mali"
                return
            elif [ -f "$d/available_frequencies" ]; then
                GPU_FREQ_PATH="$d/available_frequencies"
                GPU_MAX_FREQ=$(tr ' ' '\n' < "$GPU_FREQ_PATH" | sort -nr | head -n1)
                GPU_TYPE="mali"
                return
            fi
        fi
    done

    if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
        if [ -f "/sys/class/kgsl/kgsl-3d0/max_gpuclk" ]; then
            GPU_FREQ_PATH="/sys/class/kgsl/kgsl-3d0/max_gpuclk"
            GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
            GPU_TYPE="adreno"
            return
        elif [ -f "/sys/class/kgsl/kgsl-3d0/gpuclk" ]; then
            GPU_FREQ_PATH="/sys/class/kgsl/kgsl-3d0/gpuclk"
            GPU_MAX_FREQ=$(cat "$GPU_FREQ_PATH")
            GPU_TYPE="adreno"
            return
        fi
    fi

    if [[ -d /sys/class/drm ]]; then
        if grep -qi "mediatek" /sys/class/drm/*/device/uevent 2>/dev/null; then
            GPU_TYPE="mediatek"
        elif grep -qi "vivante" /sys/class/drm/*/device/uevent 2>/dev/null; then
            GPU_TYPE="vivante"
        fi
    fi
}

detect_gpu_freq
GPU_VENDOR="$GPU_TYPE"

case "$ARCH" in
    x86_64)
        case "$GPU_VENDOR" in
            amd)
                DRM_AMDGPU=y
                DRM_I915=n
                CONFIG_DRM_NOUVEAU=n
                CONFIG_LAVAPIPE=n
                ;;
            intel)
                DRM_AMDGPU=n
                DRM_I915=y
                CONFIG_DRM_NOUVEAU=n
                CONFIG_LAVAPIPE=n
                ;;
            nvidia)
                DRM_AMDGPU=n
                DRM_I915=n
                CONFIG_DRM_NOUVEAU=y
                CONFIG_LAVAPIPE=n
                ;;
            *)
                DRM_AMDGPU=n
                DRM_I915=n
                CONFIG_DRM_NOUVEAU=n
                CONFIG_LAVAPIPE=y
                ;;
        esac

sudo tee "$CHARD_ROOT/usr/src/linux/enable_features.cfg" > /dev/null <<EOF
CONFIG_PROC_FS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_DRM_I915=$DRM_I915
CONFIG_DRM_AMDGPU=$DRM_AMDGPU
CONFIG_DRM_NOUVEAU=$DRM_AMDGPU
CONFIG_LAVAPIPE=$CONFIG_LAVAPIPE

CONFIG_NAMESPACES=y
CONFIG_USER_NS=y
CONFIG_SECCOMP=y
CONFIG_SECCOMP_FILTER=y
CONFIG_BPF=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT=y
CONFIG_CGROUP_BPF=y
CONFIG_FHANDLE=y
CONFIG_FANOTIFY=y
CONFIG_EPOLL=y
CONFIG_INOTIFY_USER=y
CONFIG_NET=y
CONFIG_FUSE_FS=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT2=y
CONFIG_FS_POSIX_ACL=y
CONFIG_FS_SECURITY=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
DRM_MALI=n
DRM_ROCKCHIP=n
DRM_ARM_DC=n
EOF
        ;;
    aarch64)
        case "$GPU_VENDOR" in
            mali)
                DRM_MALI=y
                DRM_ROCKCHIP=n
                DRM_ARM_DC=n
                ;;
            adreno)
                DRM_MALI=y
                DRM_ROCKCHIP=n
                DRM_ARM_DC=n
                ;;
            mediatek)
                DRM_MALI=y
                DRM_ROCKCHIP=n
                DRM_ARM_DC=n
                ;;
            vivante)
                DRM_MALI=y
                DRM_ROCKCHIP=n
                DRM_ARM_DC=n
                ;;
            *)
                DRM_MALI=n
                DRM_ROCKCHIP=n
                DRM_ARM_DC=n
                ;;
        esac
        
sudo tee "$CHARD_ROOT/usr/src/linux/enable_features.cfg" > /dev/null <<EOF
CONFIG_PROC_FS=y
CONFIG_SYSFS=y
DRM_MALI=$DRM_MALI
DRM_ROCKCHIP=$DRM_ROCKCHIP
DRM_ARM_DC=$DRM_ARM_DC
DRM_AMDGPU=n
DRM_I915=n
CONFIG_DRM_NOUVEAU=n
CONFIG_LAVAPIPE=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_NAMESPACES=y
CONFIG_USER_NS=y
CONFIG_SECCOMP=y
CONFIG_SECCOMP_FILTER=y
CONFIG_BPF=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT=y
CONFIG_CGROUP_BPF=y
CONFIG_FHANDLE=y
CONFIG_FANOTIFY=y
CONFIG_EPOLL=y
CONFIG_INOTIFY_USER=y
CONFIG_NET=y
CONFIG_FUSE_FS=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT2=y
CONFIG_FS_POSIX_ACL=y
CONFIG_FS_SECURITY=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
EOF
        ;;
    *)
        echo "${RED}Unknown architecture: $ARCH${RESET}"
        exit 1
        ;;
esac

if [[ -f /etc/lsb-release ]]; then
    BOARD_NAME=$(grep '^CHROMEOS_RELEASE_BOARD=' /etc/lsb-release 2>/dev/null | cut -d= -f2)
    BOARD_NAME=${BOARD_NAME:-$(crossystem board 2>/dev/null || crossystem hwid 2>/dev/null || echo "root")}
else
    BOARD_NAME=$(hostnamectl 2>/dev/null | awk -F: '/Chassis/ {print $2}' | xargs)
    BOARD_NAME=${BOARD_NAME:-$(uname -n)}
fi

BOARD_NAME=${BOARD_NAME%%-*}

sudo tee "$CHARD_ROOT/root/.chard_prompt.sh" >/dev/null <<EOF
#!/bin/bash
BOLD='\\[\\e[1m\\]'
RED='\\[\\e[31m\\]'
YELLOW='\\[\\e[33m\\]'
GREEN='\\[\\e[32m\\]'
RESET='\\[\\e[0m\\]'

PS1="\${BOLD}\${RED}chard\${BOLD}\${YELLOW}@\${BOLD}\${GREEN}$BOARD_NAME\${RESET} \\w # "
export PS1
EOF

sudo chmod +x "$CHARD_ROOT/root/.chard_prompt.sh"
if ! grep -q '/root/.chard_prompt.sh' "$CHARD_ROOT/$CHARD_HOME/.bashrc" 2>/dev/null; then
    sudo tee -a "$CHARD_ROOT/$CHARD_HOME/.bashrc" > /dev/null <<'EOF'
source /root/.chard_prompt.sh
EOF
fi

sudo tee -a "$CHARD_ROOT/etc/env.d/99python-fork" <<< 'export PYTHONMULTIPROCESSING_START_METHOD=fork'

    WAYLAND_CONF_DIR="$CHARD_ROOT/etc/profile.d"
    sudo mkdir -p "$WAYLAND_CONF_DIR"

    WAYLAND_CONF_FILE="$WAYLAND_CONF_DIR/wayland_gpu.sh"
    sudo tee "$WAYLAND_CONF_FILE" > /dev/null <<EOF
#!/bin/sh
# Wayland GPU environment setup for Chard

EOF

    case "$GPU_TYPE" in
        intel)
            DRIVER="i965"
            echo "export MESA_LOADER_DRIVER_OVERRIDE=i915" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
            ;;
        amd)
            DRIVER="radeonsi"
            echo "export MESA_LOADER_DRIVER_OVERRIDE=amdgpu" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
            ;;
        nvidia)
            DRIVER="nouveau"
            echo "export MESA_LOADER_DRIVER_OVERRIDE=nouveau" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
            ;;
        mali)
            DRIVER="panfrost"
            echo "export MESA_LOADER_DRIVER_OVERRIDE=panfrost" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
            ;;
        adreno)
            DRIVER="freedreno"
            echo "export MESA_LOADER_DRIVER_OVERRIDE=freedreno" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
            ;;
        mediatek)
            DRIVER="panfrost"
            echo "export MESA_LOADER_DRIVER_OVERRIDE=msm" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
            ;;
        vivante)
            DRIVER="etnaviv"
            echo "export MESA_LOADER_DRIVER_OVERRIDE=etnaviv" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
            ;;
        *)
            DRIVER="llvmpipe"
            echo "[*] No GPU detected, using software fallback (LLVMpipe)" | tee /dev/stderr
            echo "export LIBGL_ALWAYS_SOFTWARE=1" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
            echo "export MESA_LOADER_DRIVER_OVERRIDE=llvmpipe" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
            if [[ "$ARCH" == "x86_64" ]]; then
                echo "export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
            fi
            ;;
    esac

sudo mkdir -p "$CHARD_ROOT/var/lib/portage/"
sudo touch "$CHARD_ROOT/var/lib/portage/world"
echo "dev-lang/perl ~$(portageq envvar ARCH)" | sudo tee -a "$CHARD_ROOT/etc/portage/package.accept_keywords/perl" >/dev/null
echo "export SOMMELIER_USE_WAYLAND=1" | sudo tee -a "$WAYLAND_CONF_FILE" > /dev/null
sudo chmod +x "$WAYLAND_CONF_FILE"
echo "[*] Wayland GPU environment setup complete ($DRIVER)"
echo "${MAGENTA}Detected GPU: $GPU_VENDOR ($ARCH)${RESET}"
echo "${BLUE}Emerge is ready! Please do not sync more than once a day.${RESET}"
echo "${CYAN}Compiling takes a long time, so please be patient if you have a slow CPU. ${RESET}"
echo "${BLUE}To start compiling apps open a new shell and run: ${BOLD}chard root${RESET}${BLUE}${RESET}"
echo "${RESET}${GREEN}Eventually a precompiled version will be made once thorough testing is done.${RESET}"
sudo chown -R 1000:1000 "$CHARD_ROOT"
echo
sudo chroot "$CHARD_ROOT" /bin/bash -c "

        mountpoint -q /proc     || mount -t proc proc /proc
        mountpoint -q /sys      || mount -t sysfs sys /sys
        mountpoint -q /dev      || mount -t devtmpfs devtmpfs /dev
        mountpoint -q /dev/shm  || mount -t tmpfs tmpfs /dev/shm
        mountpoint -q /dev/pts  || mount -t devpts devpts /dev/pts
        mountpoint -q /etc/ssl  || mount --bind /etc/ssl /etc/ssl
        mountpoint -q /run/dbus || mount --bind /run/dbus /run/dbus
        [ -e /dev/null    ] || mknod -m 666 /dev/null c 1 3
        [ -e /dev/tty     ] || mknod -m 666 /dev/tty c 5 0
        [ -e /dev/random  ] || mknod -m 666 /dev/random c 1 8
        [ -e /dev/urandom ] || mknod -m 666 /dev/urandom c 1 9
        chmod 1777 /tmp /var/tmp
                chown root:root /var/lib/portage/world
                chmod 644 /var/lib/portage/world
                CHARD_HOME=\$(cat /.chard_home)
                HOME=\$CHARD_HOME
                source \$HOME/.bashrc 2>/dev/null
                env-update
                SMRT
                dbus-daemon --system --fork 2>/dev/null
                
                emerge dev-build/make
                rm -rf /var/tmp/portage/dev-build/make-*

                emerge app-portage/gentoolkit
                rm -rf /var/tmp/portage/app-portage/gentoolkit-*
                
                emerge dev-libs/gmp
                rm -rf /var/tmp/portage/dev-libs/gmp-*
                eclean-dist -d
                
                emerge dev-libs/mpfr
                rm -rf /var/tmp/portage/dev-libs/mpfr-*
                eclean-dist -d
                
                emerge sys-devel/binutils
                rm -rf /var/tmp/portage/sys-devel/binutils-*
                eclean-dist -d
                
                emerge sys-apps/diffutils
                rm -rf /var/tmp/portage/sys-apps/diffutils-*
                eclean-dist -d
                
                emerge dev-libs/openssl
                rm -rf /var/tmp/portage/dev-libs/openssl-*
                eclean-dist -d
                
                emerge net-misc/curl
                rm -rf /var/tmp/portage/net-misc/curl-*
                eclean-dist -d
                
                emerge dev-vcs/git
                rm -rf /var/tmp/portage/dev-vcs/git-*
                eclean-dist -d
                
                emerge sys-apps/coreutils
                rm -rf /var/tmp/portage/sys-apps/coreutils-*
                eclean-dist -d
                
                emerge app-misc/fastfetch
                rm -rf /var/tmp/portage/app-misc/fastfetch-*
                eclean-dist -d
                
                emerge dev-lang/perl
                rm -rf /var/tmp/portage/dev-lang/perl-*
                eclean-dist -d
                                
                emerge dev-perl/Capture-Tiny
                rm -rf /var/tmp/portage/dev-perl/Capture-Tiny-*
                eclean-dist -d
                
                emerge dev-perl/Try-Tiny
                rm -rf /var/tmp/portage/dev-perl/Try-Tiny-*
                eclean-dist -d
                
                emerge dev-perl/Config-AutoConf
                rm -rf /var/tmp/portage/dev-perl/Config-AutoConf-*
                eclean-dist -d
                
                emerge dev-perl/Test-Fatal
                rm -rf /var/tmp/portage/dev-perl/Test-Fatal-*
                eclean-dist -d
                
                emerge sys-apps/findutils
                rm -rf /var/tmp/portage/sys-apps/findutils-*
                eclean-dist -d
                
                emerge dev-libs/elfutils
                rm -rf /var/tmp/portage/dev-libs/elfutils-*
                eclean-dist -d

                if [ \$(uname -m) = 'aarch64' ]; then
                    export ARCH='arm64';
                fi
                cd /usr/src/linux
                scripts/kconfig/merge_config.sh -m .config enable_features.cfg
                make olddefconfig
                make -j\$(nproc) tools/objtool
                make -j\$(nproc)
                make modules_install
                make INSTALL_PATH=/boot install
                if [ \$(uname -m) = 'aarch64' ]; then
                    export ARCH='aarch64';
                fi
                
                emerge dev-lang/python
                rm -rf /var/tmp/portage/dev-lang/python-*
                eclean-dist -d
                
                emerge dev-build/meson
                rm -rf /var/tmp/portage/dev-build/meson-*
                eclean-dist -d
                
                USE=\"-truetype\" emerge -1 dev-python/pillow
                rm -rf /var/tmp/portage/dev-python/pillow-*
                eclean-dist -d
                
                emerge media-libs/harfbuzz
                rm -rf /var/tmp/portage/media-libs/harfbuzz-*
                eclean-dist -d
                
                emerge dev-libs/glib
                rm -rf /var/tmp/portage/dev-libs/glib-*
                eclean-dist -d
                
                emerge dev-util/pkgcon
                rm -rf /var/tmp/portage/dev-util/pkgcon-*
                eclean-dist -d
                
                emerge dev-cpp/gtest
                rm -rf /var/tmp/portage/dev-cpp/gtest-*
                eclean-dist -d
                
                emerge dev-util/gtest-parallel
                rm -rf /var/tmp/portage/dev-util/gtest-parallel-*
                eclean-dist -d
                
                emerge dev-util/re2c
                rm -rf /var/tmp/portage/dev-util/re2c-*
                eclean-dist -d
                
                emerge dev-build/ninja
                rm -rf /var/tmp/portage/dev-build/ninja-*
                eclean-dist -d
                
                emerge app-text/docbook2X
                rm -rf /var/tmp/portage/app-text/docbook2X-*
                eclean-dist -d
                
                emerge app-text/build-docbook-catalog
                rm -rf /var/tmp/portage/app-text/build-docbook-catalog-*
                eclean-dist -d
                
                emerge dev-util/gtk-doc
                rm -rf /var/tmp/portage/dev-util/gtk-doc-*
                eclean-dist -d
                
                emerge sys-libs/zlib
                rm -rf /var/tmp/portage/sys-libs/zlib-*
                eclean-dist -d
                
                emerge dev-libs/libunistring
                rm -rf /var/tmp/portage/dev-libs/libunistring-*
                eclean-dist -d
                
                emerge sys-apps/file
                rm -rf /var/tmp/portage/sys-apps/file-*
                eclean-dist -d
                
                emerge kde-frameworks/extra-cmake-modules
                rm -rf /var/tmp/portage/kde-frameworks/extra-cmake-modules-*
                eclean-dist -d
                
                emerge -j\$(nproc) dev-perl/File-LibMagic
                rm -rf /var/tmp/portage/dev-perl/File-LibMagic-*
                eclean-dist -d
                
                emerge net-libs/libpsl
                rm -rf /var/tmp/portage/net-libs/libpsl-*
                eclean-dist -d
                
                emerge dev-libs/expat
                rm -rf /var/tmp/portage/dev-libs/expat-*
                eclean-dist -d
                
                emerge dev-lang/duktape
                rm -rf /var/tmp/portage/dev-lang/duktape-*
                eclean-dist -d
                
                emerge app-arch/brotli
                rm -rf /var/tmp/portage/app-arch/brotli-*
                eclean-dist -d

                mv /usr/lib/libcrypt.so /usr/lib/libcrypt.so.bak || true
                
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                
                emerge -j\$(nproc) dev-libs/boehm-gc
                rm -rf /var/tmp/portage/dev-libs/boehm-gc-*
                eclean-dist -d
                
                emerge sys-auth/polkit
                rm -rf /var/tmp/portage/sys-auth/polkit-*
                eclean-dist -d
                
                emerge sys-apps/bubblewrap
                rm -rf /var/tmp/portage/sys-apps/bubblewrap-*
                eclean-dist -d
                
                emerge -v =llvm-core/libclc-20*
                rm -rf /var/tmp/portage/llvm-core/libclc-*
                eclean-dist -d
                
                emerge x11-base/xorg-drivers
                rm -rf /var/tmp/portage/x11-base/xorg-drivers-*
                eclean-dist -d
                
                emerge x11-base/xorg-server
                rm -rf /var/tmp/portage/x11-base/xorg-server-*
                eclean-dist -d
                
                emerge x11-base/xorg-apps
                rm -rf /var/tmp/portage/x11-base/xorg-apps-*
                eclean-dist -d
                
                emerge x11-libs/libX11
                rm -rf /var/tmp/portage/x11-libs/libX11-*
                eclean-dist -d
                
                emerge x11-libs/libXft
                rm -rf /var/tmp/portage/x11-libs/libXft-*
                eclean-dist -d
                
                emerge x11-libs/libXrender
                rm -rf /var/tmp/portage/x11-libs/libXrender-*
                eclean-dist -d
                
                emerge x11-libs/libXrandr
                rm -rf /var/tmp/portage/x11-libs/libXrandr-*
                eclean-dist -d
                
                emerge x11-libs/libXcursor
                rm -rf /var/tmp/portage/x11-libs/libXcursor-*
                eclean-dist -d
                
                emerge x11-libs/libXi
                rm -rf /var/tmp/portage/x11-libs/libXi-*
                eclean-dist -d
                
                emerge x11-libs/libXinerama
                rm -rf /var/tmp/portage/x11-libs/libXinerama-*
                eclean-dist -d
                
                emerge x11-libs/pango
                rm -rf /var/tmp/portage/x11-libs/pango-*
                eclean-dist -d
                
                emerge dev-libs/wayland
                rm -rf /var/tmp/portage/dev-libs/wayland-*
                eclean-dist -d
                
                emerge dev-libs/wayland-protocols
                rm -rf /var/tmp/portage/dev-libs/wayland-protocols-*
                eclean-dist -d
                
                emerge x11-base/xwayland
                rm -rf /var/tmp/portage/x11-base/xwayland-*
                eclean-dist -d
                
                emerge x11-libs/libxkbcommon
                rm -rf /var/tmp/portage/x11-libs/libxkbcommon-*
                eclean-dist -d
                
                emerge gui-libs/gtk
                rm -rf /var/tmp/portage/gui-libs/gtk-*
                eclean-dist -d
                
                emerge xfce-base/libxfce4util
                rm -rf /var/tmp/portage/xfce-base/libxfce4util-*
                eclean-dist -d
                
                emerge xfce-base/xfconf
                rm -rf /var/tmp/portage/xfce-base/xfconf-*
                eclean-dist -d
                
                emerge sys-apps/xdg-desktop-portal
                rm -rf /var/tmp/portage/sys-apps/xdg-desktop-portal-*
                eclean-dist -d
                
                emerge gui-libs/xdg-desktop-portal-wlr
                rm -rf /var/tmp/portage/gui-libs/xdg-desktop-portal-wlr-*
                eclean-dist -d
                
                emerge media-libs/mesa
                rm -rf /var/tmp/portage/media-libs/mesa-*
                eclean-dist -d
                
                emerge x11-apps/mesa-progs
                rm -rf /var/tmp/portage/x11-apps/mesa-progs-*
                eclean-dist -d
                
                emerge dev-qt/qtbase
                rm -rf /var/tmp/portage/dev-qt/qtbase-*
                eclean-dist -d
                
                emerge dev-qt/qttools
                rm -rf /var/tmp/portage/dev-qt/qttools-*
                eclean-dist -d
                
                emerge dev-qt/qtnetwork
                rm -rf /var/tmp/portage/dev-qt/qtnetwork-*
                eclean-dist -d
                
                emerge dev-qt/qtconcurrent
                rm -rf /var/tmp/portage/dev-qt/qtconcurrent-*
                eclean-dist -d
                
                emerge dev-qt/qtxml
                rm -rf /var/tmp/portage/dev-qt/qtxml-*
                eclean-dist -d
                
                emerge dev-qt/qtgui
                rm -rf /var/tmp/portage/dev-qt/qtgui-*
                eclean-dist -d
                
                emerge dev-qt/qtcore
                rm -rf /var/tmp/portage/dev-qt/qtcore-*
                eclean-dist -d
                
                emerge dev-build/cmake
                rm -rf /var/tmp/portage/dev-build/cmake-*
                eclean-dist -d
                
                emerge sys-apps/dbus
                rm -rf /var/tmp/portage/sys-apps/dbus-*
                eclean-dist -d
                
                emerge app-accessibility/at-spi2-core
                rm -rf /var/tmp/portage/app-accessibility/at-spi2-core-*
                eclean-dist -d
                
                emerge app-accessibility/at-spi2-atk
                rm -rf /var/tmp/portage/app-accessibility/at-spi2-atk-*
                eclean-dist -d
                
                emerge media-libs/fontconfig
                rm -rf /var/tmp/portage/media-libs/fontconfig-*
                eclean-dist -d
                
                emerge media-fonts/dejavu
                rm -rf /var/tmp/portage/media-fonts/dejavu-*
                eclean-dist -d
                
                emerge x11-themes/gtk-engines
                rm -rf /var/tmp/portage/x11-themes/gtk-engines-*
                eclean-dist -d
                
                emerge x11-themes/gtk-engines-murrine
                rm -rf /var/tmp/portage/x11-themes/gtk-engines-murrine-*
                eclean-dist -d
                
                emerge dev-lang/python
                rm -rf /var/tmp/portage/dev-lang/python-*
                eclean-dist -d
                
                emerge x11-libs/libnotify
                rm -rf /var/tmp/portage/x11-libs/libnotify-*
                eclean-dist -d
                
                emerge dev-libs/libdbusmenu
                rm -rf /var/tmp/portage/dev-libs/libdbusmenu-*
                eclean-dist -d
                
                emerge x11-libs/libSM
                rm -rf /var/tmp/portage/x11-libs/libSM-*
                eclean-dist -d
                
                emerge x11-libs/libICE
                rm -rf /var/tmp/portage/x11-libs/libICE-*
                eclean-dist -d
                
                emerge x11-libs/libwnck
                rm -rf /var/tmp/portage/x11-libs/libwnck-*
                eclean-dist -d
                
                emerge cmake
                rm -rf /var/tmp/portage/dev-build/cmake-*
                eclean-dist -d
                
                emerge xfce-base/exo
                rm -rf /var/tmp/portage/xfce-base/exo-*
                eclean-dist -d
                
                emerge app-admin/exo
                rm -rf /var/tmp/portage/app-admin/exo-*
                eclean-dist -d
                
                emerge app-arch/tar
                rm -rf /var/tmp/portage/app-arch/tar-*
                eclean-dist -d
                
                emerge app-arch/xz-utils
                rm -rf /var/tmp/portage/app-arch/xz-utils-*
                eclean-dist -d
                
                emerge net-libs/gnutls
                rm -rf /var/tmp/portage/net-libs/gnutls-*
                eclean-dist -d
                
                emerge net-libs/glib-networking
                rm -rf /var/tmp/portage/net-libs/glib-networking-*
                eclean-dist -d
                
                emerge sys-libs/libseccomp
                rm -rf /var/tmp/portage/sys-libs/libseccomp-*
                eclean-dist -d
                
                emerge app-eselect/eselect-repository
                rm -rf /var/tmp/portage/app-eselect/eselect-repository-*
                eclean-dist -d
                
                emerge dev-libs/appstream-glib
                rm -rf /var/tmp/portage/dev-libs/appstream-glib-*
                eclean-dist -d
                
                emerge app-crypt/gpgme
                rm -rf /var/tmp/portage/app-crypt/gpgme-*
                eclean-dist -d
                
                emerge dev-libs/json-glib
                rm -rf /var/tmp/portage/dev-libs/json-glib-*
                eclean-dist -d
                
                emerge dev-util/ostree
                rm -rf /var/tmp/portage/dev-util/ostree-*
                eclean-dist -d
                
                emerge sys-apps/xdg-dbus-proxy
                rm -rf /var/tmp/portage/sys-apps/xdg-dbus-proxy-*
                eclean-dist -d
                
                emerge x11-libs/gdk-pixbuf
                rm -rf /var/tmp/portage/x11-libs/gdk-pixbuf-*
                eclean-dist -d
                
                emerge sys-fs/fuse
                rm -rf /var/tmp/portage/sys-fs/fuse-*
                eclean-dist -d
                
                emerge dev-python/pygobject
                rm -rf /var/tmp/portage/dev-python/pygobject-*
                eclean-dist -d
                
                emerge gnome-base/dconf
                rm -rf /var/tmp/portage/gnome-base/dconf-*
                eclean-dist -d
                
                emerge x11-misc/xdg-utils
                rm -rf /var/tmp/portage/x11-misc/xdg-utils-*
                eclean-dist -d
                
                emerge x11-apps/xinit
                rm -rf /var/tmp/portage/x11-apps/xinit-*
                eclean-dist -d
                
                emerge x11-terms/xterm
                rm -rf /var/tmp/portage/x11-terms/xterm-*
                eclean-dist -d
                
                emerge x11-wm/twm
                rm -rf /var/tmp/portage/x11-wm/twm-*
                eclean-dist -d
                
                emerge media-gfx/chafa
                rm -rf /var/tmp/portage/media-gfx/chafa-*
                eclean-dist -d
                
                emerge dev-python/pillow
                rm -rf /var/tmp/portage/dev-python/pillow-*
                eclean-dist -d
                
                emerge app-text/doxygen
                rm -rf /var/tmp/portage/app-text/doxygen-*
                eclean-dist -d

                emerge gui-libs/egl-gbm
                rm -rf /var/tmp/portage/app-text/doxygen-*
                eclean-dist -d

                cd /tmp
                git clone https://chromium.googlesource.com/chromiumos/platform2
                cd platform2/vm_tools/sommelier
                meson setup build
                ninja -C build
                ninja -C build install
                
                emerge sys-apps/flatpak
                rm -rf /var/tmp/portage/sys-apps/flatpak-*
                eclean-dist -d

                flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                
                umount /etc/ssl     2>/dev/null || true
                umount /dev/pts     2>/dev/null || true
                umount /dev/shm     2>/dev/null || true
                umount /dev         2>/dev/null || true
                umount /sys         2>/dev/null || true
                umount /proc        2>/dev/null || true
                umount /run/dbus    2>/dev/null || true

            "
            show_progress
            echo "${GREEN}[+] Chard Root is ready! ${RESET}"
            sudo umount -l "$CHARD_ROOT/dev/shm" 2>/dev/null || true
            sudo umount -l "$CHARD_ROOT/dev"     2>/dev/null || true
            sudo umount -l "$CHARD_ROOT/sys"     2>/dev/null || true
            sudo umount -l "$CHARD_ROOT/proc"    2>/dev/null || true
            sudo umount -l "$CHARD_ROOT/etc/ssl" 2>/dev/null || true
            sudo cp "$CHARD_ROOT/chardbuild.log" ~/
            echo "${YELLOW}Copied chardbuild.log to $HOME ${RESET}"

            # Check
            #emerge -1 dev-lang/ruby --autounmask-backtrack=y -> Do we need Ruby, yet? 
            #emerge dev-ruby/pkg-config
            #emerge dev-lang/rust -> use rustup
            #emerge --autounmask-write media-sound/pulseaudio-daemon
            #etc-update --automode -5
            #emerge media-libs/pulseaudio-qt
            #emerge media-sound/alsa-utils
            #emerge sys-fs/udisks
            #emerge sys-power/upower
            #emerge sys-apps/bluez
            #emerge dev-python/pybluez
            #sys-auth/polkit
            #app-accessibility/at-spi2-core
            #app-accessibility/at-spi2-atk
            #xfce-extra/xfce4-screensaver
            #sys-apps/xdg-dbus-proxy
            #emerge --autounmask-write www-client/firefox
            #etc-update --automode -5
            #emerge www-client/firefox
            #sudo curl -fsSL https://raw.githubusercontent.com/shadowed1/Chard/main/.chard.preload -o "$CHARD_ROOT/.chard.preload"
