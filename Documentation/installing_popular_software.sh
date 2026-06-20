# Discord
echo "net-im/discord all-rights-reserved" | sudo tee -a /etc/portage/package.license
sudo -E emerge discord

# Steam
ARCH=$(uname -m)    
if [[ "$ARCH" == "x86_64" ]]; then
    grep -q '^ABI_X86="64 32"' /etc/portage/make.conf || echo 'ABI_X86="64 32"' | sudo tee -a /etc/portage/make.conf
    sudo -E eselect repository enable steam-overlay
    sudo -E emaint sync -r steam-overlay
    sudo -E emerge --sync
    
    sudo tee /etc/portage/package.use/steam >/dev/null <<'EOF'
app-accessibility/at-spi2-core    abi_x86_32
app-arch/bzip2                    abi_x86_32
app-arch/lz4                      abi_x86_32
app-arch/xz-utils                 abi_x86_32
app-arch/zstd                     abi_x86_32
app-crypt/p11-kit                 abi_x86_32
dev-db/sqlite                     abi_x86_32
dev-lang/rust                     abi_x86_32
dev-lang/rust-bin                 abi_x86_32
dev-libs/dbus-glib                abi_x86_32
dev-libs/elfutils                 abi_x86_32
dev-libs/expat                    abi_x86_32
dev-libs/fribidi                  abi_x86_32
dev-libs/glib                     abi_x86_32
dev-libs/gmp                      abi_x86_32
dev-libs/icu                      abi_x86_32
dev-libs/json-glib                abi_x86_32
dev-libs/leancrypto               abi_x86_32
dev-libs/libevdev                 abi_x86_32
dev-libs/libffi                   abi_x86_32
dev-libs/libgcrypt                abi_x86_32
dev-libs/libgpg-error             abi_x86_32
dev-libs/libgudev                 abi_x86_32
dev-libs/libgusb                  abi_x86_32
dev-libs/libpcre2                 abi_x86_32
dev-libs/libtasn1                 abi_x86_32
dev-libs/libunistring             abi_x86_32
dev-libs/libusb                   abi_x86_32
dev-libs/libxml2                  abi_x86_32
dev-libs/lzo                      abi_x86_32
dev-libs/nettle                   abi_x86_32
dev-libs/nspr                     abi_x86_32
dev-libs/nss                      abi_x86_32
dev-libs/openssl                  abi_x86_32
dev-libs/wayland                  abi_x86_32
dev-util/glslang                  abi_x86_32
dev-util/spirv-tools              abi_x86_32
dev-util/sysprof-capture          abi_x86_32
dev-util/vulkan-utility-libraries abi_x86_32
gnome-base/librsvg                abi_x86_32
gui-libs/libdecor                 abi_x86_32
llvm-core/clang                   abi_x86_32
llvm-core/llvm                    abi_x86_32
media-gfx/graphite2               abi_x86_32
media-libs/alsa-lib               abi_x86_32
media-libs/flac                   abi_x86_32
media-libs/fontconfig             abi_x86_32
media-libs/freetype               abi_x86_32
media-libs/glu                    abi_x86_32
media-libs/harfbuzz               abi_x86_32
media-libs/lcms                   abi_x86_32
media-libs/libdisplay-info        abi_x86_32
media-libs/libepoxy               abi_x86_32
media-libs/libglvnd               abi_x86_32
media-libs/libjpeg-turbo          abi_x86_32
media-libs/libogg                 abi_x86_32
media-libs/libpng                 abi_x86_32
media-libs/libpulse               abi_x86_32
media-libs/libsdl2                abi_x86_32
media-libs/libsndfile             abi_x86_32
media-libs/libva                  abi_x86_32
media-libs/libvorbis              abi_x86_32
media-libs/libwebp                abi_x86_32
media-libs/mesa                   abi_x86_32
media-libs/openal                 abi_x86_32
media-libs/opus                   abi_x86_32
media-libs/tiff                   abi_x86_32
media-libs/vulkan-layers          abi_x86_32
media-libs/vulkan-loader          abi_x86_32 layers
media-sound/lame                  abi_x86_32
media-sound/mpg123-base           abi_x86_32
media-video/pipewire              abi_x86_32
net-dns/c-ares                    abi_x86_32
net-dns/libidn2                   abi_x86_32
net-libs/gnutls                   abi_x86_32
net-libs/libasyncns               abi_x86_32
net-libs/libndp                   abi_x86_32
net-libs/libpsl                   abi_x86_32
net-libs/nghttp2                  abi_x86_32
net-libs/nghttp3                  abi_x86_32
net-misc/curl                     abi_x86_32
net-misc/networkmanager           abi_x86_32
net-print/cups                    abi_x86_32
sys-apps/dbus                     abi_x86_32
sys-apps/lm-sensors               abi_x86_32
sys-apps/systemd                  abi_x86_32
sys-apps/systemd-utils            abi_x86_32
sys-apps/util-linux               abi_x86_32
sys-libs/gdbm                     abi_x86_32
sys-libs/gpm                      abi_x86_32
sys-libs/libcap                   abi_x86_32
sys-libs/libudev-compat           abi_x86_32
sys-libs/ncurses                  abi_x86_32
sys-libs/pam                      abi_x86_32
sys-libs/readline                 abi_x86_32
sys-libs/zlib                     abi_x86_32
virtual/glu                       abi_x86_32
virtual/libelf                    abi_x86_32
virtual/libiconv                  abi_x86_32
virtual/libintl                   abi_x86_32
virtual/libudev                   abi_x86_32
virtual/libusb                    abi_x86_32
virtual/opengl                    abi_x86_32
virtual/zlib                      abi_x86_32
x11-libs/cairo                    abi_x86_32
x11-libs/extest                   abi_x86_32
x11-libs/gdk-pixbuf               abi_x86_32
x11-libs/gtk+                     abi_x86_32
x11-libs/libdrm                   abi_x86_32
x11-libs/libICE                   abi_x86_32
x11-libs/libpciaccess             abi_x86_32
x11-libs/libSM                    abi_x86_32
x11-libs/libvdpau                 abi_x86_32
x11-libs/libX11                   abi_x86_32
x11-libs/libXau                   abi_x86_32
x11-libs/libxcb                   abi_x86_32
x11-libs/libXcomposite            abi_x86_32
x11-libs/libXcursor               abi_x86_32
x11-libs/libXdamage               abi_x86_32
x11-libs/libXdmcp                 abi_x86_32
x11-libs/libXext                  abi_x86_32
x11-libs/libXfixes                abi_x86_32
x11-libs/libXft                   abi_x86_32
x11-libs/libXi                    abi_x86_32
x11-libs/libXinerama              abi_x86_32
x11-libs/libxkbcommon             abi_x86_32
x11-libs/libXrandr                abi_x86_32
x11-libs/libXrender               abi_x86_32
x11-libs/libXScrnSaver            abi_x86_32
x11-libs/libxshmfence             abi_x86_32
x11-libs/libXtst                  abi_x86_32
x11-libs/libXxf86vm               abi_x86_32
x11-libs/pango                    abi_x86_32
x11-libs/pixman                   abi_x86_32
x11-libs/xcb-util-keysyms         abi_x86_32
x11-misc/colord                   abi_x86_32
EOF

    sudo tee /etc/portage/package.accept_keywords/steam >/dev/null <<'EOF'
