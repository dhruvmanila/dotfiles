upgrade_brew() {
  header "Updating homebrew..."
  brew update

  header "Upgrading homebrew packages..."
  brew upgrade

  header "Upgrading outdated casks..."
  brew upgrade --cask --greedy

  # Remove all cache files older than one day
  header "Cleaning up..."
  brew cleanup --prune 1
}
