upgrade_all() {
  upgrade_brew
  upgrade_plugins
  upgrade_npm
  upgrade_python
  upgrade_neovim "$@"
  upgrade_nnn
}

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

upgrade_cargo() {
  header "Upgrading global cargo packages..."
  while IFS= read -r package; do
    # The `install` command updates the package if there is a newer version.
    cargo install "$package"
  done < "${CARGO_GLOBAL_PACKAGES}"
}

upgrade_neovim() {
  header "Upgrading Neovim to ${1:-"the latest commit on master"}..."
  (
    cd "$NEOVIM_DIRECTORY" || exit 1
    curr_hash=$(git rev-parse HEAD)

    # Pull the latest changes
    git checkout master
    git pull upstream master
    git push origin master
    git fetch upstream --tags --force
    if [[ -n $1 ]]; then
      git checkout "$1"
    fi

    new_hash=$(git rev-parse HEAD)
    if [[ "$curr_hash" == "$new_hash" ]]; then
      seek_confirmation "Neovim seems to be already up to date"
      if ! is_confirmed; then
        return
      fi
    fi

    build_neovim
  )
}

upgrade_nnn() {
  header "Upgrading nnn to the latest version..."
  (
    cd "$NNN_DIRECTORY" || exit 1
    current_tag="$(git describe --abbrev=0)"
    git checkout master
    git pull origin master
    git fetch origin --tags --force
    latest_tag="$(git describe --abbrev=0)"
    if [[ "$current_tag" == "$latest_tag" ]]; then
      seek_confirmation "nnn seems to be already up to date to $latest_tag"
      if ! is_confirmed; then
        return
      fi
    fi
    git checkout "$latest_tag"
    build_nnn
  )

  # https://github.com/jarun/nnn/tree/master/plugins#installation
  header "Upgrading nnn plugins..."
  sh -c "$(curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs)"
}

upgrade_npm() {
  header "Upgrading npm and packages..."
  npm --location=global install npm@latest
  npm --location=global upgrade
}

upgrade_plugins() {
  # Not quiting vim/neovim to check what's new
  header "Upgrading vim plugins..."
  vim +PlugUpgrade +PlugClean +PlugUpdate

  # header "Upgrading neovim plugins..."
  # nvim +Lazy sync

  header "Cleaning and updating tmux plugins..."
  ~/.tmux/plugins/tpm/bin/clean_plugins
  ~/.tmux/plugins/tpm/bin/update_plugins all
}

upgrade_python() {
  header "Upgrading pip for all pyenv Python versions..."
  for python_exec in "$PYENV_ROOT"/versions/*/bin/python; do
    $python_exec -m pip install --upgrade pip
  done

  header "Upgrading pipx..."
  "$PYENV_ROOT/bin/python" -m pip install --upgrade pipx

  header "Upgrading all Python global packages..."
  pipx upgrade-all --include-injected
}
