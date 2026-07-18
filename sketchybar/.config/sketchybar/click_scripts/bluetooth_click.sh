#!/usr/bin/env sh

# sketchybar launches click scripts with a minimal PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:/opt/local/bin:$PATH"

STATE=$(blueutil -p)

if [ "$STATE" = "0" ]; then
	blueutil -p 1
else
	blueutil -p 0
fi
