#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

sudo tee "/bin/chard_firefox" >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export PATH=/usr/local/bubblepatch/bin:$PATH
xhost +SI:localuser:root >/dev/null 2>&1
exec sudo -u "$CHARD_USER" /bin/bash -c '
  XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}"
  export PULSE_SERVER=unix:$XDG_RUNTIME/pulse/native
  export MOZ_CUBEB_FORCE_PULSE=1
  export MOZ_ENABLE_WAYLAND=1
  export MOZ_GTK_TITLEBAR_DECORATION=client
  exec /usr/bin/firefox "$@"
' bash "$@"
EOF

sudo chmod +x "/bin/chard_firefox"

sudo tee "/bin/chard_discord" >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}"
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
fix_sandbox() {
    for base in \
        "$HOME/.config/discord" \
        "$HOME/.local/share/discord" \
        "/home/chronos/.config/discord" \
        "/home/chronos/user/.config/discord"
    do
        [ -d "$base" ] || continue
        find "$base" -type f -name chrome-sandbox 2>/dev/null | while read -r sb; do
            sudo chown root:root "$sb" 2>/dev/null || true
            sudo chmod 4755 "$sb" 2>/dev/null || true
        done
    done
}

fix_sandbox
exec /usr/bin/discord "$@"
EOF

sudo chmod +x "/bin/chard_discord"

sudo tee "/bin/chard_heroic" >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
sudo chown root:root /opt/Heroic/chrome-sandbox
sudo chmod 4755 /opt/Heroic/chrome-sandbox
exec /usr/bin/heroic "$@"
EOF

sudo chmod +x /bin/chard_heroic

sudo tee "/bin/chard_appfinder" >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
sudo chmod u-s,g-s /usr/bin/xfce4-appfinder
exec /usr/bin/xfce4-appfinder "$@"
EOF

sudo chmod +x "/bin/chard_appfinder"

sudo tee "/bin/chard_gparted" >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
xhost +SI:localuser:root >/dev/null 2>&1
exec sudo /bin/bash -c '
  DISPLAY=:0
  exec /usr/bin/gparted "$@"
' bash "$@"
EOF

sudo chmod +x "/bin/chard_gparted"

sudo tee "/bin/chard_tor" >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
xhost +SI:localuser:root >/dev/null 2>&1
exec sudo -u "$CHARD_USER" /bin/bash -c '
  XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
  export PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native
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
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export PATH=/usr/local/bubblepatch/bin:$PATH
xhost +SI:localuser:root >/dev/null 2>&1
exec sudo -u "$CHARD_USER" /bin/bash -c '
  XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
  export PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native
  export MOZ_CUBEB_FORCE_PULSE=1
  export MOZ_ENABLE_WAYLAND=1
  export MOZ_GTK_TITLEBAR_DECORATION=client
  exec /usr/bin/thunderbird "$@"
' bash "$@"
EOF

sudo chmod +x "/bin/chard_thunderbird"

sudo tee "/bin/chard_gedit" >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS}"
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland
exec sudo -E gedit "$@"
EOF

sudo chmod +x "/bin/chard_gedit"

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

sudo tee /usr/share/applications/chard-blender.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=Blender
GenericName=3D modeler
Comment=3D modeling, animation, rendering and post-production
Keywords=3d;cg;modeling;animation;painting;sculpting;texturing;video editing;video tracking;rendering;render engine;cycles;python;
Exec=chard_blender %f
Icon=blender
Terminal=false
Type=Application
PrefersNonDefaultGPU=true
Categories=Graphics;3DGraphics;
MimeType=application/x-blender;
StartupWMClass=Blender
EOF

sudo tee /usr/share/applications/chard-tor.desktop > /dev/null << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Tor Browser (Chard)
Exec=chard_tor %u
Icon=torbrowser
Terminal=false
StartupNotify=true
StartupWMClass=torbrowser
Categories=Network;WebBrowser;
EOF

sudo tee /usr/share/applications/chard-gparted.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=GParted (Chard)
GenericName=Partition Editor
Comment=Create, reorganize, and delete partitions
Exec=/bin/chard_gparted %f
Icon=gparted
Terminal=false
Type=Application
Categories=GNOME;System;Filesystem;
Keywords=Partition;
StartupNotify=true
EOF

