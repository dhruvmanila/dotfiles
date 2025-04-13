-- https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server
-- Install: `npm install --global vscode-langservers-extracted`
-- Settings: https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server#settings
---@type vim.lsp.Config
return {
  filetypes = { 'json', 'jsonc' },
  settings = {
    json = {
      schemas = vim.list_extend({
        {
          description = 'Lua language server config file',
          fileMatch = { '.luarc.json' },
          url = 'https://raw.githubusercontent.com/sumneko/vscode-lua/master/setting/schema.json',
        },
      }, require('schemastore').json.schemas()),
    },
  },
}
