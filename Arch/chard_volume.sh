#!/bin/bash

get_hdmi() {
    output=$(cras_test_client 2>/dev/null)
    
    hdmi_line=$(echo "$output" | grep "Output Nodes:" -A 20 | grep "HDMI" | grep "yes" | head -n 1)
    
    if [ -n "$hdmi_line" ]; then
        hdmi_name=$(echo "$hdmi_line" | sed -n 's/.*HDMI[[:space:]]*[0-9]*\*\?//p')
        echo "$hdmi_name"
    fi
}

get_volume() {
    output=$(cras_test_client 2>/dev/null)
    volume=$(echo "$output" | grep "Output Nodes:" -A 20 | grep "yes" | grep -E "INTERNAL_SPEAKER|HEADPHONE|HDMI" | awk '{print $3}')
    echo "$volume"
}

update_volume() {
    volume=$(get_volume)
    hdmi=$(get_hdmi)
    
    if [ -n "$volume" ]; then
        tmp="$CHARD_ROOT/$CHARD_HOME/.chard_volume.tmp"
        echo "$volume" > "$tmp"
        mv "$tmp" "$CHARD_ROOT/$CHARD_HOME/.chard_volume"
    fi
    
    if [ -n "$hdmi" ]; then
        tmp_hdmi="$CHARD_ROOT/$CHARD_HOME/.chard_hdmi.tmp"
        echo "$hdmi" > "$tmp_hdmi"
        mv "$tmp_hdmi" "$CHARD_ROOT/$CHARD_HOME/.chard_hdmi"
    fi
}

update_volume

dbus-monitor --system "type='signal',interface='org.chromium.cras.Control'" 2>/dev/null | \
while read -r line; do
    if echo "$line" | grep -q "signal"; then
        update_volume
    fi
done
