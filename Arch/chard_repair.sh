#!/bin/bash

RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

echo
echo "${YELLOW}Welcome to Chard Repair. This does not remove any files, it just updates Chard Markers. ${RESET}"
echo

if ls /.chardrc > /dev/null 2>&1; then
    echo "${RED}chard_mount must be run from the host shell, not inside Chard.${RESET}"
    sleep 3
    exit 1
fi

download_file() {
    local url="$1"
    local output="$2"

    local attempt=1
    local max_attempts=5
    local wait=2

    while [ $attempt -le $max_attempts ]; do
        local http_code

        http_code=$(sudo curl \
            -L \
            --silent \
            --show-error \
            --output "$output" \
            --write-out "%{http_code}" \
            "$url")

        if [ "$http_code" = "200" ] && [ -s "$output" ]; then
            return 0
        fi

        sudo rm -f "$output"

        case "$http_code" in
            429|500|502|503|504)
                echo "${YELLOW}Download failed (HTTP $http_code). Retrying in ${wait}s (${attempt}/${max_attempts})...${RESET}"
                sleep "$wait"
                wait=$((wait * 2))
                ;;
            *)
                echo "${RED}Download failed (HTTP $http_code).${RESET}"
                return 1
                ;;
        esac

        attempt=$((attempt + 1))
    done

    return 1
}

DEFAULT_CHARD_ROOT="/usr/local/chard"
CHARD_ROOT="${CHARD_ROOT%/}"
CHARD_RC="$CHARD_ROOT/.chardrc"

if [ -n "$CHARD_ROOT" ] && [ -f "$CHARD_ROOT/.install_path" ]; then
    CHARD_ROOT=$(sudo cat "$CHARD_ROOT/.install_path")
    echo -e "${CYAN}Found existing Install Path: ${BOLD}$CHARD_ROOT${RESET}"
elif [ -f "$DEFAULT_CHARD_ROOT/.install_path" ]; then
    CHARD_ROOT=$(sudo cat "$DEFAULT_CHARD_ROOT/.install_path")
    echo -e "${CYAN}Found existing Install Path: ${BOLD}$CHARD_ROOT${RESET}"
else
    CHARD_ROOT="$DEFAULT_CHARD_ROOT"
fi

read -rp "${GREEN}Enter desired Install Path - ${RESET}${GREEN}${BOLD}leave blank for default: $CHARD_ROOT: ${RESET}" choice
if [ -n "$choice" ]; then
    CHARD_ROOT="${choice}"
fi
CHARD_ROOT="${CHARD_ROOT%/}"
echo -e "\n${CYAN}You entered: ${BOLD}$CHARD_ROOT${RESET}"
echo
read -rp "${BLUE}${BOLD}Confirm this install path? Enter key counts as yes! ${RESET}${BOLD} (Y/n): ${RESET}" confirm
echo ""
    
case "$confirm" in
    [Yy]* | "")
        sudo mkdir -p "$CHARD_ROOT"
        ;;
    [Nn]*)
        echo -e "${BLUE}Cancelled.${RESET}\n"
        exit 1
        ;;
    *)
        echo -e "${RED}Please answer Y/n.${RESET}"
        exit 1
        ;;
esac

CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
DEFAULT_BASHRC="$HOME/.bashrc"
TARGET_FILE=""
        
if [ -f "$CHROMEOS_BASHRC" ]; then
    TARGET_FILE="$CHROMEOS_BASHRC"
elif [ -f "$DEFAULT_BASHRC" ]; then
    TARGET_FILE="$DEFAULT_BASHRC"
fi

echo "${RESET}${CYAN}Detected .bashrc: ${BOLD}${TARGET_FILE}${RESET}"
CHARD_HOME="$(dirname "$TARGET_FILE")"
CHARD_HOME="${CHARD_HOME#/}"

