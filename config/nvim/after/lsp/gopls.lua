-- https://github.com/golang/tools/tree/master/gopls
-- Install: `go install golang.org/x/tools/gopls@latest`
-- Settings: https://github.com/golang/tools/blob/master/gopls/doc/settings.md
---@type vim.lsp.Config
return {
  settings = {
    gopls = {
      analyses = {
        nilness = true,
        shadow = true,
        unusedparams = true,
        unusedwrite = true,
      },
      gofumpt = true,
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      usePlaceholders = true,
    },
  },
  on_init = function(client)
    -- Find the first `go.mod` file starting from the current buffer path,
    -- moving upwards. This is to support Go workspaces.
    local modfile = vim.fs.find({ 'go.mod' }, {
      path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
      upward = true,
      type = 'file',
      stop = dm.OS_HOMEDIR,
    })[1]
    for line in io.lines(modfile) do
      if vim.startswith(line, 'module') then
        -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md#local-string
        client.config.settings.gopls['local'] = vim.split(line, ' ', { plain = true })[2]
      end
    end
    client:notify(vim.lsp.protocol.Methods.workspace_didChangeConfiguration, {
      settings = client.config.settings,
    })
  end,
}
