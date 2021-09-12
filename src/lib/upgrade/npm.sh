upgrade_npm() {
  header "Upgrading npm and packages..."
  npm --global install npm@latest
  npm --global upgrade
}
