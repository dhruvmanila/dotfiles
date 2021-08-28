setup_neovim_nightly() {
  header "Setting up Neovim nightly..."
  git clone --depth=1 git@github.com:dhruvmanila/neovim.git "$NEOVIM_DIRECTORY"
  (
    cd "$NEOVIM_DIRECTORY" || exit 1
    git checkout master
    git remote add upstream git@github.com:neovim/neovim.git
    build_neovim
  )
}
