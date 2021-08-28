setup_tmux_plugins() {
  header "Installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  header "Installing tmux plugins..."
  ~/.tmux/plugins/tpm/bin/install_plugins
}
