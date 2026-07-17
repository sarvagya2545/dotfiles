#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

STATE=$(blueutil -p 2>/dev/null)

sketchybar --set bluetooth popup.drawing=off

if [ "$STATE" = "1" ]; then
  blueutil -p 0
else
  blueutil -p 1
fi
