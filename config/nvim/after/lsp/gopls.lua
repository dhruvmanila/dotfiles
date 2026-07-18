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
    -- The resolved root can be a Go module, Go workspace, or Git repository.
    -- Only set the local import prefix when a `go.mod` exists at or above it.
    local root_dir = client.config.root_dir
    if root_dir == nil then
      return
    end

    local modfile = vim.fs.find({ 'go.mod' }, {
      path = root_dir,
      upward = true,
      type = 'file',
      stop = dm.OS_HOMEDIR,
    })[1]
    if modfile == nil then
      return
    end

    for line in io.lines(modfile) do
      local module = line:match '^module%s+([^%s]+)'
      if module then
        -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md#local-string
        client.config.settings.gopls['local'] = module
        client:notify(vim.lsp.protocol.Methods.workspace_didChangeConfiguration, {
          settings = client.config.settings,
        })
        return
      end
    end
  end,
}
