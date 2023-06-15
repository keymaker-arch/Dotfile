#!/bin/sh

# suspend only if we are in battery mode
file_path="/sys/class/power_supply/ADP1/online"
content=$(cat "$file_path")

if [ "$content" = "0" ]; then
    sudo systemctl suspend
fi