sudo tee /usr/share/applications/chard-thunderbird.desktop > /dev/null << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Thunderbird (Chard)
Exec=chard_thunderbird %u
Icon=thunderbird
Terminal=false
StartupNotify=true
StartupWMClass=thunderbird
Categories=Network;Email;
MimeType=x-scheme-handler/mailto;
EOF

sudo tee /usr/share/applications/chard-prismlauncher.desktop > /dev/null << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Prism Launcher (Chard)
Exec=chard_prismlauncher %u
Icon=org.prismlauncher.PrismLauncher
Terminal=false
StartupNotify=true
StartupWMClass=prismlauncher
Categories=Game;
EOF

sudo tee /usr/share/applications/chard-steam.desktop > /dev/null << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Steam (Chard)
Exec=chard_steam %u
Icon=steam
Terminal=false
StartupNotify=true
StartupWMClass=steam
Categories=Network;FileTransfer;Game;
MimeType=x-scheme-handler/steam;x-scheme-handler/steamlink;
EOF

sudo tee /bin/chard_steam >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}"
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export XDG_RUNTIME_DIR
export QT_QPA_PLATFORM=xcb
STEAM_USER_HOME=$CHARD_HOME/.local/share/Steam
export PATH=/usr/local/bubblepatch/bin:$PATH
xhost +SI:localuser:$USER
sudo setfacl -Rm u:$USER:rwx $XDG_RUNTIME_DIR 2>/dev/null
sudo setfacl -Rm u:root:rwx $XDG_RUNTIME_DIR 2>/dev/null
/usr/bin/steam -console -chromeos -force-opaque-background "$@"
sudo setfacl -Rb $XDG_RUNTIME_DIR 2>/dev/null
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

sudo tee "/bin/chard_xfce4" >/dev/null <<'EOF'
#!/bin/bash
XFCE4="$1"
if [ -z "$XFCE4" ]; then
    exit 1
fi

shift

CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}"
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export QT_QPA_PLATFORMTHEME=gtk3
xhost +SI:localuser:$CHARD_USER
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
WRAPPED_PATH="/usr/local/bubblepatch/bin:$PATH"
export PATH="$WRAPPED_PATH"
FLATPAK_BWRAP="/usr/local/bubblepatch/bin/bwrap"
export FLATPAK_BWRAP
LWJGL_TMPDIR="$HOME/.local/tmp"
mkdir -p "$LWJGL_TMPDIR"
chmod 700 "$LWJGL_TMPDIR"
WINE_UID=$(id -u "$CHARD_USER")
WINE_TMP="/tmp/.wine-${WINE_UID}"
mkdir -p "$WINE_TMP"
chown "$CHARD_USER":"$CHARD_USER" "$WINE_TMP"
chmod 700 "$WINE_TMP"
sudo setfacl -Rm u:$CHARD_USER:rwx $XDG_RUNTIME_DIR 2>/dev/null
sudo setfacl -Rm u:root:rwx $XDG_RUNTIME_DIR 2>/dev/null
sudo -u "$CHARD_USER" env \
    HOME="$HOME" \
    USER="$CHARD_USER" \
    PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native \
    DISPLAY="${DISPLAY:-:0}" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH" \
    FLATPAK_BWRAP="$FLATPAK_BWRAP" \
    LIBGL_DRIVERS_PATH="$LIBGL_DRIVERS_PATH" \
    LIBEGL_DRIVERS_PATH="$LIBEGL_DRIVERS_PATH" \
    DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
    XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}" \
    GDK_SCALE="${GDK_SCALE:-1.25}" \
    XDG_DATA_DIRS="$XDG_DATA_DIRS" \
    WAYLAND_DISPLAY="" \
    QT_QPA_PLATFORM=xcb \
    "$XFCE4" "$@"
sudo setfacl -Rb $XDG_RUNTIME_DIR 2>/dev/null
EOF

sudo chmod +x "/bin/chard_xfce4"
    
sudo tee /bin/chard_flatpak >/dev/null <<'EOF'
#!/bin/bash

CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}"
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export QT_QPA_PLATFORMTHEME=gtk3
xhost +SI:localuser:$CHARD_USER
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
WRAPPED_PATH="/usr/local/bubblepatch/bin:/usr/local/bwrap-0.11/bin:/usr/local/flatpak-1.16.3/bin:$PATH"
export PATH="$WRAPPED_PATH"
FLATPAK_BWRAP="/usr/local/bubblepatch/bin/bwrap"
LWJGL_TMPDIR="$HOME/.local/tmp"

