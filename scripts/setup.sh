#!/bin/bash

# Outloud — Auto-setup on session start
# Symlinks the outloud CLI to ~/.local/bin if not already there

mkdir -p "$HOME/.local/bin"

SOURCE="${CLAUDE_PLUGIN_ROOT}/scripts/outloud.sh"
ln -sf "$SOURCE" "$HOME/.local/bin/outloud"
ln -sf "$SOURCE" "$HOME/.local/bin/shh"
