# Outloud

Voice summaries for Claude Code. Hear what Claude just did — spoken aloud after every response.

When Claude finishes responding, Outloud summarizes the response into natural speech and reads it out loud. Great for staying in the loop without staring at the screen.

## How it works

1. Claude finishes a response
2. The response is summarized into 3-5 natural sentences (using Claude Haiku)
3. The summary is spoken aloud via macOS `say`

Speech is automatically interrupted when you send your next message, or when a new response arrives.

## Requirements

- macOS (uses the built-in `say` command)
- Claude Code CLI
- `jq` installed (`brew install jq`)

## Install

```
/plugin marketplace add PauAbellaMolina/Outloud
/plugin install outloud@PauAbellaMolina/Outloud
```

## Uninstall

```
/plugin uninstall outloud
/plugin marketplace remove PauAbellaMolina/Outloud
```

## Stopping speech manually

Send any new message to Claude and the voice stops automatically. You can also run:

```
! pkill say
```

## Logs

Logs are written to `/tmp/outloud.log` for debugging.
