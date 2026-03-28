# Outloud

Voice summaries for Claude Code. Hear what Claude just did — spoken aloud after every response.

When Claude finishes responding, Outloud summarizes the response into natural speech and reads it out loud. Great for staying in the loop without staring at the screen.

## How it works

1. Claude finishes a response
2. The response is summarized into 2-3 natural sentences (using Claude Haiku)
3. The summary is spoken aloud via OpenAI TTS (or macOS `say` as fallback)

## Install

```
/plugin marketplace add PauAbellaMolina/Outloud
/plugin install outloud@PauAbellaMolina/Outloud
```

## Better voice (optional)

By default, Outloud uses the built-in macOS `say` voice. For a much better voice, add an OpenAI API key:

```bash
mkdir -p ~/.config && cat > ~/.config/outloud.env << 'EOF'
OPENAI_API_KEY=your-key-here
OUTLOUD_SPEED=1.5
EOF
```

Get a key at [platform.openai.com/api-keys](https://platform.openai.com/api-keys) (add $5 in credits to get started with so TTS works).

You can also configure playback speed in the same file:

| Setting | Description | Default |
|---------|-------------|---------|
| `OPENAI_API_KEY` | Enables high-quality OpenAI TTS voice | — |
| `OUTLOUD_SPEED` | Playback speed for OpenAI TTS (1.0 = normal, 2.0 = 2x fast) | `1.5` |
| `OUTLOUD_SAY_RATE` | Words per minute for macOS `say` fallback | `210` |

## CLI

The `outloud` command is auto-installed on first session. Use it from within Claude Code with `!`:

```
! outloud faster          # Increase speed by 0.25x
! outloud slower          # Decrease speed by 0.25x
! outloud speed 1.8       # Set exact speed
! outloud shutup          # Stop speaking immediately
! shh                     # Shortcut for shutup
```

## Uninstall

```
/plugin uninstall outloud
/plugin marketplace remove PauAbellaMolina/Outloud
```

## Logs

Logs are written to `/tmp/outloud.log` for debugging.
