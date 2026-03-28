# Outloud

Voice summaries for Claude Code. Hear what Claude just did — spoken aloud after every response.

When Claude finishes responding, Outloud summarizes the response into natural speech and reads it out loud. Great for staying in the loop without staring at the screen.

## How it works

1. Claude finishes a response
2. The response is summarized into 3-5 natural sentences (using Claude Haiku)
3. The summary is spoken aloud via OpenAI TTS (or macOS `say` as fallback)

Speech is automatically interrupted when you send your next message, or when a new response arrives.

## Requirements

- macOS
- Claude Code CLI
- `jq` — a lightweight JSON parser (`brew install jq`)

## Install

```
/plugin marketplace add PauAbellaMolina/Outloud
/plugin install outloud@PauAbellaMolina/Outloud
```

## Configuration

All settings go in `~/.config/outloud.env`:

```bash
mkdir -p ~/.config && cat > ~/.config/outloud.env << 'EOF'
OPENAI_API_KEY=your-key-here
OUTLOUD_SPEED=1.5
EOF
```

| Setting | Description | Default |
|---------|-------------|---------|
| `OPENAI_API_KEY` | OpenAI API key for high-quality TTS. Without it, falls back to macOS `say`. Get one at [platform.openai.com/api-keys](https://platform.openai.com/api-keys) | — |
| `OUTLOUD_SPEED` | Playback speed for OpenAI TTS (1.0 = normal, 2.0 = 2x fast) | `1.5` |
| `OUTLOUD_SAY_RATE` | Words per minute for macOS `say` fallback | `210` |

## Uninstall

```
/plugin uninstall outloud
/plugin marketplace remove PauAbellaMolina/Outloud
```

## Stopping speech

Send any new message to Claude and the voice stops automatically. You can also run:

```
! pkill say
```

## Logs

Logs are written to `/tmp/outloud.log` for debugging.