if [[ -z "$LIBVA_DRIVER_NAME" ]]; then
    if [[ -e /dev/dri/renderD128 ]]; then
        _DRIVER=$(LIBVA_DISPLAY=drm vainfo --display drm --device /dev/dri/renderD128 2>/dev/null \
            | grep -oP '(?<=Driver version: ).*' | head -1)
        case "$_DRIVER" in
            *iHD*)   LIBVA_DRIVER_NAME="iHD" ;;
            *i965*)  LIBVA_DRIVER_NAME="i965" ;;
            *radeon*|*r600*|*radeonsi*) LIBVA_DRIVER_NAME="radeonsi" ;;
            *nvidia*|*NVD*) LIBVA_DRIVER_NAME="nvidia" ;;
        esac
    fi
fi
export LIBVA_DRIVER_NAME

mkdir -p "$LWJGL_TMPDIR"
chmod 700 "$LWJGL_TMPDIR"
sudo setfacl -Rm u:$USER:rwx $XDG_RUNTIME_DIR 2>/dev/null
sudo setfacl -Rm u:root:rwx $XDG_RUNTIME_DIR 2>/dev/null
NO_USER_CMDS=(
  make-current enter ps kill
  documents document-export document-unexport document-info
  permissions permission-remove permission-set permission-show permission-reset
  remotes remote-add remote-modify remote-delete remote-ls remote-info
  build-init build build-finish build-export build-bundle build-import-bundle
  build-sign build-update-repo build-commit-from repo
)
if [[ $# -eq 0 ]]; then
sudo -u $CHARD_USER \
    env \
    HOME="$HOME" \
    PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native \
    DISPLAY="${DISPLAY:-:0}" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    FLATPAK_BWRAP="$FLATPAK_BWRAP" \
    PATH="$WRAPPED_PATH" \
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH" \
    LIBVA_DRIVER_NAME="$LIBVA_DRIVER_NAME" \
    LIBVA_DISPLAY="drm" \
    LIBVA_DRIVERS_PATH="$LIBVA_DRIVERS_PATH" \
    LIBGL_DRIVERS_PATH="$LIBGL_DRIVERS_PATH" \
    LIBEGL_DRIVERS_PATH="$LIBEGL_DRIVERS_PATH" \
    MESA_LOADER_DRIVER_OVERRIDE="$MESA_LOADER_DRIVER_OVERRIDE" \
    OBS_VKCAPTURE=1 \
    OBS_GAMECAPTURE=1 \
    LIBGL_ALWAYS_INDIRECT=0 \
    GDK_SCALE="${GDK_SCALE:-1.25}" \
    XDG_DATA_DIRS="$XDG_DATA_DIRS" \
    WAYLAND_DISPLAY="" \
    QT_QPA_PLATFORM=xcb \
    flatpak
    exit 0
fi
CMD="$1"
shift
USE_USER=1
for c in "${NO_USER_CMDS[@]}"; do
    [[ "$CMD" == "$c" ]] && USE_USER=0 && break
done
case "$CMD" in
  -h|--help|--version|--default-arch|--supported-arches|--gl-drivers|--installations|--print-updated-env|--print-system-only|-v|--verbose|--ostree-verbose)
    USE_USER=0
    ;;
esac
if [[ $USE_USER -eq 1 ]]; then
    FINAL_ARGS=(--user "$CMD" "$@")
else
    FINAL_ARGS=("$CMD" "$@")
fi
if [[ "$CMD" == "run" ]]; then
    FINAL_ARGS=("${FINAL_ARGS[@]:0:1}" \
        "--device=dri" \
        "--env=WAYLAND_DISPLAY=" \
        "--env=QT_QPA_PLATFORM=xcb" \
        "--env=LIBVA_DRIVER_NAME=iHD" \
        "--env=LIBVA_DISPLAY=drm" \
        "${FINAL_ARGS[@]:1}")
fi
sudo -u $CHARD_USER \
env \
    HOME="$HOME" \
    PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native \
    DISPLAY="${DISPLAY:-:0}" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    FLATPAK_BWRAP="$FLATPAK_BWRAP" \
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH" \
    LIBGL_DRIVERS_PATH="$LIBGL_DRIVERS_PATH" \
    LIBEGL_DRIVERS_PATH="$LIBEGL_DRIVERS_PATH" \
    LIBVA_DRIVER_NAME="$LIBVA_DRIVER_NAME" \
    LIBVA_DISPLAY="drm" \
    LIBVA_DRIVERS_PATH="$LIBVA_DRIVERS_PATH" \
    MESA_LOADER_DRIVER_OVERRIDE="$MESA_LOADER_DRIVER_OVERRIDE" \
    OBS_VKCAPTURE=1 \
    OBS_GAMECAPTURE=1 \
    PATH="$WRAPPED_PATH" \
    LIBGL_ALWAYS_INDIRECT=0 \
    GDK_SCALE="${GDK_SCALE:-1.25}" \
    XDG_DATA_DIRS="$XDG_DATA_DIRS" \
    WAYLAND_DISPLAY="" \
    QT_QPA_PLATFORM=xcb \
flatpak "${FINAL_ARGS[@]}"
sudo setfacl -Rb $XDG_RUNTIME_DIR 2>/dev/null
EOF

sudo chmod +x /bin/chard_flatpak

sudo tee /bin/chard_xfce4-terminal >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}"
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export QT_QPA_PLATFORMTHEME=gtk3
xhost +SI:localuser:$CHARD_USER
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
WRAPPED_PATH="/usr/local/bubblepatch/bin:$PATH"
export PATH="$WRAPPED_PATH"
FLATPAK_BWRAP="/usr/local/bubblepatch/bin/bwrap"
export FLATPAK_BWRAP
LWJGL_TMPDIR="$HOME/.local/tmp"
mkdir -p "$LWJGL_TMPDIR"
chmod 700 "$LWJGL_TMPDIR"
WINE_UID=$(id -u "$CHARD_USER")
WINE_TMP="/tmp/.wine-${WINE_UID}"
mkdir -p "$WINE_TMP"
chown "$CHARD_USER":"$CHARD_USER" "$WINE_TMP"
chmod 700 "$WINE_TMP"
sudo setfacl -Rm u:$USER:rwx $XDG_RUNTIME_DIR 2>/dev/null
sudo setfacl -Rm u:root:rwx $XDG_RUNTIME_DIR 2>/dev/null
XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"

