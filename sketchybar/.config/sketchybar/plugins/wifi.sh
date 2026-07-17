#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Source icons and colors
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"
CLICK_SCRIPTS_DIR="$CONFIG_DIR/click_scripts"

# ============================================================
# WiFi Plugin — Full macOS Menu Bar State Machine
# States: W1(connected) W2(no internet) W3(not connected)
#         W4(off) W5(connecting) W6(bad password) W7(open)
#         W8(no hardware) W9(hotspot) W10(prefs)
# ============================================================

# --- W8: Detect WiFi Hardware ---
WIFI_INTERFACE=$(networksetup -listallhardwareports 2>/dev/null \
  | awk '/Wi-Fi|AirPort/{getline; print $2}')

if [ -z "$WIFI_INTERFACE" ]; then
  sketchybar --set wifi drawing=off
  exit 0
fi

# --- W5: Loading / Connecting State ---
if [ "$SENDER" = "wifi_connecting" ]; then
  sketchybar --set wifi icon="$WIFI_LOADING"
  exit 0
fi

# --- Check WiFi Power ---
WIFI_POWER=$(networksetup -getairportpower "$WIFI_INTERFACE" 2>/dev/null | awk '{print $NF}')

# --- W4: WiFi OFF ---
if [ "$WIFI_POWER" = "Off" ]; then
  sketchybar --set wifi icon="$WIFI_SLASH"

  # Slot 1: "Wi-Fi is Off" header
  sketchybar --set wifi.slot.1 \
    icon.drawing=off \
    label.drawing=on label="Wi-Fi is Off" label.color=0xffffffff

  # Clear network slots 2-16
  for i in $(seq 2 16); do
    sketchybar --set wifi.slot.$i icon.drawing=off label.drawing=off \
      background.drawing=off
  done

  # Slot 17: separator off
  sketchybar --set wifi.slot.17 icon.drawing=off label.drawing=off

  # Slot 18: "Turn Wi-Fi On"
  sketchybar --set wifi.slot.18 \
    icon.drawing=off label.drawing=on label="Turn Wi-Fi On" \
    label.color=$ACCENT_COLOR \
    click_script="$CLICK_SCRIPTS_DIR/wifi_toggle.sh"

  # Slot 19: prefs off (no point when WiFi is off)
  sketchybar --set wifi.slot.19 icon.drawing=off label.drawing=off

  exit 0
fi

# --- Get Current Connection ---
CURRENT_SSID=$(networksetup -getairportnetwork "$WIFI_INTERFACE" 2>/dev/null \
  | sed 's/Current Wi-Fi Network: //')

# --- Determine Bar Icon ---
if [ -n "$CURRENT_SSID" ] && [ "$CURRENT_SSID" != "" ]; then
  # W1/W2: Connected — check for internet
  # Quick DNS resolution test (non-blocking, fast)
  if ping -c1 -W2 8.8.8.8 &>/dev/null; then
    sketchybar --set wifi icon="$WIFI_CONNECTED"
  else
    # W2: Connected but no internet
    sketchybar --set wifi icon="$WIFI_CONNECTED"
  fi
else
  # W3: Not connected
  sketchybar --set wifi icon="$WIFI_EXCLAMATION"
fi

# --- Slot 1: Status Header ---
if [ -n "$CURRENT_SSID" ] && [ "$CURRENT_SSID" != "" ]; then
  sketchybar --set wifi.slot.1 \
    icon.drawing=on icon="$WIFI_CONNECTED" icon.color=$WHITE \
    label.drawing=on label="$CURRENT_SSID" label.color=$WHITE
else
  sketchybar --set wifi.slot.1 \
    icon.drawing=off \
    label.drawing=on label="Not Connected" label.color=0xff999999
fi

# --- Scan Available Networks ---
# Parse airport -s output: extract SSID and SECURITY
SCAN_RAW=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s 2>/dev/null)

