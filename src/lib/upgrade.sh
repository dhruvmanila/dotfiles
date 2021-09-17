upgrade_all() { # {{{1
  upgrade_brew
  upgrade_plugins
  upgrade_packages
  upgrade_neovim_nightly
  upgrade_lua_language_server
}

upgrade_brew() { # {{{1
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

upgrade_lua_lsp() { # {{{1
  # https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)
  header "Upgrading the lua language server to ${1:-"the latest commit on master"}..."
  (
    cd "$LUA_LANGUAGE_SERVER_DIRECTORY" || exit 1
    curr_hash=$(git rev-parse HEAD)

    # Pull the latest changes
    git checkout master
    git pull origin master
    git fetch origin --tags --force
    if [[ -n $1 ]]; then
      git checkout "$1"
    fi

    new_hash=$(git rev-parse HEAD)
    if [[ "$curr_hash" == "$new_hash" ]]; then
      seek_confirmation "Lua language server seems to be already up to date"
      if ! is_confirmed; then
        return
      fi
    fi

    build_lua_lsp
  )
}

upgrade_neovim() { # {{{1
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

upgrade_npm() { # {{{1
  header "Upgrading npm and packages..."
  npm --global install npm@latest
  npm --global upgrade
}

upgrade_plugins() { # {{{1
  # Not quiting vim/neovim to check what's new
  header "Upgrading vim plugins..."
  vim +PlugUpgrade +PlugClean +PlugUpdate

  header "Upgrading neovim plugins..."
  nvim +PackerSync

  header "Cleaning and updating tmux plugins..."
  ~/.tmux/plugins/tpm/bin/clean_plugins
  ~/.tmux/plugins/tpm/bin/update_plugins all
}

upgrade_python() { # {{{1
  for python_version in "${PYTHON_VERSIONS[@]}"; do
    header "Upgrading pip for Python $python_version..."
    "$(pyenv root)/versions/${python_version}/bin/pip" install --upgrade pip
  done

  header "Upgrading all Python global packages..."
  pip-compile --upgrade --quiet "$PACKAGE_DIR/requirements.in"
  pip-sync "$PYTHON_GLOBAL_REQUIREMENTS"
}