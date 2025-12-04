#!/bin/bash
output=$(cras_test_client)
volume=$(echo "$output" | grep "Output Nodes:" -A 20 | grep "yes" | grep "INTERNAL_SPEAKER" | awk '{print $3}')
if [ -z "$volume" ]; then
    echo "Error: Could not find volume value"
fi
echo "$volume" > ~/MyFiles/Downloads/chard_volume
echo "Volume $volume read"