sudo -u $CHARD_USER \
env \
    HOME="$HOME" \
    PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native \
    DISPLAY="${DISPLAY:-:0}" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH" \
    FLATPAK_BWRAP="$FLATPAK_BWRAP" \
    LIBGL_DRIVERS_PATH="$LIBGL_DRIVERS_PATH" \
    LIBEGL_DRIVERS_PATH="$LIBEGL_DRIVERS_PATH" \
    OBS_VKCAPTURE=1 \
    DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
    XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}" \
    OBS_GAMECAPTURE=1 \
    LIBGL_ALWAYS_INDIRECT=0 \
    GDK_SCALE="${GDK_SCALE:-1.25}" \
    XDG_DATA_DIRS="$XDG_DATA_DIRS" \
    WAYLAND_DISPLAY="" \
    QT_QPA_PLATFORM=xcb \
xfce4-terminal
sudo setfacl -Rb $XDG_RUNTIME_DIR 2>/dev/null
EOF

sudo chmod +x /bin/chard_xfce4-terminal

sudo tee /bin/chard_flatpak_ns >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}"
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export QT_QPA_PLATFORMTHEME=gtk3
xhost +SI:localuser:$CHARD_USER

if [[ -z "$LIBVA_DRIVER_NAME" ]]; then
    if [[ -e /dev/dri/renderD128 ]]; then
        _DRIVER=$(LIBVA_DISPLAY=drm vainfo --display drm --device /dev/dri/renderD128 2>/dev/null \
            | grep -oP '(?<=Driver version: ).*' | head -1)
        case "$_DRIVER" in
            *iHD*)   LIBVA_DRIVER_NAME="iHD" ;;
            *i965*)  LIBVA_DRIVER_NAME="i965" ;;
            *radeon*|*r600*|*radeonsi*) LIBVA_DRIVER_NAME="radeonsi" ;;
            *nvidia*|*NVD*) LIBVA_DRIVER_NAME="nvidia" ;;
        esac
    fi
fi
export LIBVA_DRIVER_NAME

