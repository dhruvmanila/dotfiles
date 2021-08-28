setup_lua_language_server() {
  header "Setting up the lua language server..."
  git clone --depth=1 https://github.com/sumneko/lua-language-server.git "$LUA_LANGUAGE_SERVER_DIRECTORY"
  (
    cd "$LUA_LANGUAGE_SERVER_DIRECTORY" || exit 1
    git checkout master
    build_lua_lsp
  )
}
