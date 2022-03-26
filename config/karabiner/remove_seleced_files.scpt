tell application "Finder"
  try
    set sel to the selection
    delete (every item of sel)
  end try
end tell
