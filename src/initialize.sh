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
    error "'dotbot' command is only supported on a mac machine"
    exit 1
    ;;
esac

HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix)}"

# Common directories
DOTFILES_DIRECTORY="${HOME}/dotfiles"
NEOVIM_DIRECTORY="${HOME}/contributing/neovim"
NEOVIM_INSTALL_DIRECTORY="${HOME}/neovim"
NNN_DIRECTORY="${HOME}/git/nnn"

# Packages file
PACKAGE_DIR="${DOTFILES_DIRECTORY}/src/package"
HOMEBREW_BUNDLE_FILE="${PACKAGE_DIR}/Brewfile"
PYTHON_GLOBAL_REQUIREMENTS="${PACKAGE_DIR}/requirements.txt"
NPM_GLOBAL_PACKAGES="${PACKAGE_DIR}/node_modules.txt"
CARGO_GLOBAL_PACKAGES="${PACKAGE_DIR}/cargo_packages.txt"
