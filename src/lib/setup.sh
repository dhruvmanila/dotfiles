declare -a PY_NEOVIM_PACKAGES=(
  "pynvim"
  "debugpy"
)

declare -A SYMLINKS=(
  [".editorconfig"]=".editorconfig"
  ["assets/git/gitconfig"]=".gitconfig"
  ["assets/git/gitmessage"]=".gitmessage"
  ["assets/gpg/gpg-agent.conf"]=".gnupg/gpg-agent.conf"
  ["assets/gpg/gpg.conf"]=".gnupg/gpg.conf"
  ["assets/inputrc"]=".inputrc"
  ["assets/ssh/config"]=".ssh/config"
  ["bash/bash_profile"]=".bash_profile"
  ["bash/bashrc"]=".bashrc"
  ["config/bat"]=".config/bat"
  ["config/bottom"]="Library/Application Support/bottom"
  ["config/bpytop"]=".config/bpytop"
  ["config/gh/config.yml"]=".config/gh/config.yml"
  ["config/glow"]="Library/Preferences/glow"
  ["config/himalaya"]=".config/himalaya"
  ["config/htop"]=".config/htop"
  ["config/ignore"]=".ignore"
  ["config/kitty"]=".config/kitty"
  ["config/nvim"]=".config/nvim"
  ["config/starship.toml"]=".config/starship.toml"
  ["config/youtube-dl"]=".config/youtube-dl"
  ["mac/hammerspoon"]=".hammerspoon"
  ["mac/karabiner"]=".config/karabiner"
  ["python/flake8"]=".config/flake8"
  ["python/ipython/ipython_config.py"]=".ipython/profile_default/ipython_config.py"
  ["python/ipython/startup"]=".ipython/profile_default/startup"
  ["python/jupyter/jupyter_notebook_config.py"]=".jupyter/jupyter_notebook_config.py"
  ["python/jupyter/jupyter_lab_config.py"]=".jupyter/jupyter_lab_config.py"
  ["python/jupyter/lab/user-settings"]=".jupyter/lab/user-settings"
  ["python/pip"]=".config/pip"
  ["python/pylintrc"]=".pylintrc"
  ["tmux/tmux.conf"]=".tmux.conf"
  ["vim"]=".vim"
  ["vim/vimrc"]=".vimrc"
  ["zsh/zshenv"]=".zshenv"
  ["zsh/zshrc"]=".zshrc"
)

download_dotfiles() { # {{{1
  header "Downloading the dotfiles..."
  mkdir -p "${DOTFILES_DIRECTORY}"
  curl -fsSLo ~/dotfiles.tar.gz https://github.com/dhruvmanila/dotfiles/tarball/master

  header "Extracting the dotfiles..."
  tar -zxf "${HOME}/dotfiles.tar.gz" --strip-components 1 -C "${DOTFILES_DIRECTORY}"
  rm -rf ~/dotfiles.tar.gz
}

install_cargo_packages() { # {{{1
  header "Installing global cargo packages from ${CARGO_GLOBAL_PACKAGES}..."
  while IFS= read -r package; do
    cargo install "$package"
  done < "${CARGO_GLOBAL_PACKAGES}"
}

