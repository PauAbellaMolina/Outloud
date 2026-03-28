#!/bin/bash

# Outloud — Auto-setup on session start
# Symlinks the outloud CLI to ~/.local/bin if not already there

TARGET="$HOME/.local/bin/outloud"
SOURCE="${CLAUDE_PLUGIN_ROOT}/scripts/outloud.sh"

# Skip if already set up and pointing to the right place
if [ -L "$TARGET" ] && [ "$(readlink "$TARGET")" = "$SOURCE" ]; then
    exit 0
fi

mkdir -p "$HOME/.local/bin"
ln -sf "$SOURCE" "$TARGET"
