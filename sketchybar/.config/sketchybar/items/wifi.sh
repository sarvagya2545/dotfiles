#!/bin/bash

sketchybar --add item wifi right \
           --set wifi script="$PLUGIN_DIR/wifi.sh" \
                 label.drawing=off \
                 padding_left=0 \
                 padding_right=0 \
                 icon.padding_left=8 \
                 icon.padding_right=8 \
                 background.drawing=off \
           --subscribe wifi wifi_change
