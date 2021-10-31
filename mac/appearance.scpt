tell application "System Events"
  tell appearance preferences
    -- (bool) Use dark mode for bar and dock.
    set dark mode to true

    -- Color used for highlighting selected text and lists.
    -- Available: blue gold graphite green orange purple red silver
    set highlight color to graphite
  end tell
end tell
