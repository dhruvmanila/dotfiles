local gitlinker = require 'gitlinker'

-- Build and return the Azure DevOps url.
---@param url_data table
---@return string
local function get_azure_devops_url(url_data)
  if url_data.host == 'ssh.dev.azure.com' then
    -- Add the `_git` value right before the repository which is after the last
    -- forward slash. This is already present if the host is `https`. Also,
    -- remove the `v3/` part at the beginning which is the ssh version for
    -- Azure DevOps.
    url_data.repo = url_data.repo:gsub('/([^/]+)$', '/_git/%1'):gsub('^v3/', '')
  end

  local url = 'https://dev.azure.com/' .. url_data.repo
  if not (url_data.file and url_data.rev) then
    return url
  end

  url = ('%s?version=GC%s&path=%s'):format(url, url_data.rev, url_data.file)
  if not url_data.lstart then
    return url
  end

  url = (
    '%s&line=%d&lineEnd=%d&lineStartColumn=1&lineEndColumn=1&lineStyle=plain&_a=contents'
  ):format(url, url_data.lstart, url_data.lend + 1)

  return url
end

gitlinker.setup {
  opts = {
    -- Do not add the current line number in the url for normal mode. Use the
    -- visual mode mapping for it.
    add_current_line_on_normal_mode = false,

    -- Set the default action to open the url in the browser. This function
    -- only works on macOS and Linux.
    action_callback = require('gitlinker.actions').open_in_browser,

    -- Be quiet.
    print_url = false,
  },

  callbacks = {
    ['dev.azure.com'] = get_azure_devops_url,
  },

  -- Default mapping to call url generation with `action_callback`.
  mappings = '<leader>go',
}

vim.keymap.set('n', '<leader>gr', gitlinker.get_repo_url, {
  desc = 'gitlinker: Open the current repository url in the browser',
})
