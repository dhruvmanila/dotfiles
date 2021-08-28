ask() {
  yellow_bold "[?] $1"
  read -r -p "$(bold "> ")"
}

seek_confirmation() {
  if [[ -n $1 ]]; then
    warning "$1"
  fi
  read -r -p "$(bold "Continue? [y/n] ")" -n 1
  printf "\n"
}

is_confirmed() {
  [[ "$REPLY" =~ ^[Yy]$ ]]
}

is_git_repo() {
  git rev-parse --is-inside-work-tree &> /dev/null
}

command_exists() {
  command -v "$1" &> /dev/null
}

function_exists() {
  [[ "$(type -t "$1")" == "function" ]]
}

build_neovim() {
  make distclean
  make \
    CMAKE_BUILD_TYPE="${NEOVIM_BUILD_TYPE:-"Release"}" \
    CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$NEOVIM_INSTALL_DIRECTORY"
  make install
}

build_lua_lsp() {
  git submodule update --init --recursive
  cd 3rd/luamake || exit 1
  compile/install.sh
  cd ../..
  ./3rd/luamake/luamake rebuild
}

link() {
  local source_file="${DOTFILES_DIRECTORY}/${1}"
  local target_file="${HOME}/${2}"
  if ! [[ -e "$target_file" ]]; then
    echo "==> $target_file -> $source_file"
    ln -fs "$source_file" "$target_file"
  fi
}

setup_required_directories() {
  for directory in "${REQUIRED_DIRECTORIES[@]}"; do
    if ! [[ -d $directory ]]; then
      mkdir -p "$directory"
      if [[ -z $1 ]]; then
        echo "==> Created $directory"
      fi
    fi
  done
}
