#!/bin/bash

# Outloud — Stop speaking for the current session only

# Read hook input to get session ID
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null || true)

if [ -n "$SESSION_ID" ]; then
    SHORT_ID="${SESSION_ID:0:8}"
    PID_FILE="/tmp/outloud-say-${SHORT_ID}.pid"
    if [ -f "$PID_FILE" ]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null
        rm -f "$PID_FILE"
    fi
else
    # No session ID — fall back to killing all outloud speech
    PID_FILE="/tmp/outloud-say.pid"
    if [ -f "$PID_FILE" ]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null
        rm -f "$PID_FILE"
    fi
    pkill -f "say -v Samantha" 2>/dev/null
    pkill -f "afplay /tmp/outloud-speech" 2>/dev/null
fi

exit 0
