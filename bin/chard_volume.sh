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
    usb_node=$(echo "$output" | grep "Output Nodes:" -A 20 | grep "USB" | grep "yes" | head -n 1)
    
    if [ -n "$usb_node" ]; then
        device_id=$(echo "$usb_node" | awk '{print $2}' | cut -d':' -f1)
        usb_name=$(echo "$output" | grep "Output Devices:" -A 50 | grep "^[[:space:]]*${device_id}[[:space:]]" | awk '{$1=$2=$3=""; print $0}' | sed 's/^[[:space:]]*//')
        
        if [ -n "$usb_name" ]; then
            echo "$usb_name"
        fi
    fi
}
get_volume() {
    output=$(cras_test_client 2>/dev/null)
    volume=$(echo "$output" | grep "Output Nodes:" -A 20 | grep "yes" | grep -E "INTERNAL_SPEAKER|HEADPHONE|HDMI|BLUETOOTH|USB" | awk '{print $3}')
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
        echo "$volume" > "$CHARD_ROOT/$CHARD_HOME/.chard_volume"
    fi
    
    echo "" > "$CHARD_ROOT/$CHARD_HOME/.chard_hdmi"
    echo "" > "$CHARD_ROOT/$CHARD_HOME/.chard_bluetooth"
    echo "" > "$CHARD_ROOT/$CHARD_HOME/.chard_usb"
    
    if [ -n "$hdmi" ]; then
        echo "$hdmi" > "$CHARD_ROOT/$CHARD_HOME/.chard_hdmi"
    elif [ -n "$bluetooth" ]; then
        echo "$bluetooth" > "$CHARD_ROOT/$CHARD_HOME/.chard_bluetooth"
    elif [ -n "$usb" ]; then
        echo "$usb" > "$CHARD_ROOT/$CHARD_HOME/.chard_usb"
    fi
    
    if [ -n "$muted" ]; then
        echo "$muted" > "$CHARD_ROOT/$CHARD_HOME/.chard_muted"
    fi
}

for file in .chard_volume .chard_hdmi .chard_bluetooth .chard_usb .chard_muted; do
    [ ! -f "$CHARD_ROOT/$CHARD_HOME/$file" ] && touch "$CHARD_ROOT/$CHARD_HOME/$file"
done

update_volume
dbus-monitor --system "type='signal',interface='org.chromium.cras.Control'" 2>/dev/null | \
while read -r line; do
    if echo "$line" | grep -q "signal"; then
        update_volume
    fi
done
