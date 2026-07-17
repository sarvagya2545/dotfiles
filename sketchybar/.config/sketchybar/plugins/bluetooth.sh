#!/bin/bash

# Source icons and colors
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"
CLICK_SCRIPTS_DIR="$CONFIG_DIR/click_scripts"

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# ============================================================
# Bluetooth Plugin — Full macOS Menu Bar State Machine
# States: B1(connected) B2(no devices) B3(off) B4(connecting)
#         B5(multiple) B6(battery) B7(device types) B8(no hw)
#         B9(prefs)
# ============================================================

# --- B8: Check blueutil availability ---
if ! command -v blueutil &>/dev/null; then
  sketchybar --set bluetooth icon="$BT_ON" icon.font="JetBrainsMono Nerd Font:Bold:14.0" label.drawing=off
  exit 0
fi

# --- B4: Loading / Connecting State ---
if [ "$SENDER" = "bluetooth_connecting" ]; then
  sketchybar --set bluetooth icon="$BT_LOADING" icon.font="JetBrainsMono Nerd Font:Bold:14.0"
  exit 0
fi

# --- Check Bluetooth Power ---
BT_POWER=$(blueutil -p 2>/dev/null)

# --- B3: Bluetooth OFF ---
if [ "$BT_POWER" = "0" ]; then
  sketchybar --set bluetooth icon="$BT_OFF" icon.font="JetBrainsMono Nerd Font:Bold:14.0"

  # Slot 1: "Bluetooth is Off"
  sketchybar --set bluetooth.slot.1 \
    icon.drawing=off \
    label.drawing=on label="Bluetooth is Off" label.color=0xff999999

  # Clear device slots 2-12
  for i in $(seq 2 12); do
    sketchybar --set bluetooth.slot.$i icon.drawing=off label.drawing=off \
      background.drawing=off
  done

  # Slot 13: separator off
  sketchybar --set bluetooth.slot.13 icon.drawing=off label.drawing=off

  # Slot 14: "Turn Bluetooth On"
  sketchybar --set bluetooth.slot.14 \
    icon.drawing=off label.drawing=on label="Turn Bluetooth On" \
    label.color=$ACCENT_COLOR \
    click_script="$CLICK_SCRIPTS_DIR/bluetooth_toggle.sh"

  # Slot 15: prefs off
  sketchybar --set bluetooth.slot.15 icon.drawing=off label.drawing=off

  exit 0
fi

# --- Get Device Data via Python (blueutil + system_profiler merge) ---
DEVICE_DATA=$(python3 << 'PYEOF'
import json, subprocess, sys

# Get paired devices from blueutil (includes connected status)
try:
    paired_raw = subprocess.check_output(
        ["blueutil", "--paired", "--format", "json"],
        stderr=subprocess.DEVNULL, text=True
    )
    paired = json.loads(paired_raw) if paired_raw.strip() else []
except:
    paired = []

# Get device types from system_profiler
sp = {}
device_types = {}
try:
    sp_raw = subprocess.check_output(
        ["system_profiler", "SPBluetoothDataType", "-json", "-detailLevel", "basic"],
        stderr=subprocess.DEVNULL, text=True
    )
    sp = json.loads(sp_raw)
    for section in sp.get("SPBluetoothDataType", []):
        for key in ["device_connected", "device_not_connected"]:
            for dev_entry in section.get(key, []):
                for name, info in dev_entry.items():
                    addr = info.get("device_address", "")
                    minor = info.get("device_minorType", "")
                    if addr:
                        device_types[addr.upper()] = minor
except:
    pass

# Map minorType to Nerd Font icons (JetBrainsMono Nerd Font)
type_icons = {
    "Headphones": chr(0xF02CB),   # nf-md-headphones
    "Headset": chr(0xF02CB),      # nf-md-headphones
    "Keyboard": chr(0xF030C),     # nf-md-keyboard
    "Mouse": chr(0xF037D),        # nf-md-mouse
    "Trackpad": chr(0xF0379),     # nf-md-laptop (closest)
    "Watch": chr(0xF02B3),        # nf-md-watch
    "Phone": chr(0xF00C5),        # nf-md-cellphone
}
default_icon = chr(0xF02AF)  # nf-md-bluetooth

# Build output: connected devices first, then paired-not-connected
connected = []
not_connected = []

for dev in paired:
    addr = dev.get("address", "")
    name = dev.get("name", "Unknown Device")
    is_connected = dev.get("connected", False)
    minor = device_types.get(addr.upper(), "")
    icon = type_icons.get(minor, default_icon)

    entry = f"{addr}|{name}|{icon}"
    if is_connected:
        connected.append(entry)
    else:
        not_connected.append(entry)

# Output: connected first, then not connected
for entry in connected:
    print(f"connected|{entry}")
for entry in not_connected:
    print(f"paired|{entry}")
PYEOF
)

