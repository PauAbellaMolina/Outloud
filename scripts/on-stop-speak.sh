#!/bin/bash

# Outloud — Voice summaries for Claude Code

LOG_FILE="/tmp/outloud.log"
log() { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG_FILE"; }

log "=== Hook fired ==="

# Kill any ongoing speech from a previous response
PID_FILE="/tmp/outloud-say.pid"
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        kill "$OLD_PID" 2>/dev/null
        log "Killed previous say process ($OLD_PID)"
    fi
    rm -f "$PID_FILE"
fi

# Prevent recursive calls — claude -p triggers Stop hooks too
LOCK_FILE="/tmp/outloud.lock"
if [ -f "$LOCK_FILE" ]; then
    log "Skipping (recursive call)"
    exit 0
fi

# Read hook input from stdin
INPUT=$(cat)

# Get response from last_assistant_message or transcript
RESPONSE=$(echo "$INPUT" | jq -r '.last_assistant_message // empty' 2>/dev/null || true)

if [ -z "$RESPONSE" ]; then
    TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || true)
    if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
        RESPONSE=$(tail -200 "$TRANSCRIPT_PATH" | \
            grep -E '"type"\s*:\s*"assistant"' | tail -1 | \
            jq -r '[.message.content[] | select(.type == "text") | .text] | join(" ")' 2>/dev/null || true)
    fi
fi

[ -z "$RESPONSE" ] && { log "No response found"; exit 0; }

# Find claude binary
CLAUDE_BIN=""
for candidate in "$HOME/.local/bin/claude" "$HOME/.claude/local/bin/claude" "/usr/local/bin/claude"; do
    if [ -x "$candidate" ]; then
        CLAUDE_BIN="$candidate"
        break
    fi
done

# Summarize
if [ -n "$CLAUDE_BIN" ]; then
    touch "$LOCK_FILE"
    SUMMARY=$(echo "You are a voice assistant giving a spoken summary of what a coding AI just did. Give a natural, conversational summary in 3-5 sentences — enough to understand the key points without reading the screen. Cover the main concepts or changes, not just the first line. No markdown, no code, no bullet points, no asterisks — just natural flowing speech as if you're explaining it to someone walking next to you.

Here's what Claude said:
${RESPONSE:0:4000}" | "$CLAUDE_BIN" -p --model haiku 2>/dev/null || true)
    rm -f "$LOCK_FILE"
    log "claude summary: ${SUMMARY:0:200}"
fi

# Fallback: first two sentences
if [ -z "$SUMMARY" ]; then
    SUMMARY=$(echo "$RESPONSE" | sed 's/[#*`_~]//g' | tr '\n' ' ' | sed 's/  */ /g' | grep -oE '^[^.!?]*[.!?]' | head -2 | tr '\n' ' ' || true)
    [ -z "$SUMMARY" ] && SUMMARY="${RESPONSE:0:300}"
fi

log "Speaking: $SUMMARY"

# Speak in background so hook returns immediately, track PID for interruption
say -v Samantha -r 200 "$SUMMARY" 2>/dev/null &
echo $! > "$PID_FILE"

exit 0
