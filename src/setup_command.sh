seek_confirmation "'setup' command should only be invoked on a fresh setup"
if ! is_confirmed; then
  exit
fi

setup_required_directories

if ! [[ -d "$DOTFILES_DIRECTORY" ]]; then
  download_dotfiles
fi

header "Changing directory to $DOTFILES_DIRECTORY..."
cd "$DOTFILES_DIRECTORY" || exit 1

if ! xcode-select -p &> /dev/null; then
  install_xcode_command_line_tools
fi

if ! command_exists 'brew'; then
  install_homebrew
fi
install_homebrew_packages

if ! is_git_repo; then
  setup_dotfiles_git_repository
fi

install_python
install_python_global_packages
install_global_npm_packages
install_cargo_packages

setup_aws

setup_neovim_nightly

# No backup as this is a fresh setup
setup_symlinks

setup_tmux_plugins
setup_github_ssh

update_macos_settings
update_macos_dock
