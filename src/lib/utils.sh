ask() { # {{{1
  yellow_bold "[?] $1"
  read -r -p "$(bold "> ")"
}

build_neovim() { # {{{1
  make distclean
  make \
    CMAKE_BUILD_TYPE="${NEOVIM_BUILD_TYPE:-"Release"}" \
    CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$NEOVIM_INSTALL_DIRECTORY"
  make install
}

build_nnn() { # {{{1
  make uninstall
  make O_NERD=1 install
}

command_exists() { # {{{1
  command -v "$1" &> /dev/null
}

function_exists() { # {{{1
  [[ "$(type -t "$1")" == "function" ]]
}

get_jupyter_app_dir() { # {{{1
  printf "%s" "$(jupyter lab path \
    | awk -F ':[ ]+' '{ if($1 == "Application directory") {print $2} }')"
}

is_confirmed() { # {{{1
  [[ "$REPLY" =~ ^[Yy]$ ]]
}

is_git_repo() { # {{{1
  git rev-parse --is-inside-work-tree &> /dev/null
}

link() { # {{{1
  local source_file="${DOTFILES_DIRECTORY}/${1}"
  local target_file="${HOME}/${2}"
  if ! [[ -e "$target_file" ]]; then
    echo "==> $target_file -> $source_file"
    ln -fs "$source_file" "$target_file"
  fi
}

seek_confirmation() { # {{{1
  warning "$1"
  read -r -p "$(bold "[y/n] ")" -n 1
  printf "\n"
}

setup_required_directories() { # {{{1
  for directory in "${REQUIRED_DIRECTORIES[@]}"; do
    if ! [[ -d $directory ]]; then
      mkdir -p "$directory"
      if [[ -z $1 ]]; then
        echo "==> Created $directory"
      fi
    fi
  done
}

# }}}1
