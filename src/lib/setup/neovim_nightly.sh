py_neovim_packages=(
  "pynvim"
)

setup_neovim_nightly() {
  header "Setting up Neovim nightly..."
  git clone --depth=1 git@github.com:dhruvmanila/neovim.git "$NEOVIM_DIRECTORY"
  (
    cd "$NEOVIM_DIRECTORY" || exit 1
    git checkout master
    git remote add upstream git@github.com:neovim/neovim.git
    build_neovim
  )

  header "Setting up Neovim Python environment..."
  (
    cd ~/.neovim || exit 1
    python3 -m venv venv
    source venv/bin/activate
    pip3 install "${py_neovim_packages[*]}"
    deactivate
  )
}
