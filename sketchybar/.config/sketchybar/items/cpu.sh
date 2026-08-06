#!/bin/bash

sketchybar --add item cpu right \
           --set cpu  update_freq=2 \
                    icon.font="JetBrainsMono Nerd Font:Bold:14.0"\
                      icon=  \
                      script="$PLUGIN_DIR/cpu.sh"
