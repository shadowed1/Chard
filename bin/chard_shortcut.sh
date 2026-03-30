
#!/bin/bash
# Run in ChromeOS shell with sudo enabled or VT-2 logged in as chronos
# Thanks for Days for the early documentation! 

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

if [[ ! -f /home/chronos/user/.bashrc ]]; then
    echo "${RED}Please run this command in the ChromeOS shell."
    sleep 3
    exit 1
fi

DEFAULT_CHARD_ROOT="/usr/local/chard"

if [ -n "$CHARD_ROOT" ] && [ -f "$CHARD_ROOT/.install_path" ]; then
    CHARD_ROOT=$(sudo cat "$CHARD_ROOT/.install_path")
    echo "${CYAN}Found existing Install Path: ${BOLD}$CHARD_ROOT${RESET}"
elif [ -f "$DEFAULT_CHARD_ROOT/.install_path" ]; then
    CHARD_ROOT=$(sudo cat "$DEFAULT_CHARD_ROOT/.install_path")
    echo "${CYAN}Found existing Install Path: ${BOLD}$CHARD_ROOT${RESET}"
else
    CHARD_ROOT="$DEFAULT_CHARD_ROOT"
fi

U_HASH=$(sudo ls /home/.shadow/ | grep -v 'salt\|root' | head -1)
echo "$U_HASH" | sudo tee "$CHARD_ROOT/.chard_hash" > /dev/null
sudo chown -R 1000:1000 /home/chronos/user/MyFiles/Downloads/chard_icons/
CHARD_USER=$(cat "$CHARD_ROOT/.chard_user" 2>/dev/null || echo "chronos")
CHARD_HOME=$(cat "$CHARD_ROOT/.chard_home" 2>/dev/null || echo "/home/chronos")
CHARD_APPS="$CHARD_ROOT/usr/share/applications"
ICONS_HICOLOR="$CHARD_ROOT/usr/share/icons/hicolor"
ICONS_PIXMAPS="$CHARD_ROOT/usr/share/pixmaps"
SHARED="$HOME/MyFiles/Downloads/chard_icons"

echo "${CYAN}${BOLD}Preparing Chard app stubs for ChromeOS Ash...${RESET}"
echo

echo "${CYAN}Extracting Chard aliases...${RESET}"
mkdir -p "$SHARED"
BASHRC="$CHARD_ROOT/$CHARD_HOME/.bashrc"
ALIASES_FILE="$SHARED/.chard_aliases"
> "$ALIASES_FILE"
if [ -f "$BASHRC" ]; then
    grep -E "^alias " "$BASHRC" | while read -r line; do
        name=$(echo "$line" | sed "s/alias \([^=]*\)=.*/\1/")
        value=$(echo "$line" | sed "s/alias [^=]*=['\"]//;s/['\"]$//")
        echo "$name=$value" >> "$ALIASES_FILE"
    done
    echo "  $(wc -l < "$ALIASES_FILE") aliases written to .chard_aliases"
else
    echo "  No .bashrc found at $BASHRC"
fi

find_png() {
    local icon_name="$1"
    for size in 128 96 64 48 32 16; do
        local p="$ICONS_HICOLOR/${size}x${size}/apps/${icon_name}.png"
        [ -f "$p" ] && echo "$p" && return
    done
    local p="$ICONS_PIXMAPS/${icon_name}.png"
    [ -f "$p" ] && echo "$p" && return
    find "$ICONS_HICOLOR" -name "${icon_name}.png" 2>/dev/null | head -1
}

install_icons() {
    local icon_name="$1"
    local app_id="$2"
    local icon_dir="/home/user/$U_HASH/app_service/icons/$app_id"
    local shared_icon_dir="$SHARED/icons/$app_id"
    sudo mkdir -p "$icon_dir"
    sudo chmod 755 "$icon_dir"
    mkdir -p "$shared_icon_dir"
    local count=0
    for size in 16 32 48 64 96 128; do
        local src="$ICONS_HICOLOR/${size}x${size}/apps/${icon_name}.png"
        if [ -f "$src" ]; then
            sudo cp "$src" "$icon_dir/${size}.png"
            sudo chmod 644 "$icon_dir/${size}.png"
            cp "$src" "$shared_icon_dir/${size}.png"
            count=$((count + 1))
        fi
    done
    if [ $count -eq 0 ]; then
        local fallback=$(find_png "$icon_name")
        if [ -n "$fallback" ]; then
            for size in 16 32 48 64 96 128; do
                sudo cp "$fallback" "$icon_dir/${size}.png"
                sudo chmod 644 "$icon_dir/${size}.png"
                cp "$fallback" "$shared_icon_dir/${size}.png"
            done
            count=6
        fi
    fi
    echo "$icon_name" > "$shared_icon_dir/.icon_name"
    echo $count
}


generate_app_id() {
    echo -n "crostini:termina/penguin/chard-$1" | \
        sha256sum | head -c 32 | tr '[:lower:]' '[:upper:]' | \
        tr '0123456789ABCDEF' 'abcdefghijklmnop'
}

mkdir -p "$SHARED/desktops" "$SHARED/launch"
count=0
skipped=0

for df in "$CHARD_APPS"/*.desktop; do
    [ -f "$df" ] || continue
    type=$(grep -m1 '^Type=' "$df" | cut -d= -f2 | tr -d '[:space:]')
    no_display=$(grep -m1 '^NoDisplay=' "$df" | cut -d= -f2 | tr -d '[:space:]')
    only_show=$(grep -m1 '^OnlyShowIn=' "$df" | cut -d= -f2)
    [ "$type" != "Application" ] && { skipped=$((skipped+1)); continue; }
    [ "$no_display" = "true" ] && { skipped=$((skipped+1)); continue; }
    echo "$only_show" | grep -q "XFCE" && { skipped=$((skipped+1)); continue; }

    desktop_file_id=$(basename "$df" .desktop)
    name=$(grep -m1 '^Name=' "$df" | cut -d= -f2-)
    icon=$(grep -m1 '^Icon=' "$df" | cut -d= -f2 | tr -d '[:space:]')
    terminal=$(grep -m1 '^Terminal=' "$df" | cut -d= -f2 | tr -d '[:space:]')
    wm_class=$(grep -m1 '^StartupWMClass=' "$df" | cut -d= -f2 | tr -d '[:space:]')
    [ -z "$wm_class" ] && wm_class="$desktop_file_id"
    app_id=$(generate_app_id "$desktop_file_id")
    icons_count=$(install_icons "$icon" "$app_id")

    cat > "$SHARED/desktops/chard-${desktop_file_id}.desktop" << DESKTOP
[Desktop Entry]
Type=Application
Name=$name
Exec=/usr/local/bin/chard_bridge $desktop_file_id
Icon=$icon
Terminal=false
NoDisplay=false
StartupWMClass=$wm_class
DESKTOP

    printf "  ${GREEN}%-40s${RESET} ${YELLOW}%s${RESET} (%s icons)\n" \
        "$name" "$app_id" "$icons_count"

    count=$((count+1))
done

touch "$SHARED/.sync_now"
sudo chown -R 1000:1000 /home/chronos/user/MyFiles/Downloads/chard_icons/
echo
echo "${GREEN}${BOLD}Created $count shortcuts, skipped $skipped.${RESET}"
