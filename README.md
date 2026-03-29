# Outloud

Voice summaries for Claude Code. Hear what Claude just did — spoken aloud after every response.

When Claude finishes responding, Outloud summarizes the response into natural speech and reads it out loud. Great for staying in the loop without staring at the screen.

## How it works

1. Claude finishes a response
2. The response is summarized into 2-3 natural sentences (using Claude Haiku)
3. The summary is spoken aloud via OpenAI TTS (or macOS `say` as fallback)

## Install

<details>
<summary>Via Claude Code (copy & paste)</summary>

> Install the Outloud voice summaries plugin for Claude Code. Run the slash command `/plugin marketplace add PauAbellaMolina/Outloud` and then `/plugin install outloud@PauAbellaMolina/Outloud`. After installing, give me a summary of how to use it: the plugin speaks a voice summary after every response, I can stop speech with `! shh`, control speed with `! outloud faster` / `! outloud slower`, and optionally set up an OpenAI API key in `~/.config/outloud.env` for a much better voice.

</details>

<details>
<summary>Manual</summary>

```
/plugin marketplace add PauAbellaMolina/Outloud
/plugin install outloud@PauAbellaMolina/Outloud
```

</details>

## Better voice (optional)

For a much better voice, get an API key at [platform.openai.com/api-keys](https://platform.openai.com/api-keys) (add $5 in credits so TTS works).

<details>
<summary>Via Claude Code (copy & paste)</summary>

> Set up Outloud with OpenAI TTS for better voice quality. My OpenAI API key is: `sk-YOUR-KEY-HERE`. Create the config file at `~/.config/outloud.env` with my key as `OPENAI_API_KEY` and set `OUTLOUD_SPEED=1.5`. After setting it up, let me know it's done and remind me I can adjust speed with `! outloud faster` / `! outloud slower` or by editing `~/.config/outloud.env`.

</details>

<details>
<summary>Manual</summary>

```bash
mkdir -p ~/.config && cat > ~/.config/outloud.env << 'EOF'
OPENAI_API_KEY=your-key-here
OUTLOUD_SPEED=1.5
EOF
```

</details>

### Settings

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
