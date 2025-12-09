#!/bin/bash 
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
sudo chown -R 1000:1000 ~/.config/pulse
if [[ "$PS1" =~ @([^-]+)- ]]; then
    CHROME_CODENAME="${BASH_REMATCH[1]}"
else
    CHROME_CODENAME="unknown"
fi

ALSA_CARD=$(awk -F': ' '/sof-/ {n=split($2,a," "); print a[length(a)]; exit}' /proc/asound/cards)
ALSA_CARD="${ALSA_CARD%:}"
ALSA_CARD_SHORT="${ALSA_CARD#sof-}"
    
echo
echo "${MAGENTA}$CHROME_CODENAME${RESET}"
echo "${BLUE}$ALSA_CARD${RESET}"
echo "${CYAN}$ALSA_CARD_SHORT${RESET}"
echo
    
UCM1_ROOT="/usr/share/alsa/ucm"
UCM1_FOLDER=$(find "$UCM1_ROOT" -maxdepth 1 -type d -name "${ALSA_CARD}*" | grep "$CHROME_CODENAME" | head -n1)
if [[ -n "$UCM1_FOLDER" ]]; then
    echo
    echo "${YELLOW}$UCM1_FOLDER${RESET}"
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
    echo "${GREEN}$UCM2_FOLDER${RESET}"
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
echo
echo "${CYAN}Generated: UCM2 HiFi.conf at $UCM2_HIFI ${RESET}"

PA_FILE="$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa"
UCM2_HIFI="${UCM2_HIFI:-/usr/share/alsa/ucm2/*/*/HiFi.conf}"

CARDNUM=$(aplay -l | awk '/card [0-9]+:/ {gsub(/[^0-9]/,"",$2); print $2; exit}')

extract_pcm() {
    local name="$1"

    grep -A20 -E "SectionDevice|$name" "$UCM2_HIFI" 2>/dev/null \
        | grep -E "PlaybackPCM|CapturePCM" \
        | grep -Eo '[0-9]+' \
        | head -n 1
}

SPEAKER_PCM=$(extract_pcm "Speaker")
HEADPHONE_PCM=$(extract_pcm "Headphone")
DMIC_PCM=$(extract_pcm "Mic|Internal")
HSMIC_PCM=$(extract_pcm "Headset")

HDMI_PCMs=$(
    grep -R "HDMI" "$UCM2_HIFI" 2>/dev/null \
        | grep PlaybackPCM \
        | grep -Eo '[0-9]+'
)

mkdir -p "$CHARD_ROOT/$CHARD_HOME/.config/pulse"

{
echo ".fail"
echo
echo "### Core modules"
echo "load-module module-device-restore"
echo "load-module module-stream-restore"
echo "load-module module-card-restore"
echo "load-module module-augment-properties"
echo "load-module module-switch-on-port-available"
echo "load-module module-native-protocol-unix"
echo "load-module module-default-device-restore"
echo "load-module module-always-sink"
echo "load-module module-suspend-on-idle"
echo "load-module module-position-event-sounds"
echo
echo "### Auto-generated ALSA sinks/sources from UCM2"

[[ -n "$SPEAKER_PCM" ]] &&  echo "load-module module-alsa-sink device=hw:${CARDNUM},${SPEAKER_PCM} name=Speaker tsched=no"
[[ -n "$HEADPHONE_PCM" ]] && echo "load-module module-alsa-sink device=hw:${CARDNUM},${HEADPHONE_PCM} name=Headphones tsched=no"
[[ -n "$DMIC_PCM" ]] &&      echo "load-module module-alsa-source device=hw:${CARDNUM},${DMIC_PCM} name=InternalMic tsched=no"
[[ -n "$HSMIC_PCM" ]] &&     echo "load-module module-alsa-source device=hw:${CARDNUM},${HSMIC_PCM} name=HeadsetMic tsched=no"

i=1
for p in $HDMI_PCMs; do
    echo "load-module module-alsa-sink device=hw:${CARDNUM},${p} name=HDMI${i} tsched=no"
    i=$((i+1))
done

echo
echo ".nofail"
} > "$PA_FILE"

echo "${BLUE}Generated: $PA_FILE ${RESET}"
