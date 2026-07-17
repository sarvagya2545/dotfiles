#!/bin/bash

# Source icons and colors
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# ============================================================
# WiFi Connect Script
# Handles: W5(loading) W6(bad password) W7(open network)
# Called with: wifi_connect.sh <SSID> <SECURITY> <INTERFACE>
# ============================================================

SSID="$1"
SECURITY="$2"
INTERFACE="$3"

# Close popup immediately
sketchybar --set wifi popup.drawing=off

# W5: Set loading state on bar icon
sketchybar --set wifi icon="$WIFI_LOADING"

# --- W7: Open Network (no password required) ---
if echo "$SECURITY" | grep -qi "NONE\|OPEN"; then
  RESULT=$(networksetup -setairportnetwork "$INTERFACE" "$SSID" 2>&1)
  RET=$?

  if [ $RET -ne 0 ]; then
    osascript <<DIALOG
display dialog "Could not join the Wi-Fi network \"$SSID\"." ¬
  buttons {"OK"} ¬
  default button "OK" ¬
  with icon stop ¬
  with title "Wi-Fi"
DIALOG
  fi

  sketchybar --trigger wifi_change
  exit 0
fi

# --- W6: Secured Network — Password Dialog with Retry ---
MAX_ATTEMPTS=3

for ATTEMPT in $(seq 1 $MAX_ATTEMPTS); do
  # Show password dialog via osascript
  PASSWORD_RESULT=$(osascript <<DIALOG
try
  set dialogResult to display dialog "Enter the Wi-Fi network password for \"$SSID\"." ¬
    default answer "" ¬
    with hidden text ¬
    with title "Wi-Fi" ¬
    buttons {"Cancel", "Join"} ¬
    default button "Join"
  set password to text returned of dialogResult
  set buttonClicked to button returned of dialogResult
  if buttonClicked is "Join" then
    return password
  else
    return "CANCEL"
  end if
on error number -128
  return "CANCEL"
end try
DIALOG
  )

  # User cancelled
  if [ "$PASSWORD_RESULT" = "CANCEL" ] || [ -z "$PASSWORD_RESULT" ]; then
    sketchybar --trigger wifi_change
    exit 0
  fi

  # Attempt connection
  RESULT=$(networksetup -setairportnetwork "$INTERFACE" "$SSID" "$PASSWORD_RESULT" 2>&1)
  RET=$?

  if [ $RET -eq 0 ]; then
    # Success — connection established
    break
  fi

  # Connection failed
  if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
    # W6: Incorrect password — show error with retry
    RETRY_RESULT=$(osascript <<DIALOG
try
  set dialogResult to display dialog ¬
    "The Wi-Fi network password for \"$SSID\" is incorrect. Please try again." ¬
    buttons {"Cancel", "Try Again"} ¬
    default button "Try Again" ¬
    with icon stop ¬
    with title "Wi-Fi"
  set buttonClicked to button returned of dialogResult
  if buttonClicked is "Try Again" then
    return "RETRY"
  else
    return "CANCEL"
  end if
on error number -128
  return "CANCEL"
end try
DIALOG
    )

    if [ "$RETRY_RESULT" = "CANCEL" ]; then
      sketchybar --trigger wifi_change
      exit 0
    fi
  else
    # Final attempt failed
    osascript <<DIALOG
display dialog ¬
  "Unable to join the network \"$SSID\". The password you entered is incorrect." ¬
  buttons {"OK"} ¬
  default button "OK" ¬
  with icon stop ¬
  with title "Wi-Fi"
DIALOG
  fi
done

# Refresh WiFi state
sketchybar --trigger wifi_change