[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
WRAPPED_PATH="/usr/local/bubblepatch/bin:/usr/local/bwrap-0.11/bin:/usr/local/flatpak-1.16.3/bin:$PATH"
export PATH="$WRAPPED_PATH"
LWJGL_TMPDIR="$HOME/.local/tmp"
mkdir -p "$LWJGL_TMPDIR"
chmod 700 "$LWJGL_TMPDIR"
WINE_UID=$(id -u "$CHARD_USER")
WINE_TMP="/tmp/.wine-${WINE_UID}"
mkdir -p "$WINE_TMP"
chown "$CHARD_USER":"$CHARD_USER" "$WINE_TMP"
chmod 700 "$WINE_TMP"
sudo setfacl -Rm u:$USER:rwx $XDG_RUNTIME_DIR 2>/dev/null
sudo setfacl -Rm u:root:rwx $XDG_RUNTIME_DIR 2>/dev/null
XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}" \


NO_USER_CMDS=(
  make-current enter ps kill
  documents document-export document-unexport document-info
  permissions permission-remove permission-set permission-show permission-reset
  remotes remote-add remote-modify remote-delete remote-ls remote-info
  build-init build build-finish build-export build-bundle build-import-bundle
  build-sign build-update-repo build-commit-from repo
)

if [[ $# -eq 0 ]]; then
    env \
    HOME="$HOME" \
    PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native \
    DISPLAY="${DISPLAY:-:0}" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH" \
    LIBVA_DRIVER_NAME="$LIBVA_DRIVER_NAME" \
    LIBVA_DISPLAY="drm" \
    LIBVA_DRIVERS_PATH="$LIBVA_DRIVERS_PATH" \
    LIBGL_DRIVERS_PATH="$LIBGL_DRIVERS_PATH" \
    LIBEGL_DRIVERS_PATH="$LIBEGL_DRIVERS_PATH" \
    LIBGL_DRIVERS_PATH="$LIBGL_DRIVERS_PATH" \
    LIBEGL_DRIVERS_PATH="$LIBEGL_DRIVERS_PATH" \
    DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
    XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}" \
    OBS_VKCAPTURE=1 \
    PATH="$WRAPPED_PATH" \
    OBS_GAMECAPTURE=1 \
    LIBGL_ALWAYS_INDIRECT=0 \
    GDK_SCALE="${GDK_SCALE:-1.25}" \
    XDG_DATA_DIRS="$XDG_DATA_DIRS" \
    WAYLAND_DISPLAY="" \
    QT_QPA_PLATFORM=xcb \
    flatpak
    exit 0
fi

CMD="$1"
shift
USE_USER=1
for c in "${NO_USER_CMDS[@]}"; do
    [[ "$CMD" == "$c" ]] && USE_USER=0 && break
done
case "$CMD" in
  -h|--help|--version|--default-arch|--supported-arches|--gl-drivers|--installations|--print-updated-env|--print-system-only|-v|--verbose|--ostree-verbose)
    USE_USER=0
    ;;
esac

if [[ $USE_USER -eq 1 ]]; then
    FINAL_ARGS=(--user "$CMD" "$@")
else
    FINAL_ARGS=("$CMD" "$@")
fi

if [[ "$CMD" == "run" ]]; then
    FINAL_ARGS=("${FINAL_ARGS[@]:0:1}" \
        "--env=WAYLAND_DISPLAY=" \
        "--env=QT_QPA_PLATFORM=xcb" \
        "--env=DISPLAY=${DISPLAY:-:0}" \
        "--env=XAUTHORITY=${XAUTHORITY:-$HOME/.Xauthority}" \
        "${FINAL_ARGS[@]:1}")
fi

env \
    HOME="$HOME" \
    PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native \
    DISPLAY="${DISPLAY:-:0}" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH" \
    LIBGL_DRIVERS_PATH="$LIBGL_DRIVERS_PATH" \
    LIBEGL_DRIVERS_PATH="$LIBEGL_DRIVERS_PATH" \
    OBS_VKCAPTURE=1 \
    PATH="$WRAPPED_PATH" \
    LIBVA_DRIVER_NAME="$LIBVA_DRIVER_NAME" \
    LIBVA_DISPLAY="drm" \
    LIBVA_DRIVERS_PATH="$LIBVA_DRIVERS_PATH" \
    LIBGL_DRIVERS_PATH="$LIBGL_DRIVERS_PATH" \
    LIBEGL_DRIVERS_PATH="$LIBEGL_DRIVERS_PATH" \
    DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
    XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}" \
    OBS_GAMECAPTURE=1 \
    LIBGL_ALWAYS_INDIRECT=0 \
    GDK_SCALE="${GDK_SCALE:-1.25}" \
    XDG_DATA_DIRS="$XDG_DATA_DIRS" \
    WAYLAND_DISPLAY="" \
    QT_QPA_PLATFORM=xcb \
flatpak "${FINAL_ARGS[@]}"
sudo setfacl -Rb $XDG_RUNTIME_DIR 2>/dev/null
EOF

