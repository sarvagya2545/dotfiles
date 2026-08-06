#!/bin/bash

POPUP_CLICK_SCRIPT="sketchybar --set $NAME popup.drawing=toggle"

sketchybar --add alias  "Control Centre,WiFi" right                      \
           --rename     "Control Centre,WiFi" wifi.alias                 \
           --set        wifi.alias    icon.drawing=off                   \
                                      label.drawing=off \
                                      alias.color="$WHITE"              \
                                      padding_left=0 \
                                      padding_right=0 \
                                      icon.padding_left=8 \
                                      icon.padding_right=8 \
                                      click_script="$POPUP_CLICK_SCRIPT" \
                                      script="$PLUGIN_DIR/wifi.sh"       \
                                      update_freq=1                      \
                                      popup.background.border_width=2   \
                                      popup.background.border_color="$ACCENT_COLOR" \
                                      popup.background.corner_radius=8  \
                                      popup.background.color="$ITEM_BG_COLOR" \
           --subscribe  wifi.alias    mouse.entered                      \
                                      mouse.exited                       \
                                      mouse.exited.global                \
                                                                         \
            --add       item          wifi.details popup.wifi.alias      \
            --set       wifi.details  background.corner_radius=5        \
                                      background.padding_left=10          \
                                      background.padding_right=10        \
                                      icon.drawing=off \
                                      label.align=center                 \
                                      click_script="sketchybar --set wifi.alias popup.drawing=off"
