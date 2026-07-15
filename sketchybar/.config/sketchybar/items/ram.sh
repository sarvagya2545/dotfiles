#!/bin/bash

sketchybar -m --add item ram_percentage right \
              --set ram_percentage update_freq=2 \
                    icon=""\
                    script="~/.config/sketchybar/plugins/ram.sh"
