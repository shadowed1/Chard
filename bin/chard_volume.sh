#!/bin/bash
for file in .chard_volume .chard_hdmi .chard_bluetooth .chard_usb .chard_muted .chard_mic_gain; do
    [ ! -f "$CHARD_ROOT/$CHARD_HOME/$file" ] && sudo touch "$CHARD_ROOT/$CHARD_HOME/$file"
done
update_volume() {
    local output
    output=$(cras_test_client 2>/dev/null)
    volume=$(echo "$output" | grep "Output Nodes:" -A 20 | grep "yes" | grep -E "INTERNAL_SPEAKER|HEADPHONE|HDMI|BLUETOOTH|USB" | awk '{print $3}')
    hdmi=$(echo "$output" | grep "Output Nodes:" -A 20 | grep "HDMI" | grep "yes" | head -n 1 | sed -n 's/.*HDMI[[:space:]]*[0-9]*\*\?//p')
    bluetooth=$(echo "$output" | grep "Output Nodes:" -A 20 | grep "BLUETOOTH" | grep "yes" | head -n 1 | sed -n 's/.*BLUETOOTH[[:space:]]*[0-9]*\*\?//p')
    usb_node=$(echo "$output" | grep "Output Nodes:" -A 20 | grep "USB" | grep "yes" | head -n 1)
    gain=$(echo "$output" | grep "Input Nodes:" -A 20 | grep "yes" | grep -E "INTERNAL_MIC|MIC|FRONT_MIC|REAR_MIC|BLUETOOTH" | awk '{print $3}' | head -n 1)
    if echo "$output" | grep -q "User muted: Muted"; then
        muted="1"
    else
        muted="0"
    fi
    usb=""
    if [ -n "$usb_node" ]; then
        device_id=$(echo "$usb_node" | awk '{print $2}' | cut -d':' -f1)
        usb=$(echo "$output" | grep "Output Devices:" -A 50 | grep "^[[:space:]]*${device_id}[[:space:]]" | awk '{$1=$2=$3=""; print $0}' | sed 's/^[[:space:]]*//')
    fi
    [ -n "$volume" ] && echo "$volume" | sudo tee "$CHARD_ROOT/$CHARD_HOME/.chard_volume" > /dev/null
    echo "$muted" | sudo tee "$CHARD_ROOT/$CHARD_HOME/.chard_muted" > /dev/null
    echo "" | sudo tee "$CHARD_ROOT/$CHARD_HOME/.chard_hdmi" > /dev/null
    echo "" | sudo tee "$CHARD_ROOT/$CHARD_HOME/.chard_bluetooth" > /dev/null
    echo "" | sudo tee "$CHARD_ROOT/$CHARD_HOME/.chard_usb" > /dev/null
    if [ -n "$hdmi" ]; then
        echo "$hdmi" | sudo tee "$CHARD_ROOT/$CHARD_HOME/.chard_hdmi" > /dev/null
    elif [ -n "$bluetooth" ]; then
        echo "$bluetooth" | sudo tee "$CHARD_ROOT/$CHARD_HOME/.chard_bluetooth" > /dev/null
    elif [ -n "$usb" ]; then
        echo "$usb" | sudo tee "$CHARD_ROOT/$CHARD_HOME/.chard_usb" > /dev/null
    fi
    echo "${gain:-}" | sudo tee "$CHARD_ROOT/$CHARD_HOME/.chard_mic_gain" > /dev/null
}
update_volume
dbus-monitor --system "type='signal',interface='org.chromium.cras.Control'" 2>/dev/null | \
while read -r line; do
    if echo "$line" | grep -q "signal"; then
        update_volume
    fi
done
