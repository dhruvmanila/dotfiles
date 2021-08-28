MAIN_BRANCH="master"

# https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)
upgrade_lua_lsp() {
  header "Upgrading the lua language server to ${1:-"the latest commit on $MAIN_BRANCH"}..."
  (
    cd "$LUA_LANGUAGE_SERVER_DIRECTORY" || exit 1
    curr_hash=$(git rev-parse HEAD)

    # Pull the latest changes
    git checkout $MAIN_BRANCH
    git pull origin $MAIN_BRANCH
    git fetch origin --tags --force
    if [[ -n $1 ]]; then
      git checkout "$1"
    fi

    new_hash=$(git rev-parse HEAD)
    if [[ "$curr_hash" == "$new_hash" ]]; then
      seek_confirmation "Lua language server seems to be already up to date"
      if ! is_confirmed; then
        return
      fi
    fi

    build_lua_lsp
  )
}
