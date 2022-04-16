# shellcheck disable=SC2034
#
# Code here runs inside the `initialize()` function
#
# Use it for anything that you need to run before any other function, like
# setting environment vairables:
#
#     > DOTFILES_DIRECTORY="${HOME}/dotfiles"
#
# Feel free to empty (but not delete) this file.

case "$(uname)" in
  Darwin) ;;
  *)
    error "'dot' command is only supported on a mac machine"
    exit 1
    ;;
esac

HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix)}"

# Default shell path. This can be set using `dot shell`.
DEFAULT_SHELL_PATH="${HOMEBREW_PREFIX}/bin/zsh"

# Common directories
DOTFILES_DIRECTORY="${HOME}/dotfiles"
NEOVIM_DIRECTORY="${HOME}/contributing/neovim"
NEOVIM_INSTALL_DIRECTORY="${HOME}/neovim"
NNN_DIRECTORY="${HOME}/git/nnn"

# Python versions to be installed on the system.
# First version will be the global one
PYTHON_VERSIONS=(
  "3.10.2"
  "3.9.10"
)

# Packages file
PACKAGE_DIR="${DOTFILES_DIRECTORY}/src/package"
HOMEBREW_BUNDLE_FILE="${PACKAGE_DIR}/Brewfile"
PYTHON_GLOBAL_REQUIREMENTS="${PACKAGE_DIR}/requirements.txt"
NPM_GLOBAL_PACKAGES="${PACKAGE_DIR}/node_modules.txt"
CARGO_GLOBAL_PACKAGES="${PACKAGE_DIR}/cargo_packages.txt"

# On initialization of the script, if these directories does not exist, then
# they will be created.
REQUIRED_DIRECTORIES=(
  ~/.config
  ~/.gnupg
  ~/.ssh
  ~/contributing
  ~/git
  ~/neovim
  ~/playground
  ~/projects
  ~/work
)

# These files/directories will be backed up before symlinking, if they exists.
# This step can be skipped if `-f/--force` flag is passed to the `link` command.
BACKUP_DOTFILES=(
  ~/.bash_profile
  ~/.bashrc
  ~/.config
  ~/.gitconfig
  ~/.inputrc
  ~/.tmux.conf
  ~/.vim
)

setup_required_directories silent
