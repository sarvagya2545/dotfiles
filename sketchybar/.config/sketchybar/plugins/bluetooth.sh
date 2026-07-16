#!/bin/bash

  DEVICES=$(system_profiler SPBluetoothDataType -json -detailLevel basic 2>/dev/null | jq -rc '.SPBluetoothDataType[0].devices_list[]? | select( .[] | .device_minorType == "Headphones" and .device_connected =="Yes") | keys[]')

  if [ "$DEVICES" = "" ]; then
    sketchybar --set $NAME icon.drawing=off background.padding_right=0 background.padding_left=0 label=""
  else
    DEVICES="$(echo $DEVICES | rev | cut -d" " -f3- | rev)"
    sketchybar --set $NAME icon.drawing=on background.padding_right=1 background.padding_left=4 label="$DEVICES"
  fi