# --- B1/B2: Determine Bar Icon ---
CONNECTED_COUNT=$(echo "$DEVICE_DATA" | grep -c "^connected|" 2>/dev/null || echo "0")

if [ "$CONNECTED_COUNT" -gt 0 ]; then
  # B1/B5: Device(s) connected
  sketchybar --set bluetooth icon="$BT_CONNECTED" icon.font="JetBrainsMono Nerd Font:Bold:14.0"
else
  # B2: No devices connected
  sketchybar --set bluetooth icon="$BT_ON" icon.font="JetBrainsMono Nerd Font:Bold:14.0"
fi

# --- Slot 1: Status Header ---
if [ "$CONNECTED_COUNT" -gt 0 ]; then
  if [ "$CONNECTED_COUNT" -eq 1 ]; then
    FIRST_NAME=$(echo "$DEVICE_DATA" | grep "^connected|" | head -1 | cut -d'|' -f3)
    sketchybar --set bluetooth.slot.1 \
      icon.drawing=on icon="$BT_CONNECTED" icon.font="JetBrainsMono Nerd Font:Bold:13.0" icon.color=$WHITE \
      label.drawing=on label="$FIRST_NAME" label.color=$WHITE
  else
    sketchybar --set bluetooth.slot.1 \
      icon.drawing=on icon="$BT_CONNECTED" icon.font="JetBrainsMono Nerd Font:Bold:13.0" icon.color=$WHITE \
      label.drawing=on label="$CONNECTED_COUNT Devices Connected" label.color=$WHITE
  fi
else
  sketchybar --set bluetooth.slot.1 \
    icon.drawing=off \
    label.drawing=on label="No Devices Connected" label.color=0xff999999
fi

# --- Populate Device Slots (2-12) ---
SLOT_IDX=2

while IFS='|' read -r STATUS ADDR NAME DEVICE_ICON; do
  [ -z "$ADDR" ] && continue
  [ $SLOT_IDX -gt 12 ] && break

  if [ "$STATUS" = "connected" ]; then
    # Connected device — show with checkmark
    sketchybar --set bluetooth.slot.$SLOT_IDX \
      icon.drawing=on icon="$DEVICE_ICON" icon.font="JetBrainsMono Nerd Font:Bold:13.0" icon.color=$WHITE \
      label.drawing=on label="$CHECKMARK $NAME" label.color=$WHITE \
      click_script="$CLICK_SCRIPTS_DIR/bluetooth_click.sh '$ADDR'"
  else
    # Paired but not connected
    sketchybar --set bluetooth.slot.$SLOT_IDX \
      icon.drawing=on icon="$DEVICE_ICON" icon.font="JetBrainsMono Nerd Font:Bold:13.0" icon.color=0xff999999 \
      label.drawing=on label="    $NAME" label.color=0xff999999 \
      click_script="$CLICK_SCRIPTS_DIR/bluetooth_click.sh '$ADDR'"
  fi

  SLOT_IDX=$((SLOT_IDX + 1))
done <<< "$DEVICE_DATA"

# Clear remaining device slots
while [ $SLOT_IDX -le 12 ]; do
  sketchybar --set bluetooth.slot.$SLOT_IDX icon.drawing=off label.drawing=off \
    background.drawing=off
  SLOT_IDX=$((SLOT_IDX + 1))
done

# --- Slot 13: Separator ---
sketchybar --set bluetooth.slot.13 \
  background.drawing=on background.color=0xff3a3a3c background.height=1 \
  padding_left=8 padding_right=8 \
  icon.drawing=off label.drawing=off

# --- Slot 14: Toggle Bluetooth ---
if [ "$BT_POWER" = "1" ]; then
  sketchybar --set bluetooth.slot.14 \
    icon.drawing=off label.drawing=on label="Turn Bluetooth Off" \
    label.color=$ACCENT_COLOR \
    click_script="$CLICK_SCRIPTS_DIR/bluetooth_toggle.sh"
else
  sketchybar --set bluetooth.slot.14 \
    icon.drawing=off label.drawing=on label="Turn Bluetooth On" \
    label.color=$ACCENT_COLOR \
    click_script="$CLICK_SCRIPTS_DIR/bluetooth_toggle.sh"
fi

# --- Slot 15: Bluetooth Settings ---
sketchybar --set bluetooth.slot.15 \
  icon.drawing=off label.drawing=on label="Bluetooth Settings..." \
  label.color=$ACCENT_COLOR \
  click_script="open 'x-apple.systempreferences:com.apple.preference.bluetooth'; sketchybar --set bluetooth popup.drawing=off"
