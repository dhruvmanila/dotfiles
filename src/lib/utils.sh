ask() {
  yellow_bold "[?] $1"
  read -r -p "$(bold "> ")"
}

build_neovim() {
  make distclean
  make \
    CMAKE_BUILD_TYPE="${NEOVIM_BUILD_TYPE:-"Release"}" \
    CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=${NEOVIM_INSTALL_DIRECTORY:-"${HOME}/neovim"}"
  make install
}

build_nnn() {
  make uninstall
  make O_NERD=1 install
}

function_exists() {
  [[ "$(type -t "$1")" == "function" ]]
}

is_confirmed() {
  [[ "$REPLY" =~ ^[Yy]$ ]]
}

seek_confirmation() {
  warning "$1"
  read -r -p "$(bold "[y/n] ")" -n 1
  printf "\n"
}
