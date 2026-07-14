#!/bin/bash
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'
echo "${BOLD}${CYAN}"
echo "Select your default web browser for Chard!"
echo "${RESET}"

BROWSERS=()

add_browser() {
    local desktop="$1"
    local name="$2"

    if [ -f "/usr/share/applications/$desktop" ]; then
        BROWSERS+=("$desktop|$name")
    fi
}

if [ -f "/usr/share/applications/firefox.desktop" ]; then
    BROWSERS+=("firefox.desktop|Firefox")
elif [ -f "/usr/share/applications/org.mozilla.firefox.desktop" ]; then
    BROWSERS+=("org.mozilla.firefox.desktop|Firefox")
else
    BROWSERS+=("chard-garcon.desktop|ChromeOS Chrome")
fi
add_browser chard-garcon.desktop "ChromeOS' Chrome (Requires Crostini to be running to send command)"
add_browser org.mozilla.firefox.desktop "Firefox"
add_browser brave-browser.desktop "Brave"
add_browser microsoft-edge.desktop "Microsoft Edge"
add_browser microsoft-edge-beta.desktop "Microsoft Edge Beta"
add_browser microsoft-edge-dev.desktop "Microsoft Edge Dev"
add_browser vivaldi-stable.desktop "Vivaldi"
add_browser opera.desktop "Opera"
add_browser opera-beta.desktop "Opera Beta"
add_browser opera-developer.desktop "Opera Developer"
add_browser google-chrome.desktop "Google Chrome"
add_browser google-chrome-stable.desktop "Google Chrome"
add_browser chromium.desktop "Chromium"
add_browser ungoogled-chromium.desktop "Ungoogled Chromium"
add_browser librewolf.desktop "LibreWolf"
add_browser waterfox.desktop "Waterfox"
add_browser floorp.desktop "Floorp"
add_browser zen.desktop "Zen Browser"
add_browser thorium-browser.desktop "Thorium"

for i in "${!BROWSERS[@]}"; do
    IFS='|' read -r desktop name <<< "${BROWSERS[$i]}"
done

printf " ${GREEN}%2d) Enter a desktop file manually (include the ${BOLD}.desktop${RESET}${GREEN} in the name)\n ${RESET}" $(( ${#BROWSERS[@]} + 1 ))
echo

DEFAULT_BROWSER="${BROWSERS[0]}"

while true; do
    read -t 15 -rp "${CYAN}Default Browser: [1-$(( ${#BROWSERS[@]} + 1 ))] (Defaulting to option 1 in 15 seconds...): ${RESET}" choice
    if [ $? -ne 0 ] || [ -z "$choice" ]; then
        IFS='|' read -r BROWSER_DESKTOP _ <<< "$DEFAULT_BROWSER"
        echo
        break
    fi

    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        if (( choice >= 1 && choice <= ${#BROWSERS[@]} )); then
            IFS='|' read -r BROWSER_DESKTOP _ <<< "${BROWSERS[$((choice-1))]}"
            break
        elif (( choice == ${#BROWSERS[@]} + 1 )); then
            read -rp "Enter the desktop file: " BROWSER_DESKTOP
            [ -n "$BROWSER_DESKTOP" ] && break
        fi
    fi

    echo "${RED}Invalid selection. ${RESET}"
done

xdg-mime default "$BROWSER_DESKTOP" text/html
xdg-mime default "$BROWSER_DESKTOP" x-scheme-handler/http
xdg-mime default "$BROWSER_DESKTOP" x-scheme-handler/https
xdg-settings set default-web-browser "$BROWSER_DESKTOP"
echo
echo "${BOLD}${BLUE}Default Browser set to: ${RESET}${MAGENTA}${BOLD}${BROWSER_DESKTOP}${RESET}"
echo
