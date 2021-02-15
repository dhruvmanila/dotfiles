#!/usr/bin/env bash

# We cannot get the information for streaming track
# https://dougscripts.com/itunes/2020/12/getting-properties-of-streaming-tracks/
read -r -d '' SCRIPT << END
if application "Music" is running then
  tell application "Music"
    if player state is stopped then
      ""
    else
      try
        set trackName to name of current track
        set trackArtist to artist of current track
        set result to "ﭵ " & trackName & " - " & trackArtist
        if length of result > 35 then
          text 1 thru 35 of result & "..."
        else
          result
        end if
      on error
        ""
      end try
    end if
  end tell
end if
END

output=$(osascript -e "$SCRIPT")

printf "%s" "$output"

# if [[ -z "$output" ]]; then
#   printf ""
# else
#   printf "#[fg=red,bg=#49464e]#[fg=black,bg=red] %s" "$output"
# fi
