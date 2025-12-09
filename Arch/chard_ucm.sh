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

echo "${MAGENTA}$CHROME_CODENAME${RESET}"
echo "${BLUE}$ALSA_CARD${RESET}"
echo "${CYAN}$ALSA_CARD_SHORT${RESET}"

UCM1_ROOT="/usr/share/alsa/ucm"
UCM1_FOLDER=$(find "$UCM1_ROOT" -maxdepth 1 -type d -name "${ALSA_CARD}*" | grep "$CHROME_CODENAME" | head -n1)

if [[ -n "$UCM1_FOLDER" ]]; then
    echo "${GREEN}$UCM1_FOLDER${RESET}"
else
    echo "${RED}Could not find UCM1 folder${RESET}"
fi

UCM1_HIFI="$UCM1_FOLDER/HiFi.conf"

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
    echo "${YELLOW}$UCM2_FOLDER ${RESET}"
else
    echo "${RED}Could not find UCM2 folder for card $ALSA_CARD_SHORT in $UCM2_ROOT${RESET}"
fi

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

echo "${CYAN}Generated: UCM2 HiFi.conf at $UCM2_HIFI ${RESET}"

extract_pcm() {
    local device="$1"
    local type="$2"
    awk -v dev="$device" -v t="$type" '
        $0 ~ "SectionDevice.\""dev"\"" {found=1}
        found && $0 ~ t {gsub(/.*hw:[^,]+,/, ""); gsub(/".*/, ""); print; exit}
    ' "$UCM1_HIFI"
}

SPEAKER_PCM=$(extract_pcm "Speaker" "PlaybackPCM")
HEADPHONE_PCM=$(extract_pcm "Headphone" "PlaybackPCM")
INTERNAL_MIC_PCM=$(extract_pcm "Internal Mic" "CapturePCM")
HEADSET_MIC_PCM=$(extract_pcm "Mic" "CapturePCM")
HDMI_PCM=$(extract_pcm "HDMI" "PlaybackPCM")

CARDNUM=$(aplay -l | awk -v card="$ALSA_CARD" '$0 ~ card {gsub(/[^0-9]/,"",$2); print $2; exit}')

PA_FILE="$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa"
mkdir -p "$(dirname "$PA_FILE")"

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
echo "### Load ALSA sinks using known SOF devices derived from UCM1"
[[ -n "$SPEAKER_PCM" ]] && echo "load-module module-alsa-sink device=hw:${CARDNUM},${SPEAKER_PCM} name=Speaker channels=2 format=s16le tsched=no"
[[ -n "$HEADPHONE_PCM" ]] && echo "load-module module-alsa-sink device=hw:${CARDNUM},${HEADPHONE_PCM} name=Headphones channels=2 format=s16le tsched=no"
[[ -n "$INTERNAL_MIC_PCM" ]] && echo "load-module module-alsa-source device=hw:${CARDNUM},${INTERNAL_MIC_PCM} name=InternalMic channels=2 tsched=no"
[[ -n "$HEADSET_MIC_PCM" ]] && echo "load-module module-alsa-source device=hw:${CARDNUM},${HEADSET_MIC_PCM} name=HeadsetMic channels=2 tsched=no"
#[[ -n "$HDMI_PCM" ]] && echo "load-module module-alsa-sink device=hw:${CARDNUM},${HDMI_PCM} name=HDMI tsched=no"
echo
echo ".nofail"
} > "$PA_FILE"

echo "${BLUE}Generated: $PA_FILE ${RESET}"

grep -qxF ".include /etc/pulse/default.pa" "$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa" 2>/dev/null || \
( sed '/^\.fail$/a\.include /etc/pulse/default.pa' "$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa" 2>/dev/null > "$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa.tmp" && \
  mv "$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa.tmp" "$CHARD_ROOT/$CHARD_HOME/.config/pulse/default.pa" )

echo "${BLUE}Added default.pa $PA_FILE ${RESET}"
