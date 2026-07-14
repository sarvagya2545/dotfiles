#!/usr/bin/env bash

BAR_HEIGHT=45
export PATH="/opt/homebrew/bin:/usr/local/bin:/opt/local/bin:$PATH"

# Check if SketchyBar is currently hidden
hidden=$(sketchybar --query bar | jq -r '.hidden')

if [ "$hidden" = "on" ]; then
    # Show bar
    sketchybar --bar hidden=off
    yabai -m config top_padding "$BAR_HEIGHT"
else
    # Hide bar
    sketchybar --bar hidden=on
    yabai -m config top_padding 0
fi
