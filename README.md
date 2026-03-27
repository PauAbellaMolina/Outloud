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

## Voice setup

By default, Outloud uses the built-in macOS `say` voice. For much better voice quality, add an OpenAI API key:

```bash
mkdir -p ~/.config && echo "OPENAI_API_KEY=your-key-here" > ~/.config/outloud.env
```

Get your key at [platform.openai.com/api-keys](https://platform.openai.com/api-keys).

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
