install_npm_global_packages() {
  header "Installing global npm packages from ${NPM_GLOBAL_PACKAGES}..."
  while IFS= read -r package; do
    npm --global install "$package"
  done < "${NPM_GLOBAL_PACKAGES}"
}
