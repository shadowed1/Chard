'EOF' 
#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo "${RESET}${GREEN}Flatpak directly in ChromeOS without Developer mode?${RESET}"
echo "${RESET}"
echo "${YELLOW}0: Quit${RESET}"
echo "${GREEN}1: Download and install Chard to ~/chard${RESET}"
echo ""

read -rp "Enter (0-1): " choice

case "$choice" in
    0)
        echo "Quit"
        ;;
    1)
echo ""
echo "${GREEN}${BOLD}About to start downloading STUFF${RESET}"
echo ""
mkdir -p ~/chard
mkdir -p ~/chard/flatpak
mkdir -p ~/chard/flatpak-deps

download_and_extract() {
    local url="$1"
    local target_dir="$2"
    local FILE SAFE_FILE BASENAME

    echo "${MAGENTA}Downloading: $url${RESET}"
    mkdir -p "$target_dir"

    curl -LO "$url"

    if [[ -f "download" ]]; then
        FILE="download"
    else
        FILE=$(ls -t *.pkg.tar.zst 2>/dev/null | head -n 1)
    fi

    SAFE_FILE="${FILE//:/}"
    if [[ "$FILE" != "$SAFE_FILE" ]]; then
        mv "$FILE" "$SAFE_FILE"
        FILE="$SAFE_FILE"
    fi

    BASENAME="${FILE%.zst}"
    echo "${CYAN}Extracting $FILE to $target_dir${RESET}"
    tar --use-compress-program=unzstd -xvf "$FILE" -C "$target_dir"

    rm -f "$FILE" "$BASENAME"

    chmod +x "$target_dir/usr/bin/"* 2>/dev/null || true
    chmod +x "$target_dir/usr/share/"* 2>/dev/null || true

    echo "${GREEN}${SAFE_FILE} extracted to $target_dir${RESET}"
    sleep 1
}


########
# Flatpak Core
URL="https://archlinux.org/packages/extra/x86_64/flatpak/download"
download_and_extract "$URL" "$HOME/opt/chard/flatpak"

URL="https://archlinux.org/packages/extra/x86_64/ostree/download"
download_and_extract "$URL" "$HOME/opt/chard/flatpak-deps"

URL="https://archlinux.org/packages/core/x86_64/libxml2/download"
download_and_extract "$URL" "$HOME/opt/chard/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/libmalcontent/download"
download_and_extract "$URL" "$HOME/opt/chard/flatpak-deps"

URL="https://archlinux.org/packages/core/x86_64/gpgme/download"
download_and_extract "$URL" "$HOME/opt/chard/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/libsodium/download"
download_and_extract "$URL" "$HOME/opt/chard/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/composefs/download"
download_and_extract "$URL" "$HOME/opt/chard/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/bubblewrap/download"
download_and_extract "$URL" "$HOME/opt/chard/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/xdg-dbus-proxy/download"
download_and_extract "$URL" "$HOME/opt/chard/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal/download"
download_and_extract "$URL" "$HOME/opt/chard/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal-gtk/download"
download_and_extract "$URL" "$HOME/opt/chard/flatpak-deps"

############################################################## 
# Fastfetch
URL="https://archlinux.org/packages/extra/x86_64/fastfetch/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/yyjson/download"
download_and_extract "$URL" "$HOME/opt/chard"

############################################################## 
# Nano
URL="https://archlinux.org/packages/core/x86_64/nano/download"
download_and_extract "$URL" "$HOME/opt/chard"

############################################################## 
# Git
URL="https://archlinux.org/packages/extra/x86_64/git/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/expat/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/pcre2/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/openssl/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/perl/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/perl-error/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/perl-mailtools/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/shadow/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/zlib-ng/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/libcurl-gnutls/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/zstd/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/lz4/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/leancrypto/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/libidn2/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/libp11-kit/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/libffi/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/glibc/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/tzdata/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/libtasn1/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/libunistring/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/nettle/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/gmp/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/zlib/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/gcc-libs/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/npm/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/jq/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/oniguruma/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/node-gyp/download"
download_and_extract "$URL" "$HOME/opt/chard/flatpak-deps"

URL="https://archlinux.org/packages/extra/any/semver/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/nodejs/download"
download_and_extract "$URL" "$HOME/opt/chard"

# gcc
URL="https://archlinux.org/packages/core/x86_64/gcc/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/binutils/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/jansson/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/libelf/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/json-c/download"
download_and_extract "$URL" "$HOME/opt/chard"


# python
URL="https://archlinux.org/packages/core/x86_64/brotli/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/cmake/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/nlohmann-json/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/python/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-sphinx/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-babel/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/libxcrypt/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/mpdecimal/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-pytz/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-jaraco.collections/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-setuptools/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-jaraco.functools/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-jaraco.text/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-more-itertools/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-packaging/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-freezegun/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-pytest/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-docutils/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-imagesize/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-jinja/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-pygments/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-snowballstemmer/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-roman-numerals-py/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-sphinx-alabaster-theme/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-sphinxcontrib-htmlhelp/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-sphinxcontrib-jsmath/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-sphinxcontrib-qthelp/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-sphinxcontrib-serializinghtml/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/cppdap/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/jsoncpp/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/libarchive/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/libuv/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/ncurses/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/rhash/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/lcms2/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/gnutls/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/qt6-base/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/ninja/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/make/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/gc/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-wheel/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-installer/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-build/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/c-ares/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/icu/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/libngtcp2/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/libnsl/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/simdjson/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/procps-ng/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/nodejs-nopt/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-sphinxcontrib-applehelp/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/python-sphinxcontrib-devhelp/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/nvm/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/giflib/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/core/x86_64/libisl/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/any/node-gyp/download"
download_and_extract "$URL" "$HOME/opt/chard"

