#!/usr/bin/env bash

CHARGING_SYMBOL="⚡"

battery_status=$(pmset -g batt)
percentage=$(echo "$battery_status" | grep -Eo '[0-9]{1,3}%')

if echo "$battery_status" | grep 'charging' &>/dev/null; then
  printf "%s%s" "${CHARGING_SYMBOL}" "${percentage}"
else
  printf "%s" "${percentage}"
fi
