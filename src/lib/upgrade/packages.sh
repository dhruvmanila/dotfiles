upgrade_packages() {
  for python_version in "${PYTHON_VERSIONS[@]}"; do
    header "Upgrading pip for Python $python_version..."
    "$(pyenv root)/versions/${python_version}/bin/pip" install --upgrade pip
  done

  header "Upgrading all pipx packages..."
  pipx upgrade-all

  header "Upgrading all npm packages..."
  npm --global upgrade
}
