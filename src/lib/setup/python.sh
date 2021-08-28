# Setup the mentioned Python versions in from the constant $PYTHON_VERSIONS.
# The first element is made the global Python version.
#
# If the version is already installed, it will be skipped. `pip` will be
# upgraded for every mentioned version.
install_python() {
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

  header "Rehashing pyenv shims..."
  pyenv rehash
}

function install_global_python_packages() {
  header "Installing global Python packages from ${PYTHON_GLOBAL_REQUIREMENTS}..."
  while IFS= read -r package; do
    pipx install "$package"
  done < "${PYTHON_GLOBAL_REQUIREMENTS}"
}
