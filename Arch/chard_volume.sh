#!/bin/bash
get_volume() {
    output=$(cras_test_client)
    volume=$(echo "$output" | grep "Output Nodes:" -A 20 | grep "yes" | grep "INTERNAL_SPEAKER" | awk '{print $3}')
    echo "$volume"
}

update_volume() {
    volume=$(get_volume)
    if [ ! -z "$volume" ]; then
        echo "$volume" > ~/MyFiles/Downloads/chard_volume
        echo "Volume updated: $volume"
    fi
}

update_volume
dbus-monitor --system "type='signal',interface='org.chromium.cras.Control'" 2>/dev/null | \
while read -r line; do
    if echo "$line" | grep -q "signal"; then
        update_volume
    fi
done