sudo chmod +x /bin/chard_flatpak_ns

sudo tee /bin/chard_plasma >/dev/null <<'EOF'
#!/bin/bash
export PATH=/usr/local/bubblepatch/bin:$PATH
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export QT_QPA_PLATFORM=xcb
RUNTIME_DIR="$XDG_RUNTIME_DIR"
xhost +SI:localuser:$USER
ORIG_MODE=$(stat -c '%a' "$RUNTIME_DIR")
ORIG_OWNER=$(stat -c '%u:%g' "$RUNTIME_DIR")
sudo chown "$USER:$USER" "$RUNTIME_DIR"
sudo chmod 700 "$RUNTIME_DIR"
export XDG_RUNTIME_DIR="$RUNTIME_DIR"

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax --exit-with-session)
fi

SCREEN_RES=$(xdpyinfo | awk '/dimensions/{print $2}' | head -n1)
SCREEN_W=$(echo $SCREEN_RES | cut -dx -f1)
SCREEN_H=$(echo $SCREEN_RES | cut -dx -f2)
kwin_wayland --x11-display "$DISPLAY" --width "$SCREEN_W" --height "$SCREEN_H" &
KWIN_PID=$!
sleep 2
WAYLAND_SOCKET=$(ls "$RUNTIME_DIR"/wayland-* 2>/dev/null | grep -v '\.lock' | sort | tail -n1)
export WAYLAND_DISPLAY=$(basename "$WAYLAND_SOCKET")
plasmashell &
PLASMA_PID=$!
wait $PLASMA_PID
kill $KWIN_PID 2>/dev/null
sudo chown "$ORIG_OWNER" "$RUNTIME_DIR"
sudo chmod "$ORIG_MODE" "$RUNTIME_DIR"
EOF

sudo chmod +x /bin/chard_plasma

sudo tee /bin/chard_qemu >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)
    QEMU_BIN="qemu-system-x86_64"
    ;;
  aarch64|arm64)
    QEMU_BIN="qemu-system-aarch64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac
xhost +SI:localuser:root
sudo setfacl -Rm u:root:rwx $XDG_RUNTIME_DIR 2>/dev/null
source /$CHARD_HOME/.bashrc
WRAPPED_PATH="/usr/local/bubblepatch/bin:/usr/local/bwrap-0.11/bin:/usr/local/flatpak-1.16.3/bin:$PATH"
sudo env \
    HOME=/$CHARD_HOME \
    USER=$CHARD_USER \
    DISPLAY="${DISPLAY:-:0}" \
    PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native \
    PATH="$WRAPPED_PATH" \
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH" \
    LIBGL_DRIVERS_PATH="$LIBGL_DRIVERS_PATH" \
    LIBEGL_DRIVERS_PATH="$LIBEGL_DRIVERS_PATH" \
    LIBGL_ALWAYS_INDIRECT=0 \
    GDK_BACKEND="wayland" \
    EGL_PLATFORM=wayland \
    GDK_SCALE="${GDK_SCALE:-1.25}" \
    XDG_DATA_DIRS="$XDG_DATA_DIRS" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    "$QEMU_BIN" "$@"
sudo setfacl -Rb $XDG_RUNTIME_DIR 2>/dev/null
EOF

sudo chmod +x /bin/chard_qemu

sudo tee /bin/chard_bazaar >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
xhost +SI:localuser:$CHARD_USER
sudo setfacl -Rm u:$USER:rwx $XDG_RUNTIME_DIR 2>/dev/null
sudo setfacl -Rm u:root:rwx $XDG_RUNTIME_DIR 2>/dev/null
source /$CHARD_HOME/.bashrc
WRAPPED_PATH="/usr/local/bubblepatch/bin:/usr/local/bwrap-0.11/bin:/usr/local/flatpak-1.16.3/bin:$PATH"
LWJGL_TMPDIR="/$CHARD_HOME/.local/tmp"
mkdir -p "$LWJGL_TMPDIR"
chown $CHARD_USER:$CHARD_USER "$LWJGL_TMPDIR"
  env HOME=/$CHARD_HOME \
      PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native \
      DISPLAY="${DISPLAY:-:0}" \
      PATH="$WRAPPED_PATH" \
      LD_LIBRARY_PATH="$LD_LIBRARY_PATH" \
      LIBGL_DRIVERS_PATH="$LIBGL_DRIVERS_PATH" \
      LIBEGL_DRIVERS_PATH="$LIBEGL_DRIVERS_PATH" \
      LIBGL_ALWAYS_INDIRECT=0 \
      GDK_BACKEND="wayland" \
      EGL_PLATFORM=wayland \
      GDK_SCALE="${GDK_SCALE:-1.25}" \
      XDG_DATA_DIRS="$XDG_DATA_DIRS" \
  /usr/bin/bazaar "$@"
