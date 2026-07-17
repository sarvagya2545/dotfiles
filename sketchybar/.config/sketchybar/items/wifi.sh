#!/bin/bash

POPUP_BG="0xe61c1c1c"
POPUP_BORDER="0xff3a3a3c"

sketchybar --add item wifi right \
           --set wifi script="$PLUGIN_DIR/wifi.sh" \
                 icon.font="SF Pro:Bold:14.0" \
                 label.drawing=off \
                 padding_left=0 \
                 padding_right=0 \
                 icon.padding_left=8 \
                 icon.padding_right=8 \
                 background.drawing=off \
                 click_script="sketchybar --set wifi popup.drawing=toggle" \
                 popup.background.color=$POPUP_BG \
                 popup.background.corner_radius=10 \
                 popup.background.border_width=1 \
                 popup.background.border_color=$POPUP_BORDER \
                 popup.background.shadow.color=0x40000000 \
                 popup.background.shadow.distance=4 \
                 popup.drawing=off \
                 update_freq=15 \
           --subscribe wifi wifi_change

# Pre-create 19 popup child items
# Slot 1:            Status header
# Slots 2-16:        Available networks (15 max)
# Slot 17:           Separator
# Slot 18:           Toggle WiFi on/off
# Slot 19:           WiFi Settings link
WIFI_SLOTS=19
for i in $(seq 1 $WIFI_SLOTS); do
  sketchybar --add item wifi.slot.$i popup.wifi \
             --set wifi.slot.$i \
                   icon.font="SF Pro:Regular:13.0" \
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

# Slot 17: Separator — thin line
sketchybar --set wifi.slot.17 \
           background.drawing=on \
           background.color=$POPUP_BORDER \
           background.height=1 \
           padding_left=8 \
           padding_right=8 \
           icon.drawing=off \
           label.drawing=off

# Slot 18: Toggle — accent color
sketchybar --set wifi.slot.18 \
           icon.drawing=off \
           label.color=$ACCENT_COLOR

# Slot 19: Preferences — accent color
sketchybar --set wifi.slot.19 \
           icon.drawing=off \
           label.color=$ACCENT_COLOR
