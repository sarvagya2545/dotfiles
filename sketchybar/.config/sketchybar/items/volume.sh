#!/bin/bash

sketchybar --add item volume right \
           --set volume \
                 label.drawing=off \
                 padding_left=0 \
                 padding_right=0 \
                 icon.padding_left=8 \
                 icon.padding_right=8 \
                 background.drawing=off \
                 script="$PLUGIN_DIR/volume.sh" \
           --subscribe volume volume_change
