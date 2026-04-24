#!/bin/bash

TERMINALS=("WezTerm" "iTerm2" "Terminal")
BROWSERS=("Google Chrome" "Safari" "Firefox" "Arc")

# restack all terminals on space 1
TERMINAL_IDS=()
for APP in "${TERMINALS[@]}"; do
  IDS=$(yabai -m query --windows --space 1 | jq --arg app "$APP" '[.[] | select(.app==$app) | .id]')
  while IFS= read -r id; do
    TERMINAL_IDS+=("$id")
  done < <(echo $IDS | jq '.[]')
done

if [ "${#TERMINAL_IDS[@]}" -gt 1 ]; then
  FIRST="${TERMINAL_IDS[0]}"
  for i in $(seq 1 $(( ${#TERMINAL_IDS[@]} - 1 ))); do
    yabai -m window $FIRST --stack "${TERMINAL_IDS[$i]}"
  done
fi

# restack all browsers on space 2
BROWSER_IDS=()
for APP in "${BROWSERS[@]}"; do
  IDS=$(yabai -m query --windows --space 2 | jq --arg app "$APP" '[.[] | select(.app==$app) | .id]')
  while IFS= read -r id; do
    BROWSER_IDS+=("$id")
  done < <(echo $IDS | jq '.[]')
done

if [ "${#BROWSER_IDS[@]}" -gt 1 ]; then
  FIRST="${BROWSER_IDS[0]}"
  for i in $(seq 1 $(( ${#BROWSER_IDS[@]} - 1 ))); do
    yabai -m window $FIRST --stack "${BROWSER_IDS[$i]}"
  done
fi
