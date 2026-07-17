#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

WIFI_INTERFACE=$(networksetup -listallhardwareports 2>/dev/null \
  | awk '/Wi-Fi|AirPort/{getline; print $2}')

CURRENT=$(networksetup -getairportpower "$WIFI_INTERFACE" 2>/dev/null | awk '{print $NF}')

sketchybar --set wifi popup.drawing=off

if [ "$CURRENT" = "On" ]; then
  networksetup -setairportpower "$WIFI_INTERFACE" off
else
  networksetup -setairportpower "$WIFI_INTERFACE" on
fi
