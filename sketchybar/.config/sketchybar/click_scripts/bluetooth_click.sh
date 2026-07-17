#!/bin/bash

# Source icons and colors
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# ============================================================
# Bluetooth Click Script — Connect/Disconnect Device
# Handles: B4(connecting state), connection failure dialog
# Called with: bluetooth_click.sh <DEVICE_ADDRESS>
# ============================================================

ADDR="$1"

# Close popup immediately
sketchybar --set bluetooth popup.drawing=off

# B4: Set loading state
sketchybar --set bluetooth icon="$BT_LOADING"

# Check current connection state
IS_CONNECTED=$(blueutil --is-connected "$ADDR" 2>/dev/null)

if [ "$IS_CONNECTED" = "1" ]; then
  # --- Disconnect ---
  blueutil --disconnect "$ADDR" 2>/dev/null
else
  # --- Connect ---
  # blueutil --connect can take several seconds
  blueutil --connect "$ADDR" 2>/dev/null
  CONNECT_EXIT=$?

  # Brief pause to verify connection
  sleep 1
  IS_NOW_CONNECTED=$(blueutil --is-connected "$ADDR" 2>/dev/null)

  if [ "$IS_NOW_CONNECTED" != "1" ]; then
    # Connection failed — get device name for error dialog
    DEV_NAME=$(blueutil --paired --format json 2>/dev/null \
      | python3 -c "
import json, sys
for d in json.load(sys.stdin):
    if d.get('address','') == '$ADDR':
        print(d.get('name','the device'))
        break
" 2>/dev/null)

    [ -z "$DEV_NAME" ] && DEV_NAME="the device"

    osascript <<DIALOG
display dialog ¬
  "Unable to connect to \"$DEV_NAME\". Make sure the device is charged, in range, and discoverable." ¬
  buttons {"OK"} ¬
  default button "OK" ¬
  with icon stop ¬
  with title "Bluetooth"
DIALOG
  fi
fi

# Refresh Bluetooth state
sketchybar --trigger bluetooth_change
