#!/bin/bash

# Outloud — Stop speaking immediately

PID_FILE="/tmp/outloud-say.pid"
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID" 2>/dev/null
    fi
    rm -f "$PID_FILE"
fi

# Also kill any stray say processes from outloud
pkill -f "say -v Samantha" 2>/dev/null

exit 0
