upgrade_brew() {
  header "Updating homebrew and packages..."
  brew update
  brew upgrade
  brew cleanup
}
