-- https://github.com/bash-lsp/bash-language-server
-- Install: `npm install --global bash-language-server`
-- Settings: https://github.com/bash-lsp/bash-language-server/blob/master/server/src/config.ts
---@type vim.lsp.Config
return {
  settings = {
    bashIde = {
      shfmt = {
        binaryNextLine = true,
        caseIndent = true,
        spaceRedirects = true,
      },
    },
  },
}
