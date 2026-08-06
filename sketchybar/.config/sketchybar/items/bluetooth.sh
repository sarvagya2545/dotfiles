#!/usr/bin/env bash

# A reload wipes the popup's device items; clear the cache so the
# plugin rebuilds them instead of thinking nothing changed.
rm -f /tmp/sketchybar_bluetooth_paired

bluetooth_alias=(
	icon.drawing=off
    label.drawing=off
	alias.color="$WHITE"
    padding_left=0 \
    padding_right=0 \
    icon.padding_left=8 \
    icon.padding_right=8 \
	click_script="$CLICK_SCRIPTS_DIR/bluetooth_click.sh"
	script="$PLUGIN_DIR/bluetooth.sh"
	popup.height=30
	update_freq=5
	popup.background.border_width=2
	popup.background.border_color="$ACCENT_COLOR"
	popup.background.corner_radius=8
	popup.background.color="$ITEM_BG_COLOR"
)

bluetooth_details=(
	background.corner_radius=5
	background.padding_left=10
	background.padding_right=10
	icon.drawing=off
	label.align=center
)

sketchybar --add alias  "Control Centre,Bluetooth" right                                    \
           --rename     "Control Centre,Bluetooth" bluetooth.alias                          \
           --set        bluetooth.alias  "${bluetooth_alias[@]}"                            \
           --subscribe  bluetooth.alias  mouse.entered                                      \
                                         mouse.exited                                       \
                                         mouse.exited.global                                \
                                                                                            \
            --add       item              bluetooth.details popup.bluetooth.alias           \
            --set       bluetooth.details "${bluetooth_details[@]}"                         \
                                          click_script="sketchybar --set bluetooth.alias popup.drawing=off"
