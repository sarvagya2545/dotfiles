#!/bin/bash
#
# sketchybar -m --add       event              bluetooth_change "com.apple.bluetooth.status"                       \
#                                                                                                                  \
#               --add       item headphones    right                                                               \
#               --set       headphones         icon=󰂯                                                              \
#                                              script="$PLUGIN_DIR/bluetooth.sh"                \
#               --subscribe headphones         bluetooth_change

sketchybar --add alias "Control Center,Bluetooth" right                            \
           --rename "Control Center,Bluetooth" bluetooth                     \
           --set bluetooth icon=󰂯 \
              label.drawing=off                                    \
              alias.color="$WHITE"                                 \
              padding_left=0 \
              padding_right=0 \
              icon.padding_left=8 \
              icon.padding_right=8 \
              align=right                                          \
              click_script="$CLICK_SCRIPTS_DIR/bluetooth_click.sh"
