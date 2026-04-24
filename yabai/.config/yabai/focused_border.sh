#!/bin/bash

stack_index=$(yabai -m query --windows --window | jq '."stack-index"')

if [ "$stack_index" -gt 0 ]; then
  borders active_color=0xFF65D1FF
else
  borders active_color=0xFFFFDA7B
fi
