#!/usr/bin/env bash

battery_status=$(pmset -g batt)
percentage=$(echo "$battery_status" | grep -Eo '[0-9]{1,3}%')

if echo "$battery_status" | grep -i 'ac power' &>/dev/null; then
  charging="⚡"
else
  charging=""
fi

printf "%s%s" "$charging" "$percentage"