if [[ "$CHARD_HOME" == home/* ]]; then
    CHARD_HOME="${CHARD_HOME%%/user*}"

    CHARD_USER="${CHARD_HOME#*/}"
fi

CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
DEFAULT_BASHRC="$HOME/.bashrc"
TARGET_FILE=""

if [ -f "$CHROMEOS_BASHRC" ]; then
    TARGET_FILE="$CHROMEOS_BASHRC"
    CHROME_MILESTONE=$(grep '^CHROMEOS_RELEASE_CHROME_MILESTONE=' /etc/lsb-release | cut -d'=' -f2)
    echo "${CYAN}ChromeOS Version: ${BOLD}$CHROME_MILESTONE ${RESET}${RED}"
    echo "$CHROME_MILESTONE" | sudo tee "$CHARD_ROOT/.chard_chrome" > /dev/null
    sudo mkdir -p $CHARD_ROOT/$CHARD_HOME/external 2>/dev/null
    sudo mkdir -p $CHARD_ROOT/$CHARD_HOME/mtp_devices 2>/dev/null
    sudo chown -R chronos:chronos-access $CHARD_ROOT/$CHARD_HOME/external 2>/dev/null
    sudo chown -R chronos:chronos-access $CHARD_ROOT/$CHARD_HOME/mtp_devices 2>/dev/null
elif [ -f "$DEFAULT_BASHRC" ]; then
    TARGET_FILE="$DEFAULT_BASHRC"
fi

if [ -n "$TARGET_FILE" ]; then
    sed -i '/^# <<< CHARD ENV MARKER <<</,/^# <<< END CHARD ENV MARKER <<</d' "$TARGET_FILE"
    tr -d '\0' < "$TARGET_FILE" > "${TARGET_FILE}.clean" && mv "${TARGET_FILE}.clean" "$TARGET_FILE"
else
    echo "${RED}No .bashrc found! ${RESET}"
fi

if ! grep -Fxq "# <<< CHARD ENV MARKER <<<" "$TARGET_FILE"; then
    {
        echo "# <<< CHARD ENV MARKER <<<"
        echo "source \"$CHARD_RC\""
        echo "# <<< END CHARD ENV MARKER <<<"
    } >> "$TARGET_FILE"
fi

CHROMEOS_BASHRC="/home/chronos/user/.bashrc"
DEFAULT_BASHRC="$HOME/.bashrc"
TARGET_FILE=""

if [ -f "$CHROMEOS_BASHRC" ]; then
    TARGET_FILE="$CHROMEOS_BASHRC"
    sudo mkdir -p "$CHARD_ROOT/$CHARD_HOME/user/MyFiles/Downloads"
else
    TARGET_FILE="$DEFAULT_BASHRC"
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

echo "${CYAN}[*] Downloading Chard components...${RESET}"
echo ""
BASE_URL="https://raw.githubusercontent.com/shadowed1/Chard/main"

FILES=(
    "Arch/.chardrc|$CHARD_ROOT/.chardrc|0"
    "Arch/.chard.env|$CHARD_ROOT/.chard.env|0"
	"Arch/chard_repair.sh|/usr/local/bin/chard_repair|1"
    "bin/Uninstall_Chard.sh|$CHARD_ROOT/bin/Uninstall_Chard.sh|1"
    "Arch/chard.sh|$CHARD_ROOT/bin/chard|1"
    "Arch/.bashrc|$CHARD_ROOT/$CHARD_HOME/.bashrc|0"
    "bin/chard_version|$CHARD_ROOT/bin/chard_version|1"
    "LICENSE|$CHARD_ROOT/$CHARD_HOME/CHARD_LICENSE|0"
    "Arch/.rootrc|$CHARD_ROOT/.rootrc|1"
    "Arch/chariot.sh|$CHARD_ROOT/bin/chariot|1"
    "bin/chard_debug.sh|$CHARD_ROOT/bin/chard_debug|1"
    "Arch/chard_sommelier.sh|$CHARD_ROOT/bin/chard_sommelier|1"
    "bin/chard_scale.sh|$CHARD_ROOT/bin/chard_scale|1"
    "bin/wx|$CHARD_ROOT/bin/wx|1"
    "Arch/SMRT.sh|$CHARD_ROOT/bin/SMRT|1"
    "bin/chard_mount|$CHARD_ROOT/bin/chard_mount|1"
    "bin/chard_unmount|$CHARD_ROOT/bin/chard_unmount|1"
    "Arch/chardsetup.sh|$CHARD_ROOT/bin/chardsetup|1"
    "Arch/root.sh|$CHARD_ROOT/bin/root|1"
    "bin/chard_volume.sh|$CHARD_ROOT/bin/chard_volume|1"
    "bin/chardwire.sh|$CHARD_ROOT/bin/chardwire|1"
    "Arch/.chard.preload|$CHARD_ROOT/.chard.preload|1"
    "Arch/chard_ucm.sh|$CHARD_ROOT/bin/chard_ucm|1"
    "bin/chard_preload.sh|$CHARD_ROOT/bin/chard_preload|1"
	"Arch/chard_wrappers.sh|$CHARD_ROOT/bin/chard_wrappers|1"
	"bin/chard_svg.sh|$CHARD_ROOT/bin/chard_svg|1"
	"bin/downgrade_flatpak_bwrap.sh|$CHARD_ROOT/bin/downgrade_flatpak_bwrap|1"
)

for entry in "${FILES[@]}"; do
    IFS='|' read -r source target executable <<< "$entry"

    sudo mkdir -p "$(dirname "$target")"

    if download_file "$BASE_URL/$source" "$target"; then
        echo "${BLUE}${BOLD}$target${RESET}"

        if [ "$executable" = "1" ]; then
            sudo chmod +x "$target"
        fi
    else
        echo "${RED}Failed: ${BOLD}$source${RESET}"
    fi
    sleep 0.2
done

for file in \
    "$CHARD_ROOT/.chardrc" \
    "$CHARD_ROOT/.chard.env" \
    "$CHARD_ROOT/$CHARD_HOME/.bashrc" \
    "$CHARD_ROOT/.rootrc" \
    "$CHARD_ROOT/bin/chariot" \
    "$CHARD_ROOT/bin/chard_debug" \
    "$CHARD_ROOT/bin/SMRT" \
    "$CHARD_ROOT/bin/chardsetup" \
    "$CHARD_ROOT/bin/chard"; do

    if [ -f "$file" ]; then
        if sudo grep -q '^# <<< CHARD_ROOT_MARKER >>>' "$file"; then
            sudo sed -i -E "/^# <<< CHARD_ROOT_MARKER >>>/,/^# <<< END_CHARD_ROOT_MARKER >>>/c\
# <<< CHARD_ROOT_MARKER >>>\n\
CHARD_ROOT=\"$CHARD_ROOT\"\n\
CHARD_HOME=\"$CHARD_HOME\"\n\
CHARD_USER=\"$CHARD_USER\"\n\
# <<< END_CHARD_ROOT_MARKER >>>" "$file"
        else
            sudo sed -i "1i # <<< CHARD_ROOT_MARKER >>>\n\
CHARD_ROOT=\"$CHARD_ROOT\"\n\
CHARD_HOME=\"$CHARD_HOME\"\n\
CHARD_USER=\"$CHARD_USER\"\n\
# <<< END_CHARD_ROOT_MARKER >>>\n" "$file"
        fi

        sudo chmod +x "$file"
    else
        echo "${RED}[!] Missing: $file ${RESET}"
    fi
done

if grep -q "CHROMEOS_RELEASE" /etc/lsb-release 2>/dev/null; then
    XDG_RUNTIME_VALUE='export XDG_RUNTIME_DIR="$ROOT/run/chrome/"'
else
    XDG_RUNTIME_VALUE='export XDG_RUNTIME_DIR="$ROOT/run/user/1000/"'
fi

if [[ -z "$XDG_RUNTIME_DIR" ]]; then
    if [[ -d /run/chrome ]]; then
        XDG_RUNTIME_DIR="/run/chrome/"
    else
        XDG_RUNTIME_DIR="/run/user/1000/"
    fi
fi

echo "$XDG_RUNTIME_DIR" | sudo tee "$CHARD_ROOT/.xdg_runtime_dir" >/dev/null

sudo sed -i "/# <<< CHARD_XDG_RUNTIME_DIR >>>/,/# <<< END CHARD_XDG_RUNTIME_DIR >>>/c\
# <<< CHARD_XDG_RUNTIME_DIR >>>\n${XDG_RUNTIME_VALUE}\n# <<< END CHARD_XDG_RUNTIME_DIR >>>" \
"$CHARD_ROOT/$CHARD_HOME/.bashrc"

sudo sed -i "/# <<< CHARD_XDG_RUNTIME_DIR >>>/,/# <<< END CHARD_XDG_RUNTIME_DIR >>>/c\
# <<< CHARD_XDG_RUNTIME_DIR >>>\n${XDG_RUNTIME_VALUE}\n# <<< END CHARD_XDG_RUNTIME_DIR >>>" \
"$CHARD_ROOT/bin/chard_sommelier"
