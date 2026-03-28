#!/bin/bash

# Outloud — Read elicitations (interactive questions) aloud

LOG_FILE="/tmp/outloud.log"
log() { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG_FILE"; }

log "=== Elicitation fired ==="

# Read hook input (must happen before backgrounding)
INPUT=$(cat)

# Fork everything into background so hook returns immediately
(
    log "Elicitation input: ${INPUT:0:500}"

    # Load config
    CONFIG_FILE="$HOME/.config/outloud.env"
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi

    # Extract the message/question from the elicitation
    MESSAGE=$(echo "$INPUT" | jq -r '.message // .title // .description // empty' 2>/dev/null || true)

    # Extract options if present
    OPTIONS=$(echo "$INPUT" | jq -r '.options // [] | .[] | .label // .value // .' 2>/dev/null 2>/dev/null | head -10 || true)

    if [ -z "$MESSAGE" ] && [ -z "$OPTIONS" ]; then
        log "No elicitation content found"
        exit 0
    fi

    # Build spoken text
    SPOKEN="$MESSAGE"
    if [ -n "$OPTIONS" ]; then
        SPOKEN="$SPOKEN. Options are: $(echo "$OPTIONS" | tr '\n' ',' | sed 's/,/, /g; s/, $//')"
    fi

    log "Speaking elicitation: $SPOKEN"

    # Playback speed
    SPEED="${OUTLOUD_SPEED:-1.5}"
    SAY_RATE="${OUTLOUD_SAY_RATE:-210}"
    AUDIO_FILE="/tmp/outloud-speech.wav"

    if [ -n "$OPENAI_API_KEY" ]; then
        log "Starting OpenAI TTS..."
        HTTP_CODE=$(curl -s -o "$AUDIO_FILE" -w "%{http_code}" \
            https://api.openai.com/v1/audio/speech \
            -H "Authorization: Bearer $OPENAI_API_KEY" \
            -H "Content-Type: application/json" \
            -d "$(jq -n --arg text "$SPOKEN" '{
                model: "tts-1",
                voice: "nova",
                input: $text,
                response_format: "wav"
            }')" 2>/dev/null)

        log "OpenAI TTS done (HTTP $HTTP_CODE)"
        if [ "$HTTP_CODE" = "200" ] && [ -s "$AUDIO_FILE" ]; then
            afplay -r "$SPEED" "$AUDIO_FILE" 2>/dev/null &
        else
            log "OpenAI TTS failed, falling back to say"
            say -v Samantha -r "$SAY_RATE" "$SPOKEN" 2>/dev/null &
        fi
    else
        say -v Samantha -r "$SAY_RATE" "$SPOKEN" 2>/dev/null &
    fi
) &

exit 0
