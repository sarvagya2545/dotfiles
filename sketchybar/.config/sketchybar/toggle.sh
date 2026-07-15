#!/usr/bin/env bash

BAR_HEIGHT=37
export PATH="/opt/homebrew/bin:/usr/local/bin:/opt/local/bin:$PATH"

# Check if SketchyBar is currently hidden
hidden=$(sketchybar --query bar | jq -r '.hidden')

if [ "$hidden" = "on" ]; then
    # Show bar
    sketchybar --bar hidden=off
    yabai -m config external_bar "all:$BAR_HEIGHT:0"
else
    # Hide bar
    sketchybar --bar hidden=on
    yabai -m config external_bar all:0:0
fi
