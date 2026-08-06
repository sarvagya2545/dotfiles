#!/bin/bash

sketchybar -m --add item ram_percentage right \
              --set ram_percentage update_freq=2 \
                    icon.font="JetBrainsMono Nerd Font:Bold:14.0"\
                    icon=""\
                    script="~/.config/sketchybar/plugins/ram.sh"