*/*::steam-overlay
games-util/game-device-udev-rules
sys-libs/libudev-compat
EOF

    sudo tee /etc/portage/package.accept_keywords/steam >/dev/null <<'EOF'
*/*::steam-overlay
games-util/game-device-udev-rules
sys-libs/libudev-compat
EOF

    sudo tee /etc/portage/package.license >/dev/null <<'EOF'
media-libs/libva-intel-media-driver no-source-code
app-arch/lha lha
app-arch/unrar unRAR
app-arch/rar RAR
app-arch/lha lha
app-arch/unrar unRAR
app-arch/rar RAR
games-util/steam-launcher ValveSteamLicense
EOF

sudo tee /etc/portage/package.use/systemd >/dev/null <<'EOF'
sys-apps/systemd -test
EOF

    USE="-gpm" sudo -E emerge --oneshot sys-libs/ncurses
    sudo -E emerge --oneshot sys-libs/glibc
    USE="policykit" sudo -E emerge --oneshot sys-apps/systemd
    sudo -E emerge games-util/steam-launcher
    sudo -E emerge sys-libs/ncurses
    eclean-dist -d
    STEAM_SCRIPT="/usr/lib/steam/bin_steam.sh"
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
/usr/lib/steam/bin_steam.sh -no-cef-sandbox -cef-disable-gpu-compositing "$@"
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
    echo "Skipping Steam for architecture: $ARCH"
else
    echo "Skipping Steam for architecture: $ARCH"
fi
