#!/bin/bash

get_hdmi() {
    output=$(cras_test_client 2>/dev/null)
    hdmi_line=$(echo "$output" | grep "Output Nodes:" -A 20 | grep "HDMI" | grep "yes" | head -n 1)
    
    if [ -n "$hdmi_line" ]; then
        hdmi_name=$(echo "$hdmi_line" | sed -n 's/.*HDMI[[:space:]]*[0-9]*\*\?//p')
        echo "$hdmi_name"
    fi
}

get_bluetooth() {
    output=$(cras_test_client 2>/dev/null)
    bluetooth_line=$(echo "$output" | grep "Output Nodes:" -A 20 | grep "BLUETOOTH" | grep "yes" | head -n 1)
    
    if [ -n "$bluetooth_line" ]; then
        bluetooth_name=$(echo "$bluetooth_line" | sed -n 's/.*BLUETOOTH[[:space:]]*[0-9]*\*\?//p')
        echo "$bluetooth_name"
    fi
}

get_usb() {
    output=$(cras_test_client 2>/dev/null)
    
    usb_line=$(echo "$output" | grep "Output Nodes:" -A 20 | grep "USB" | grep "yes" | head -n 1)
    
    if [ -n "$usb_line" ]; then
        usb_name=$(echo "$usb_line" | sed -n 's/.*USB[[:space:]]*[0-9]*\*\?//p')
        echo "$usb_name"
    fi
}

get_volume() {
    output=$(cras_test_client 2>/dev/null)
    volume=$(echo "$output" | grep "Output Nodes:" -A 20 | grep "yes" | grep -E "INTERNAL_SPEAKER|HEADPHONE|HDMI|BLUETOOTH" | awk '{print $3}')
    echo "$volume"
}

is_muted() {
    if cras_test_client 2>/dev/null | grep -q "User muted: Muted"; then
        echo "1"
    else
        echo "0"
    fi
}


update_volume() {
    volume=$(get_volume)
    hdmi=$(get_hdmi)
    bluetooth=$(get_bluetooth)
    usb=$(get_usb)
    muted=$(is_muted)

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
    
    if [ -n "$bluetooth" ]; then
        tmp_bluetooth="$CHARD_ROOT/$CHARD_HOME/.chard_bluetooth.tmp"
        echo "$bluetooth" > "$tmp_bluetooth"
        mv "$tmp_bluetooth" "$CHARD_ROOT/$CHARD_HOME/.chard_bluetooth"
    fi

    if [ -n "$usb" ]; then
        tmp_usb="$CHARD_ROOT/$CHARD_HOME/.chard_usb.tmp"
        echo "$usb" > "$tmp_usb"
        mv "$tmp_usb" "$CHARD_ROOT/$CHARD_HOME/.chard_usb"
    fi

    if [ -n "$muted" ]; then
        tmp_muted="$CHARD_ROOT/$CHARD_HOME/.chard_muted.tmp"
        echo "$muted" > "$tmp_muted"
        mv "$tmp_muted" "$CHARD_ROOT/$CHARD_HOME/.chard_muted"
    fi
}

update_volume

dbus-monitor --system "type='signal',interface='org.chromium.cras.Control'" 2>/dev/null | \
while read -r line; do
    if echo "$line" | grep -q "signal"; then
        update_volume
    fi
done