sudo setfacl -Rb $XDG_RUNTIME_DIR 2>/dev/null
EOF

sudo chmod +x /bin/chard_bazaar

sudo tee /bin/chard_blender >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export PATH=/usr/local/bubblepatch/bin:$PATH
xhost +SI:localuser:root >/dev/null 2>&1
exec sudo -u "$CHARD_USER" /bin/bash -c '
  export PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native
  exec /usr/bin/blender "$@"
' bash "$@"
EOF

sudo chmod +x /bin/chard_blender

sudo tee /bin/chard_obs >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export OBS_VKCAPTURE=1
export OBS_GAMECAPTURE=1
export QT_QPA_PLATFORM=xcb
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
case ":$LD_LIBRARY_PATH:" in
    *:/usr/lib64/obs-plugins:*) ;;
    *) LD_LIBRARY_PATH="/usr/lib64/obs-plugins:$LD_LIBRARY_PATH" ;;
esac
case ":$LD_LIBRARY_PATH:" in
    *:/usr/lib64/obs_glcapture:*) ;;
    *) LD_LIBRARY_PATH="/usr/lib64/obs_glcapture:$LD_LIBRARY_PATH" ;;
esac
export LD_LIBRARY_PATH

chard_obs_mounts() {
    sudo mkdir -p /run/obs-glcapture /run/obs-plugins /run/obs-vklayer
    mountpoint -q /run/obs-glcapture || sudo mount --bind /usr/lib64/obs_glcapture /run/obs-glcapture
    mountpoint -q /run/obs-plugins   || sudo mount --bind /usr/lib64/obs-plugins /run/obs-plugins
    OBS_LAYER_JSON_SRC="/usr/share/vulkan/implicit_layer.d/obs_vkcapture_64.json"
    OBS_LAYER_JSON_DST="/run/obs-vklayer/obs_vkcapture_64.json"
    sudo cp "$OBS_LAYER_JSON_SRC" "$OBS_LAYER_JSON_DST"
    sudo sed -i 's|"library_path": *"/usr/lib/libVkLayer_obs_vkcapture.so"|"library_path": "/run/obs-vklayer/libVkLayer_obs_vkcapture.so"|' "$OBS_LAYER_JSON_DST"
    sudo touch /run/obs-vklayer/libVkLayer_obs_vkcapture.so
    mountpoint -q /run/obs-vklayer/libVkLayer_obs_vkcapture.so || sudo mount --bind /usr/lib/libVkLayer_obs_vkcapture.so /run/obs-vklayer/libVkLayer_obs_vkcapture.so
}

chard_obs_cleanup() {
    sudo umount -l /run/obs-vklayer/libVkLayer_obs_vkcapture.so 2>/dev/null
    sudo umount -l /run/obs-vklayer 2>/dev/null
    sudo umount -l /run/obs-glcapture 2>/dev/null
    sudo umount -l /run/obs-plugins 2>/dev/null
}

chard_obs_mounts
/usr/bin/obs "$@" &
OBS_PID=$!
wait $OBS_PID
chard_obs_cleanup
EOF

sudo chmod +x /bin/chard_obs

sudo tee /bin/chard_7z >/dev/null <<'EOF'
#!/bin/bash
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
HOME=/$CHARD_HOME
USER=$CHARD_USER
export HOME=/$CHARD_HOME
export USER=$CHARD_USER
export PATH=/usr/local/bubblepatch/bin:$PATH
xhost +SI:localuser:root >/dev/null 2>&1
exec sudo -u "$CHARD_USER" /bin/bash -c '
  exec /usr/bin/7zFM "$@"
' bash "$@"
EOF

sudo chmod +x /bin/chard_7z
