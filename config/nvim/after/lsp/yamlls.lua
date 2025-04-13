-- https://github.com/redhat-developer/yaml-language-server
-- Install: `npm install --global yaml-language-server`
-- Settings: https://github.com/redhat-developer/yaml-language-server#language-server-settings
return {
  settings = {
    yaml = {
      schemas = {
        -- Specify this explicitly as the server gets confused with `hammerkit.json`
        ---@see https://github.com/redhat-developer/vscode-yaml/issues/565
        ['https://json.schemastore.org/github-workflow.json'] = '.github/workflows/*',
      },
    },
  },
}
