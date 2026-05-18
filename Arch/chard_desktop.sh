#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

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
