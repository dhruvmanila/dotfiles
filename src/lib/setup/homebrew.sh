install_homebrew() {
  header "Installing Homebrew..."
  set +e
  if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"; then
    error "Failure occured during Homebrew installation"
    # https://github.com/Homebrew/brew/pull/9383
    core_location="/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core"

    header "Checking if homebrew-core is a shallow clone..."
    if [[ -f "${core_location}/.git/shallow" ]]; then
      header "Fetching everything from homebrew/homebrew-core (this may take a while)..."

      # This `git` is from the xcode command-line tools. By default, we will
      # be using the brew installed `git` to keep up-to date.
      git -C $core_location fetch --unshallow
    else
      error "Unknown error while installing homebrew, exiting..."
      exit 1
    fi
  fi
  set -e
}

install_homebrew_packages() {
  header "Installing homebrew bundle tap..."
  brew tap homebrew/bundle

  header "Installing packages from Brewfile..."
  #  prints output from commands as they are run ┐
  #                                              │
  HOMEBREW_NO_AUTO_UPDATE=1 brew bundle install -v --no-lock --file "$HOMEBREW_BUNDLE_FILE"
  #                                                  │
  #         don't output a `Brewfile.lock.json` file ┘

  header "Cleaning up..."
  brew cleanup
}