URL="https://archlinux.org/packages/extra/x86_64/unzip/download"
download_and_extract "$URL" "$HOME/opt/chard"

echo "${RESET}${GREEN}"
curl -L https://raw.githubusercontent.com/shadowed1/Chard/main/.chardLogic -o ~/opt/chard/.chardLogic
echo "${RESET}${YELLOW}"
curl -L https://raw.githubusercontent.com/shadowed1/Chard/main/.chardEnv -o ~/opt/chard/bin/.chardEnv
echo "${RESET}${GREEN}"
curl -L https://raw.githubusercontent.com/shadowed1/Chard/main/chard -o ~/opt/chard/bin/chard
echo "${RESET}${YELLOW}"
curl -L https://raw.githubusercontent.com/shadowed1/Chard/main/version -o ~/opt/chard/bin/version
echo "${RESET}"
chmod +x ~/opt/bin/chard
echo ""

export LD_LIBRARY_PATH="$HOME/opt/chard/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"

if file "$XDG_RUNTIME_DIR/dbus-session" | grep -q socket; then
  export DBUS_SESSION_BUS_ADDRESS=$(grep -E '^unix:' "$XDG_RUNTIME_DIR/dbus-session.address")
  grep -v '^export DBUS_SESSION_BUS_ADDRESS=' "$HOME/opt/chard/.chardEnv" > "$HOME/opt/chard/chardEnv.tmp"
  echo "export DBUS_SESSION_BUS_ADDRESS=\"$DBUS_SESSION_BUS_ADDRESS\"" >> "$HOME/opt/chard/.chardEnv.tmp"
  mv "$HOME/opt/chard/.chardEnv.tmp" "$HOME/opt/chard/.chardEnv"
else
  echo "dbus socket not found."
fi

[ -f "$HOME/.chardbashrc" ] || touch "$HOME/.chardbashrc"

FLATPAK_ENV_LINE='[ -f "$HOME/opt/chard/.chardEnv" ] && . "$HOME/opt/chard/.chardEnv"'
FLATPAK_LOGIC_LINE='[ -f "$HOME/opt/chard/.chardLogic" ] && . "$HOME/opt/chard/.chardLogic"'

grep -Fxq "$FLATPAK_ENV_LINE" "$HOME/.chardbashrc" || echo "$FLATPAK_ENV_LINE" >> "$HOME/.chardbashrc"
grep -Fxq "$FLATPAK_LOGIC_LINE" "$HOME/.chardbashrc" || echo "$FLATPAK_LOGIC_LINE" >> "$HOME/.chardbashrc"

echo ""
"$HOME/opt/chard/flatpak/usr/bin/flatpak" --version
sleep 3

echo ""

"$HOME/opt/chard/flatpak/usr/bin/flatpak" --version
sleep 3

export PATH="$HOME/opt/chard/usr/bin:$PATH"
CHARD_LIB="$HOME/opt/chard/usr/lib"
FLATPAK_USER_DIR="$HOME/opt/chard/share/flatpak" \
LD_LIBRARY_PATH="$CHARD_LIB:$LD_LIBRARY_PATH" \
"$HOME/opt/chard/flatpak/usr/bin/flatpak" --version
export XDG_DATA_DIRS="$HOME/opt/chard/usr/share:$XDG_DATA_DIRS"
export FLATPAK_USER_DIR="$HOME/opt/chard/share/flatpak"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"
NPM_BASE="$HOME/opt/chard/usr/lib/node_modules/npm"
NVM_DIR="$HOME/opt/chard/usr/share/nvm"
BIN_DIR="$HOME/opt/chard/usr/bin"

mkdir -p "$BIN_DIR"
mkdir -p ~/opt/etc/xdg/xfce4/xfwm4

rm -f "$BIN_DIR/npm" "$BIN_DIR/npx"

ln -s "$NPM_BASE/bin/npm-cli.js" "$BIN_DIR/npm"
ln -s "$NPM_BASE/bin/npx-cli.js" "$BIN_DIR/npx"

chmod +x "$NPM_BASE/bin/"*.js

ln -sf "$HOME/opt/chard/bin/chard" "$HOME/opt/chard/bin/yay"
ln -sf "$HOME/opt/chard/bin/chard" "$HOME/opt/chard/bin/paru"
ln -sf "$HOME/opt/chard/bin/chard" "$HOME/opt/chard/bin/pacaur"
ln -sf "$HOME/opt/chard/bin/chard" "$HOME/opt/chard/bin/pacman"


echo ""

        ;;
    *)
        echo "${RED}Invalid option.$RESET"
        exit 1
        ;;
esac
exit 0
EOF