install_homebrew() { # {{{1
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

install_homebrew_packages() { # {{{1
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

install_npm_global_packages() { # {{{1
  header "Installing global npm packages from ${NPM_GLOBAL_PACKAGES}..."
  while IFS= read -r package; do
    npm --global install "$package"
  done < "${NPM_GLOBAL_PACKAGES}"
}

install_python() { # {{{1
  # Setup the mentioned Python versions in from the constant $PYTHON_VERSIONS.
  # The first element is made the global Python version.
  #
  # If the version is already installed, it will be skipped. `pip` will be
  # upgraded for every mentioned version.
  for python_version in "${PYTHON_VERSIONS[@]}"; do
    if ! pyenv versions | grep -q "${python_version}"; then
      header "Installing Python ${python_version}..."
      pyenv install "${python_version}"
    else
      header "Python $python_version is already installed."
    fi
    header "Upgrading pip for Python ${python_version}..."
    "$(pyenv root)/versions/${python_version}/bin/pip" install --upgrade pip
  done

  pyenv_global_python="${PYTHON_VERSIONS[0]}"
  header "Making ${pyenv_global_python} as the global Python version..."
  pyenv global "${pyenv_global_python}"

  header "Initiating pyenv..."
  eval "$(pyenv init -)"
  eval "$(pyenv init --path)"
}

install_python_global_packages() { # {{{1
  header "Installing pipx to manage global packages..."
  python -m pip install pipx
  pyenv rehash

  header "Installing global Python packages from ${PYTHON_GLOBAL_REQUIREMENTS}..."
  while IFS= read -r package; do
    if [[ "$package" == "jupyter" ]]; then
      # 'jupyter' is a metapackage used for installation of all packages related
      # to the ecosystem.
      pipx install --include-deps "$package"

      # These packages needs to be injected in the same environment.
      pipx inject --include-apps "$package" jupyterlab
      pipx inject --include-apps "$package" jupytext
    else
      pipx install "$package"
    fi
  done < "${PYTHON_GLOBAL_REQUIREMENTS}"
}

install_xcode_command_line_tools() { # {{{1
  header "Installing xcode command line tools..."
  xcode-select --install
  # wait until the tools are installed...
  until xcode-select -p &> /dev/null; do
    sleep 5
  done
}

setup_aws() { # {{{1
  # This is the recommended way of installing the tool.
  # https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html#cliv2-mac-install-cmd
  curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"

  # This requires root permission to create symlinks between `path/to/aws-cli/*`
  # and `/usr/local/bin/*` where '*' indicates the necessary executables.
  sudo installer -pkg AWSCLIV2.pkg -target /

  rm AWSCLIV2.pkg
}

setup_dotfiles_git_repository() { # {{{1
  header "Initializing Git repository..."
  set -x
  git init
  git remote add origin https://github.com/dhruvmanila/dotfiles
  git fetch --all
  git reset --hard FETCH_HEAD
  git branch --set-upstream-to origin/master master
  set +x
}

setup_github_ssh() { # {{{1
  # NOTE: This function should be called after symlinking the dotfiles
  ssh -T git@github.com &> /dev/null
  if [[ $? -eq 1 ]]; then
    return
  fi

  local ssh_algorithm="ed25519"
  local ssh_filename="github"

  header "Generating SSH keys..."
  ask "Please provide an email address"
  ssh-keygen -f "${HOME}/.ssh/${ssh_filename}" -t "$ssh_algorithm" -C "$REPLY"

  # shellcheck disable=SC1090
  source "$(ssh-agent)"
  header "Adding SSH key to the ssh-agent..."
  ssh-add -K "${HOME}/.ssh/${ssh_filename}"

  header "Copied public SSH key to clipboard. Please add it to GitHub.com..."
  pbcopy < "${HOME}/.ssh/${ssh_filename}.pub"
  open "https://github.com/settings/ssh"
  for i in {1..6}; do
    ssh -T git@github.com &> /dev/null
    if [[ $? -eq 1 ]]; then
      header "Authentication successful."
      break
    else
      if [[ i -eq 6 ]]; then
        error "Exceeded max retries. Authenticate using 'ssh -T git@github.com' command."
        break
      fi
      error "Failed to authenticate. Retrying in 5 seconds..."
    fi
    sleep 5
  done
}

setup_neovim_nightly() { # {{{1
  header "Setting up Neovim nightly..."
  git clone --depth=1 git@github.com:dhruvmanila/neovim.git "$NEOVIM_DIRECTORY"
  (
    cd "$NEOVIM_DIRECTORY" || exit 1
    git checkout master
    git remote add upstream git@github.com:neovim/neovim.git
    build_neovim
  )
  header "Setting up Neovim Python environment..."
  (
    cd ~/.neovim || exit 1
    python3 -m venv --prompt pynvim .venv
    source venv/bin/activate
    pip3 install "${PY_NEOVIM_PACKAGES[*]}"
    deactivate
  )
}

setup_nnn() { # {{{1
  header "Setting up nnn..."
  git clone git@github.com:jarun/nnn.git "$NNN_DIRECTORY"
  (
    cd "$NNN_DIRECTORY" || exit 1
    git fetch origin --tags --force
    git checkout "$(git describe --abbrev=0)"
    build_nnn
  )
}

setup_symlinks() { # {{{1
  # What does this file do? {{{
  #
  #   > Immediately after logging a user in, login displays the system copyright
  #   > notice, the date and time the user last logged in, the message of the day
  #   > as well as other information. If the file .hushlogin exists in the user's
  #   > home directory, all of these messages are suppressed.
  #
  # Source: `man login`
  # }}}
  if [[ ! -f "${HOME}/.hushlogin" ]]; then
    touch ~/.hushlogin
  fi

  # Create the necessary symbolic links between the `dotfiles` and `HOME` directory.
  header "Creating the necessary symlinks..."

  #                ┌ list associative array keys
  #                │
  for source in "${!SYMLINKS[@]}"; do
    link "$source" "${SYMLINKS[$source]}"
  done
}

setup_tmux_plugins() { # {{{1
  header "Installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  header "Installing tmux plugins..."
  ~/.tmux/plugins/tpm/bin/install_plugins
}

update_macos_settings() { # {{{1
  header "Updating macOS settings..."
  bash "${DOTFILES_DIRECTORY}/mac/osxdefaults"
}

update_macos_dock() { # {{{1
  header "Updating macOS dock applications..."
  dockutil --remove all --no-restart
  for app in "${MACOS_DOCK_APPLICATIONS[@]}"; do
    echo "    Adding '$app'..."
    dockutil --add "$app" --section apps --no-restart
  done

  echo "    Adding '${HOME}/Downloads'..."
  dockutil \
    --add "${HOME}/Downloads" \
    --view grid \
    --display folder \
    --sort dateadded \
    --section others \
    --no-restart

  header "Restarting the dock..."
  killall Dock &> /dev/null
}

# }}}1
