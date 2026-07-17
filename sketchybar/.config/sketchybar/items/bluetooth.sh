#!/bin/bash

POPUP_BG="0xe61c1c1c"
POPUP_BORDER="0xff3a3a3c"

# Bluetooth item — replaces the old alias to "Control Center,Bluetooth"
# Uses JetBrainsMono Nerd Font for icon (no SF Symbol exists for bluetooth)
sketchybar --add item bluetooth right \
           --set bluetooth script="$PLUGIN_DIR/bluetooth.sh" \
                 icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
                 icon="$BT_ON" \
                 label.drawing=off \
                 padding_left=0 \
                 padding_right=0 \
                 icon.padding_left=8 \
                 icon.padding_right=8 \
                 background.drawing=off \
                 click_script="$PLUGIN_DIR/bluetooth.sh; sketchybar --set bluetooth popup.drawing=toggle" \
                 popup.background.color=$POPUP_BG \
                 popup.background.corner_radius=10 \
                 popup.background.border_width=1 \
                 popup.background.border_color=$POPUP_BORDER \
                 popup.background.shadow.color=0x40000000 \
                 popup.background.shadow.distance=4 \
                 popup.drawing=off

# Pre-create 15 popup child items
# Slot 1:           Status header (connected device name or "No Devices")
# Slots 2-12:       Device list (connected first, then paired)
# Slot 13:          Separator
# Slot 14:          Toggle Bluetooth on/off
# Slot 15:          Bluetooth Settings link
BT_SLOTS=15
for i in $(seq 1 $BT_SLOTS); do
  sketchybar --add item bluetooth.slot.$i popup.bluetooth \
             --set bluetooth.slot.$i \
                   icon.font="JetBrainsMono Nerd Font:Bold:13.0" \
                   icon.color=$WHITE \
                   label.font="SF Pro:Regular:13.0" \
                   label.color=$WHITE \
                   background.drawing=off \
                   padding_left=12 \
                   padding_right=12 \
                   icon.padding_left=4 \
                   icon.padding_right=4 \
                   label.padding_left=4 \
                   label.padding_right=4 \
                   label.y_offset=-1
done

# Slot 13: Separator — thin line
sketchybar --set bluetooth.slot.13 \
           background.drawing=on \
           background.color=$POPUP_BORDER \
           background.height=1 \
           padding_left=8 \
           padding_right=8 \
           icon.drawing=off \
           label.drawing=off

# Slot 14: Toggle — accent color
sketchybar --set bluetooth.slot.14 \
           icon.drawing=off \
           label.color=$ACCENT_COLOR

# Slot 15: Preferences — accent color
sketchybar --set bluetooth.slot.15 \
           icon.drawing=off \
           label.color=$ACCENT_COLOR
