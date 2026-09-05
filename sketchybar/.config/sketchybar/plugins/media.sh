#!/bin/bash

find_bin() {
  local name="$1"; shift
  local p
  for p in "$@"; do
    [ -x "$p" ] && { printf '%s' "$p"; return 0; }
  done
  p="$(command -v "$name" 2>/dev/null)" && { printf '%s' "$p"; return 0; }
  return 1
}

MPC="$(find_bin mpc /opt/local/bin/mpc /opt/homebrew/bin/mpc /usr/local/bin/mpc)"
JQ="$(find_bin jq /opt/homebrew/bin/jq /usr/local/bin/jq /opt/local/bin/jq /usr/bin/jq)"
MC="$(find_bin media-control /opt/homebrew/bin/media-control /usr/local/bin/media-control)"

show() {
  local title="$1" artist="$2" media
  if [ -n "$artist" ]; then media="$title - $artist"; else media="$title"; fi
  sketchybar --set "$NAME" label="$media" drawing=on
  exit 0
}

# 1. mpd, if it's installed and playing.
if [ -n "$MPC" ] && [ "$("$MPC" status '%state%' 2>/dev/null)" = "playing" ]; then
  show "$("$MPC" -f '%title%' current 2>/dev/null)" \
       "$("$MPC" -f '%artist%' current 2>/dev/null)"
fi

# 2. media-control, which works on every macOS including 15.4 and later.
if [ -n "$MC" ] && [ -n "$JQ" ]; then
  JSON="$("$MC" get --no-artwork 2>/dev/null)"
  if [ "$(printf '%s' "$JSON" | "$JQ" -r '.playing // empty')" = "true" ]; then
    show "$(printf '%s' "$JSON" | "$JQ" -r '.title // empty')" \
         "$(printf '%s' "$JSON" | "$JQ" -r '.artist // empty')"
  fi
fi

# 3. Old built-in media_change event. Only fires on macOS before 15.4.
if [ "$SENDER" = "media_change" ] && [ -n "$JQ" ]; then
  if [ "$(printf '%s' "$INFO" | "$JQ" -r '.state // empty')" = "playing" ]; then
    show "$(printf '%s' "$INFO" | "$JQ" -r '.title // empty')" \
         "$(printf '%s' "$INFO" | "$JQ" -r '.artist // empty')"
  fi
fi

# Nothing playing anywhere.
sketchybar --set "$NAME" drawing=off
