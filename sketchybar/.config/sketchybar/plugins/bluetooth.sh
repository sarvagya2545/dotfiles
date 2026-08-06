#!/usr/bin/env bash

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

# sketchybar launches plugins with a minimal PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:/opt/local/bin:$PATH"

STATE_FILE="/tmp/sketchybar_bluetooth_paired"

render_bar_item() {
	if [ "$COUNT_CONNECTED" -eq 0 ]; then
		args+=(--set "$NAME" label.drawing=off)
	else
		args+=(--set "$NAME" label="$COUNT_CONNECTED" label.drawing=on)
	fi
}

render_popup() {
	args+=(--set bluetooth.details \
	             label="Paired Devices" \
	             icon.drawing=off \
	             click_script="sketchybar --set $NAME popup.drawing=off")

	# Run the remove separately: if the regex matches nothing, sketchybar
	# errors out and skips every argument after it in the same command,
	# which would silently drop the --add calls below.
	sketchybar --remove '/bluetooth\.device\..*/' >/dev/null 2>&1

	COUNTER=0
	while IFS= read -r device; do
		[ -z "$device" ] && continue

		device_name="$(sed -n 's/.*name: "\([^"]*\)".*/\1/p' <<< "$device")"
		[ -z "$device_name" ] && device_name="$device"

		device_address="$(sed -n 's/^address: \([^,]*\),.*/\1/p' <<< "$device")"

		if [ -n "$device_address" ] && grep -q "$device_address" <<< "$CONNECTED"; then
			icon_color="$ACCENT_COLOR"
		else
			icon_color="$INACTIVE_COLOR"
		fi

		args+=(--add item bluetooth.device."$COUNTER" popup."$NAME" \
		       --set bluetooth.device."$COUNTER" \
		             label="$device_name" \
		             label.align=right \
		             icon="●" \
		             icon.color="$icon_color" \
		             icon.drawing=on \
		             click_script="sketchybar --set $NAME popup.drawing=off")

		COUNTER=$((COUNTER + 1))
	done <<< "$PAIRED"
}

update() {
	args=()

	PAIRED="$(blueutil --paired 2>/dev/null)"
	CONNECTED="$(blueutil --connected 2>/dev/null)"
	COUNT_PAIRED="$(grep -c . <<< "$PAIRED")"
	COUNT_CONNECTED="$(grep -c . <<< "$CONNECTED")"

	render_bar_item

	# Only rebuild the popup when the paired list or connection status
	# actually changed (or on a forced refresh). Rebuilding every tick
	# makes the open popup flicker as items are removed and re-added.
	# Strip volatile fields (access timestamps, signal strength) so they
	# don't count as changes.
	normalize() { sed -E 's/, recent access date:.*$//; s/connected \([^)]*\)/connected/'; }
	STATE="$(normalize <<< "$PAIRED")
--connected--
$(normalize <<< "$CONNECTED")"
	PREV=""
	[ -f "$STATE_FILE" ] && PREV="$(cat "$STATE_FILE")"

	if [ "$STATE" != "$PREV" ] || [ "$SENDER" = "forced" ]; then
		render_popup
		printf '%s' "$STATE" > "$STATE_FILE"
	fi

	sketchybar "${args[@]}"

	if [ "$SENDER" = "forced" ]; then
		sketchybar --animate tanh 15 --set "$NAME" label.y_offset=5 label.y_offset=0
	fi
}

popup() {
	sketchybar --set "$NAME" popup.drawing="$1"
}

case "$SENDER" in
"routine" | "forced")
	update
	;;
"mouse.entered")
	popup on
	;;
"mouse.exited" | "mouse.exited.global")
	popup off
	;;
"mouse.clicked")
	popup toggle
	;;
esac
