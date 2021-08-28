install_xcode_command_line_tools() {
  header "Installing xcode command line tools..."
  xcode-select --install
  # wait until the tools are installed...
  until xcode-select -p &> /dev/null; do
    sleep 5
  done
}
