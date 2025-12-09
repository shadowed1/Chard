#!/bin/bash 
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
    
if [[ "$PS1" =~ @([^-]+)- ]]; then
    CHROME_CODENAME="${BASH_REMATCH[1]}"
else
    CHROME_CODENAME="unknown"
fi
    
ALSA_CARD=$(awk -F': ' '/sof-/ {n=split($2,a," "); print a[length(a)]; exit}' /proc/asound/cards)
ALSA_CARD="${ALSA_CARD%:}"
ALSA_CARD_SHORT="${ALSA_CARD#sof-}"
    
echo
echo "${MAGENTA}Codename: $CHROME_CODENAME${RESET}"
echo "${BLUE}ALSA card: $ALSA_CARD${RESET}"
echo "${CYAN}ALSA card short: $ALSA_CARD_SHORT${RESET}"
    
UCM1_ROOT="/usr/share/alsa/ucm"
UCM1_FOLDER=$(find "$UCM1_ROOT" -maxdepth 1 -type d -name "${ALSA_CARD}*" | grep "$CHROME_CODENAME" | head -n1)
if [[ -n "$UCM1_FOLDER" ]]; then
    echo "${CYAN}UCM1 folder: $UCM1_FOLDER${RESET}"
else
    echo "${RED}Could not find UCM1 folder${RESET}"
fi
    
UCM2_ROOT="$CHARD_ROOT/usr/share/alsa/ucm2"
UCM2_FOLDER=$(find "$UCM2_ROOT" -type f -name "HiFi.conf" | while read -r f; do
    dir=$(dirname "$f")
    base=$(basename "$dir")
    
    if [[ "$ALSA_CARD" == sof-* && "$base" == "sof-$ALSA_CARD_SHORT" ]]; then
        echo "$dir"
    fi
    
    if [[ "$base" == "$ALSA_CARD_SHORT" ]]; then
        echo "$dir"
    fi
done | head -n1)

if [[ -n "$UCM2_FOLDER" ]]; then
    echo "${GREEN}Detected UCM2 folder: $UCM2_FOLDER${RESET}"
else
    echo "${RED}Could not find UCM2 folder for card $ALSA_CARD_SHORT in $UCM2_ROOT${RESET}"
fi
    
UCM1_HIFI="$UCM1_FOLDER/HiFi.conf"
UCM2_HIFI="$UCM2_FOLDER/HiFi.conf"
sudo cp "$UCM2_HIFI" "$UCM2_HIFI.bak.$(date +%s)"
    
sudo sed -i "s/hw:[^,]\+,/hw:${ALSA_CARD},/g" "$UCM2_HIFI"

if [[ "$ALSA_CARD" == sof-* ]] && ! grep -q 'SplitPCM { Name "dmic_stereo_in"' "$UCM2_HIFI"; then
    {
        echo
        echo "Macro ["
        echo "    { SplitPCM { Name \"dmic_stereo_in\" Direction Capture Format S32_LE Channels 2 HWChannels 4 HWChannelPos0 FL HWChannelPos1 FR HWChannelPos2 FL HWChannelPos3 FR } }"
        echo "]"
    } | sudo tee -a "$UCM2_HIFI" > /dev/null
fi

if [[ "$ALSA_CARD" == sof-* ]] && ! grep -q 'Include.hdmi.File' "$UCM2_HIFI"; then
    echo "Include.hdmi.File \"/codecs/hda/\${var:hdmi}.conf\"" | sudo tee -a "$UCM2_HIFI" > /dev/null
fi

echo "${GREEN}Generated dynamic UCM2 HiFi.conf at $UCM2_HIFI ${RESET}"
