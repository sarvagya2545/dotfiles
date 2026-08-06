#!/bin/bash

sketchybar --add item battery right \
           --set battery update_freq=120 \
                         script="$PLUGIN_DIR/battery.sh" \
                         padding_left=0 \
                         padding_right=0 \
                         icon.padding_left=8 \
                         icon.padding_right=8 \
                         label.drawing=off \
                         background.drawing=off \
           --subscribe battery system_woke power_source_change
