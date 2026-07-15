#!/bin/bash
MPC=/opt/local/bin/mpc
JQ=/usr/local/bin/jq
SRC_FILE=/tmp/sketchybar_media_source

STATE="$($MPC status '%state%' 2>/dev/null)"

if [ "$STATE" = "playing" ]; then
  # mpd playing: it takes priority
  TITLE="$($MPC -f '%title%' current)"
  ARTIST="$($MPC -f '%artist%' current)"
  [ -n "$ARTIST" ] && MEDIA="$TITLE - $ARTIST" || MEDIA="$TITLE"
  echo "mpd" > "$SRC_FILE"
  sketchybar --set "$NAME" label="$MEDIA" drawing=on

elif [ "$SENDER" = "media_change" ]; then
  # system event (browser, Music.app, ...)
  SYS_STATE="$(echo "$INFO" | $JQ -r '.state')"
  if [ "$SYS_STATE" = "playing" ]; then
    MEDIA="$(echo "$INFO" | $JQ -r '.title + " - " + .artist')"
    echo "system" > "$SRC_FILE"
    sketchybar --set "$NAME" label="$MEDIA" drawing=on
  else
    echo "none" > "$SRC_FILE"
    sketchybar --set "$NAME" drawing=off
  fi

else
  # Timer tick, mpd not playing.
  # Only clear the label if mpd was the one who set it.
  if [ "$(cat "$SRC_FILE" 2>/dev/null)" = "mpd" ]; then
    echo "none" > "$SRC_FILE"
    sketchybar --set "$NAME" drawing=off
  fi
  # If "system" owns it, leave it alone — media_change will manage it.
fi

# #!/bin/bash
#
# STATE="$(echo "$INFO" | jq -r '.state')"
# echo "$(date) INFO=$INFO" >> /tmp/media_debug.log
# if [ "$STATE" = "playing" ]; then
#   MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist')"
#   sketchybar --set $NAME label="$MEDIA" drawing=on
# else
#   sketchybar --set $NAME drawing=off
# fi
