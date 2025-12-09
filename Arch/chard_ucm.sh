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
    echo
    
    UCM1_ROOT="/usr/share/alsa/ucm"
    UCM1_FOLDER=$(find "$UCM1_ROOT" -maxdepth 1 -type d -name "${ALSA_CARD}*" | grep "$CHROME_CODENAME" | head -n1)
    if [[ -n "$UCM1_FOLDER" ]]; then
        echo "${CYAN}UCM1 folder: $UCM1_FOLDER${RESET}"
    else
        echo "${RED}Could not find UCM1 folder${RESET}"
    fi
    
    UCM2_ROOT="${CHARD_ROOT:-/usr/local/chard}/usr/share/alsa/ucm2"
    UCM2_FOLDER=$(find "$UCM2_ROOT" -type f -name "HiFi.conf" | sort | while read -r f; do
        dir=$(dirname "$f")
        base=$(basename "$dir")
    
        # SOF devices: pick the first directory whose path contains sof-ALSA_CARD_SHORT
        if [[ "$ALSA_CARD" == sof-* && "$dir" == *"/sof-$ALSA_CARD_SHORT"* ]]; then
            echo "$dir"
        fi
    
        # Non-SOF devices: pick the directory whose basename matches exactly
        if [[ "$ALSA_CARD" != sof-* && "$base" == "$ALSA_CARD_SHORT" ]]; then
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
    
    {
        echo "SectionVerb {"
        echo "    EnableSequence ["
        echo "        disdevall \"\""
        echo "    ]"
        echo "    Value.TQ \"HiFi\""
        echo "}"
        echo
    
        awk -v CardId="${ALSA_CARD}" '
        BEGIN { in_device=0; devname=""; friendly=""; seq="" }
    
        /^SectionDevice/ {
            in_device=1
            devname=$2
            gsub(/[".0]/,"",devname)
            if (devname ~ /Speaker/i) friendly="Speaker"
            else if (devname ~ /Headphone/i) friendly="Headphones"
            else if (devname ~ /Headset/i) friendly="Headset"
            else if (devname ~ /Mic/i) friendly="Mic"
            else friendly=devname
            print "SectionDevice.\""friendly"\" {"
            next
        }
    
        in_device && /^\}/ {
            in_device=0
            print "}"
            print ""
            next
        }
    
        in_device {
            gsub(/ 0$/," off")
            gsub(/ 1$/," on")
            gsub(/hw:[^,]+,/,"hw:${CardId},")
            gsub(/JackDev/,"JackControl")
            print
        }
    
        END {
            if (CardId ~ /sofrt/) {
                print "Macro ["
                print "    { SplitPCM { Name \"dmic_stereo_in\" Direction Capture Format S32_LE Channels 2 HWChannels 4 HWChannelPos0 FL HWChannelPos1 FR HWChannelPos2 FL HWChannelPos3 FR } }"
                print "]"
            }
        }
        ' "$UCM1_HIFI"
    
        if [[ "$ALSA_CARD" == sof-* ]]; then
            echo "Include.hdmi.File \"/codecs/hda/\${var:hdmi}.conf\""
        fi
    
    } | sudo tee "$UCM2_HIFI" > /dev/null
    
    echo "${GREEN}Generated dynamic UCM2 HiFi.conf at $UCM2_HIFI ${RESET}"
