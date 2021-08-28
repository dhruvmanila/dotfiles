upgrade_plugins() {
  # Not quiting vim/neovim to check what's new
  header "Upgrading vim plugins..."
  vim +PlugUpgrade +PlugClean +PlugUpdate

  header "Upgrading neovim plugins..."
  nvim +PackerSync

  header "Cleaning and updating tmux plugins..."
  ~/.tmux/plugins/tpm/bin/clean_plugins
  ~/.tmux/plugins/tpm/bin/update_plugins all
}
