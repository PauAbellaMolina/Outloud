#!/bin/bash

# Outloud — Voice summaries for Claude Code

LOG_FILE="/tmp/outloud.log"
log() { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG_FILE"; }

log "=== Hook fired (v1.9.0) ==="

# Load config (OpenAI API key)
CONFIG_FILE="$HOME/.config/outloud.env"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Prevent recursive calls — claude -p triggers Stop hooks too
LOCK_FILE="/tmp/outloud.lock"
if [ -f "$LOCK_FILE" ]; then
    if [ "$(find "$LOCK_FILE" -mmin +1 2>/dev/null)" ]; then
        log "Removing stale lock"
        rm -f "$LOCK_FILE"
    else
        log "Skipping (recursive call)"
        exit 0
    fi
fi

# Ensure lock is always cleaned up, even on crash
cleanup() { rm -f "$LOCK_FILE"; }
trap cleanup EXIT

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
    log "Starting Haiku summarization..."
    SUMMARY=$(echo "You convert a coding AI's response into something that can be spoken aloud. No markdown, no code, no bullet points, no asterisks — just natural speech.

Rules:
- If Claude is ASKING A QUESTION or waiting for user input, always clearly state the question. This is the most important thing to communicate — the user needs to know what they're being asked.
- If Claude presents a PLAN, briefly list the key steps (one sentence each) and end with whatever question or confirmation Claude is asking.
- If the response is short or conversational (greetings, confirmations, simple answers), just repeat it nearly verbatim. Do NOT over-explain or analyze it.
- If the response describes code changes or technical work, give a brief natural summary of what was done in 2-3 sentences.

Here's what Claude said:
${RESPONSE:0:4000}" | "$CLAUDE_BIN" -p --model haiku 2>/dev/null || true)
    log "Haiku done: ${SUMMARY:0:200}"
fi

# Fallback: first two sentences
if [ -z "$SUMMARY" ]; then
    SUMMARY=$(echo "$RESPONSE" | sed 's/[#*`_~]//g' | tr '\n' ' ' | sed 's/  */ /g' | grep -oE '^[^.!?]*[.!?]' | head -2 | tr '\n' ' ' || true)
    [ -z "$SUMMARY" ] && SUMMARY="${RESPONSE:0:300}"
fi

log "Speaking: $SUMMARY"

# Playback speed (configurable via OUTLOUD_SPEED in ~/.config/outloud.env)
SPEED="${OUTLOUD_SPEED:-1.5}"
SAY_RATE="${OUTLOUD_SAY_RATE:-210}"

# Speak using OpenAI TTS if API key is available, otherwise fall back to macOS say
AUDIO_FILE="/tmp/outloud-speech.wav"

if [ -n "$OPENAI_API_KEY" ]; then
    log "Starting OpenAI TTS..."
    HTTP_CODE=$(curl -s -o "$AUDIO_FILE" -w "%{http_code}" \
        https://api.openai.com/v1/audio/speech \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg text "$SUMMARY" '{
            model: "tts-1",
            voice: "nova",
            input: $text,
            response_format: "wav"
        }')" 2>/dev/null)

    log "OpenAI TTS done (HTTP $HTTP_CODE)"
    if [ "$HTTP_CODE" = "200" ] && [ -s "$AUDIO_FILE" ]; then
        afplay -r "$SPEED" "$AUDIO_FILE" 2>/dev/null &
    else
        log "OpenAI TTS failed (HTTP $HTTP_CODE), falling back to say"
        say -v Samantha -r "$SAY_RATE" "$SUMMARY" 2>/dev/null &
    fi
else
    log "No OPENAI_API_KEY, using macOS say"
    say -v Samantha -r "$SAY_RATE" "$SUMMARY" 2>/dev/null &
fi

exit 0
