-- https://github.com/LuaLS/lua-language-server
-- Install: `brew install lua-language-server`
-- Settings: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
---@type vim.lsp.Config
return {
  settings = {
    Lua = {
      codelens = {
        enable = true,
      },
      completion = {
        -- Do NOT show contextual words, I got `cmp-buffer` for that.
        showWord = 'Disable',
      },
      hint = {
        enable = true,
        arrayIndex = 'Disable',
        paramName = 'Disable',
      },
      format = {
        enable = false,
      },
      workspace = {
        preloadFileSize = 1000,
      },
    },
  },
}
