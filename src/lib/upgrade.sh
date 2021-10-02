upgrade_all() { # {{{1
  upgrade_brew
  upgrade_plugins
  upgrade_npm
  upgrade_python
  upgrade_cargo
  upgrade_neovim "$@"
  upgrade_lua_lsp
  upgrade_nnn
  upgrade_mac
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

upgrade_cargo() { # {{{1
  header "Upgrading global cargo packages..."
  while IFS= read -r package; do
    # The `install` command updates the package if there is a newer version.
    cargo install "$package"
  done < "${CARGO_GLOBAL_PACKAGES}"
}

upgrade_lua_lsp() { # {{{1
  # https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)
  header "Upgrading the lua language server to the latest version..."
  (
    cd "$LUA_LANGUAGE_SERVER_DIRECTORY" || exit 1
    current_tag="$(git describe --abbrev=0)"
    git checkout master
    git pull origin master
    git fetch origin --tags --force
    latest_tag=$(git describe --abbrev=0)
    if [[ "$current_tag" == "$latest_tag" ]]; then
      echo "==> Lua language server is to be already up to date to $latest_tag"
      return
    fi
    git checkout "$latest_tag"
    build_lua_lsp
  )
}

upgrade_mac() { # {{{1
  header "Upgrading macOS applications..."
  mas upgrade

  header "Updating softwares..."
  softwareupdate --install --all
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

upgrade_nnn() { # {{{1
  header "Upgrading nnn to the latest version..."
  (
    cd "$NNN_DIRECTORY" || exit 1
    current_tag="$(git describe --abbrev=0)"
    git checkout master
    git pull origin master
    git fetch origin --tags --force
    latest_tag="$(git describe --abbrev=0)"
    if [[ "$current_tag" == "$latest_tag" ]]; then
      echo "==> nnn is already up to date to $latest_tag"
      return
    fi
    git checkout "$latest_tag"
    build_nnn
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
  local pyenv_root pyenv_global
  pyenv_root="$(pyenv root)"
  pyenv_global="$(pyenv global)"

  header "Upgrading pip for all pyenv Python versions..."
  for python_exec in "$pyenv_root"/versions/*/bin/python; do
    $python_exec -m pip install --upgrade pip
  done

  header "Upgrading pipx..."
  local global_python_exec="$pyenv_root/versions/$pyenv_global/bin/python"
  $global_python_exec -m pip install --upgrade pipx

  header "Upgrading all Python global packages..."
  pipx upgrade-all --include-injected
}
