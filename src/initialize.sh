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

DEFAULT_SHELL="bash"

# Common directories
DOTFILES_DIRECTORY="${HOME}/dotfiles"
NEOVIM_DIRECTORY="${HOME}/contributing/neovim"
NEOVIM_INSTALL_DIRECTORY="${HOME}/neovim"
LUA_LANGUAGE_SERVER_DIRECTORY="${HOME}/git/lua-language-server"

# Python versions to be installed on the system.
# First version will be the global one
PYTHON_VERSIONS=(
  "3.9.7"
  "3.9.6"
)

# Packages file
PACKAGE_DIR="${DOTFILES_DIRECTORY}/src/package"
HOMEBREW_BUNDLE_FILE="${DOTFILES_DIRECTORY}/src/package/Brewfile"
PYTHON_GLOBAL_REQUIREMENTS="${DOTFILES_DIRECTORY}/src/package/requirements.txt"
NPM_GLOBAL_PACKAGES="${DOTFILES_DIRECTORY}/src/package/node_modules.txt"

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

# MacOS dock applications
# Keep everything quoted due to spaces. Order: left to right
MACOS_DOCK_APPLICATIONS=(
  "/Applications/Safari.app"
  "/Applications/Brave Browser.app"
  "/Applications/kitty.app"
  "/System/Applications/Notes.app"
  "/Applications/Mark Text.app"
  "/System/Applications/Music.app"
  "/System/Applications/Books.app"
  "/Applications/Slack.app"
  "/Applications/Discord.app"
  "/Applications/Docker.app"
)

setup_required_directories silent