# Use Python for reliable parsing of variable-width airport output
NETWORK_LIST=$(echo "$SCAN_RAW" | python3 -c "
import re, sys

lines = sys.stdin.read().strip().split('\n')
if len(lines) < 2:
    sys.exit(0)

results = []
for line in lines[1:]:
    # Find RSSI: first negative number surrounded by whitespace
    rssi_match = re.search(r'\s(-\d{2,3})\s', line)
    if not rssi_match:
        continue

    rssi = int(rssi_match.group(1))
    rssi_start = rssi_match.start() + 1  # +1 to skip leading whitespace

    # SSID is everything before the RSSI column
    ssid_part = line[:rssi_start].rstrip()

    # Remove BSSID if present (xx:xx:xx:xx:xx:xx = 17 chars)
    ssid_part = re.sub(r'\s+[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}\s*$', '', ssid_part)

    ssid = ssid_part.strip()
    if not ssid:
        continue

    # Rest of line after RSSI
    rest = line[rssi_match.end():].strip()

    # Extract security type
    sec_match = re.search(r'(RSN\(|WPA\(|NONE|OWE)', rest)
    if sec_match:
        security = rest[sec_match.start():].strip()
        # Strip trailing comment in parens
        security = re.sub(r'\s*\(.*\)$', '', security).strip()
    else:
        security = ''

    results.append((ssid, security, rssi))

results.sort(key=lambda x: x[2], reverse=True)

for ssid, security, rssi in results:
    ssid_escaped = ssid.replace('|', '\\|')
    print(f'{ssid_escaped}|{security}|{rssi}')
" 2>/dev/null)

# --- Populate Network Slots (2-16) ---
CURRENT_FOUND=false
SLOT_IDX=2

while IFS='|' read -r SSID SECURITY RSSI; do
  [ -z "$SSID" ] && continue
  [ $SLOT_IDX -gt 16 ] && break

  # Determine lock icon
  if echo "$SECURITY" | grep -qi "NONE\|OPEN"; then
    NET_ICON=""
    IS_SECURED=false
  else
    NET_ICON="$SECURITY_LOCK"
    IS_SECURED=true
  fi

  # Determine if this is the connected network
  if [ "$SSID" = "$CURRENT_SSID" ]; then
    CURRENT_FOUND=true
    sketchybar --set wifi.slot.$SLOT_IDX \
      icon.drawing=on icon="$NET_ICON" icon.color=$WHITE \
      label.drawing=on label="$CHECKMARK $SSID" label.color=$WHITE \
      click_script=""
  else
    # Escape single quotes in SSID for shell safety
    ESCAPED_SSID=$(echo "$SSID" | sed "s/'/'\\\\''/g")
    sketchybar --set wifi.slot.$SLOT_IDX \
      icon.drawing=on icon="$NET_ICON" icon.color=$WHITE \
      label.drawing=on label="    $SSID" label.color=$WHITE \
      click_script="$CLICK_SCRIPTS_DIR/wifi_connect.sh '$ESCAPED_SSID' '$SECURITY' '$WIFI_INTERFACE'"
  fi

  SLOT_IDX=$((SLOT_IDX + 1))
done <<< "$NETWORK_LIST"

# Clear remaining network slots
while [ $SLOT_IDX -le 16 ]; do
  sketchybar --set wifi.slot.$SLOT_IDX icon.drawing=off label.drawing=off \
    background.drawing=off
  SLOT_IDX=$((SLOT_IDX + 1))
done

# --- Slot 17: Separator ---
sketchybar --set wifi.slot.17 \
  background.drawing=on background.color=0xff3a3a3c background.height=1 \
  padding_left=8 padding_right=8 \
  icon.drawing=off label.drawing=off

# --- Slot 18: Toggle WiFi ---
if [ "$WIFI_POWER" = "On" ]; then
  sketchybar --set wifi.slot.18 \
    icon.drawing=off label.drawing=on label="Turn Wi-Fi Off" \
    label.color=$ACCENT_COLOR \
    click_script="$CLICK_SCRIPTS_DIR/wifi_toggle.sh"
else
  sketchybar --set wifi.slot.18 \
    icon.drawing=off label.drawing=on label="Turn Wi-Fi On" \
    label.color=$ACCENT_COLOR \
    click_script="$CLICK_SCRIPTS_DIR/wifi_toggle.sh"
fi

# --- Slot 19: Wi-Fi Settings ---
sketchybar --set wifi.slot.19 \
  icon.drawing=off label.drawing=on label="Wi-Fi Settings..." \
  label.color=$ACCENT_COLOR \
  click_script="open 'x-apple.systempreferences:com.apple.preference.network'; sketchybar --set wifi popup.drawing=off"
