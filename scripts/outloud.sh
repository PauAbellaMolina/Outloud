#!/bin/bash

# Outloud CLI — configure outloud from the terminal

CONFIG_FILE="$HOME/.config/outloud.env"
mkdir -p "$(dirname "$CONFIG_FILE")"
touch "$CONFIG_FILE"

# Read current speed
get_speed() {
    grep 'OUTLOUD_SPEED=' "$CONFIG_FILE" 2>/dev/null | tail -1 | sed 's/OUTLOUD_SPEED=//' || echo "1.5"
}

set_speed() {
    if grep -q "OUTLOUD_SPEED=" "$CONFIG_FILE" 2>/dev/null; then
        sed -i '' "s/OUTLOUD_SPEED=.*/OUTLOUD_SPEED=$1/" "$CONFIG_FILE"
    else
        echo "OUTLOUD_SPEED=$1" >> "$CONFIG_FILE"
    fi
    echo "Outloud speed set to ${1}x"
}

# If called as "shh", just shutup immediately
if [ "$(basename "$0")" = "shh" ]; then
    pkill -f "say -v Samantha" 2>/dev/null
    pkill -f "afplay /tmp/outloud-speech" 2>/dev/null
    exit 0
fi

case "${1:-help}" in
    faster)
        CURRENT=$(get_speed)
        NEW=$(echo "$CURRENT + 0.25" | bc)
        set_speed "$NEW"
        ;;
    slower)
        CURRENT=$(get_speed)
        NEW=$(echo "$CURRENT - 0.25" | bc)
        # Don't go below 0.5
        if (( $(echo "$NEW < 0.5" | bc -l) )); then NEW="0.5"; fi
        set_speed "$NEW"
        ;;
    speed)
        if [ -n "$2" ]; then
            set_speed "$2"
        else
            echo "Current speed: $(get_speed)x"
        fi
        ;;
    shutup|stop)
        pkill -f "say -v Samantha" 2>/dev/null
        pkill -f "afplay /tmp/outloud-speech" 2>/dev/null
        echo "Outloud silenced"
        ;;
    help|*)
        echo "Usage: outloud <command>"
        echo ""
        echo "  faster        Increase speed by 0.25x"
        echo "  slower        Decrease speed by 0.25x"
        echo "  speed [N]     Get or set speed (e.g. outloud speed 1.8)"
        echo "  shutup        Stop speaking immediately"
        ;;
esac
