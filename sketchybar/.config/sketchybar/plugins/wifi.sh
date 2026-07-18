#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

render_bar_item() {
    if [ "$SSID" = "" ]; then
        args+=(--set "$NAME" label="N/A")
    else
        args+=(--set "$NAME"    label="$SSID (${CURR_TX}Mbps)" \
                                label.drawing=off) # remove if you want more detailed info available without hovering
    fi

}

render_popup() {
  LABEL="$SSID"
  if [ "$SSID" = "" ]; then
    LABEL="Not connected"
  fi
  args+=(--set wifi.details label="$LABEL"                            \
                            click_script="sketchybar --set $NAME popup.drawing=off")

  sketchybar -m "${args[@]}" > /dev/null

}

update() {
  CURRENT_WIFI="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)"
  SSID="$(echo "$CURRENT_WIFI" | grep -o "SSID: .*" | sed 's/^SSID: //')"
  CURR_TX="$(echo "$CURRENT_WIFI" | grep -o "lastTxRate: .*" | sed 's/^lastTxRate: //')"

  # Migrate to these when move to mac os 14+
  # SSID="$(networksetup -getairportnetwork en0 | sed 's/^Current Wi-Fi Network: //')"
  # CURR_TX=$(system_profiler SPAirPortDataType | grep "Transmit Rate:" | awk '{print $3}')

  args=()

  render_bar_item
  render_popup
  
  if [ "$SENDER" = "forced" ]; then
    sketchybar --animate tanh 15 --set "$NAME" label.y_offset=5 label.y_offset=0
  fi
}

popup() {
  sketchybar --set "$NAME" popup.drawing="$1"
}

case "$SENDER" in
  "routine"|"forced") update
  ;;
  "mouse.entered") popup on
  ;;
  "mouse.exited"|"mouse.exited.global") popup off
  ;;
  "mouse.clicked") popup toggle
  ;;
esac
