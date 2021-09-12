upgrade_python() {
  for python_version in "${PYTHON_VERSIONS[@]}"; do
    header "Upgrading pip for Python $python_version..."
    "$(pyenv root)/versions/${python_version}/bin/pip" install --upgrade pip
  done

  header "Upgrading all Python global packages..."
  pip-compile --upgrade --quiet "$PACKAGE_DIR/requirements.in"
  pip-sync "$PYTHON_GLOBAL_REQUIREMENTS"
}
