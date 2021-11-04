# Setup the default shell as mentioned in the DEFAULT_SHELL_PATH global
# variable. This will be skipped if the shell is already the default one.

# https://stackoverflow.com/a/41553295
if dscl . -read ~/ UserShell | grep "$DEFAULT_SHELL_PATH" &> /dev/null; then
  header "'$DEFAULT_SHELL_PATH' is already the default shell."
  return
fi

if ! grep -F -q "${DEFAULT_SHELL_PATH}" /etc/shells; then
  header "Adding '$DEFAULT_SHELL_PATH' to /etc/shells..."
  echo "${DEFAULT_SHELL_PATH}" | sudo tee -a /etc/shells
fi

header "Switching to '${DEFAULT_SHELL_PATH}' as the default shell..."
chsh -s "${DEFAULT_SHELL_PATH}"
