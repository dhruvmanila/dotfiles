#!/usr/bin/env bash

battery_status=$(pmset -g batt)
percentage=$(echo "$battery_status" | grep -Eo '[0-9]{1,3}%')

# if [[ $percentage -lt 20 ]]; then
#   tmux_fg=red
#   tmux_attr=,bold
# elif [[ $percentage -lt 80 ]]; then
#   tmux_fg=yellow
#   tmux_attr=
# else
#   tmux_fg=green
#   tmux_attr=
# fi

if echo "$battery_status" | grep -i 'ac power' &>/dev/null; then
  charging="⚡"
else
  charging=""
fi

# printf "#[fg=%s%s]%s%s%%" "$tmux_fg" "$tmux_attr" "$charging" "$percentage"
printf "%s%s" "$charging" "$percentage"
