MAIN_BRANCH="master"

upgrade_neovim() {
  header "Upgrading Neovim to ${1:-"the latest commit on $MAIN_BRANCH"}..."

  (
    cd "$NEOVIM_DIRECTORY" || exit 1
    curr_hash=$(git rev-parse HEAD)

    # Pull the latest changes
    git checkout $MAIN_BRANCH
    git pull upstream $MAIN_BRANCH
    git push origin $MAIN_BRANCH
    git fetch upstream --tags --force
    if [[ -n $1 ]]; then
      git checkout "$1"
    fi

    new_hash=$(git rev-parse HEAD)
    if [[ "$curr_hash" == "$new_hash" ]]; then
      seek_confirmation "Neovim seems to be already up to date"
      if ! is_confirmed; then
        return
      fi
    fi

    build_neovim
  )
}
