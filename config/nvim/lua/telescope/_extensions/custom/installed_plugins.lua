local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'
local telescope_config = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local custom_actions = require 'dm.plugins.telescope.actions'

-- Defines the action to open the selection in a new Telescope finder with the
-- current working directory being set to the selected plugin installation path.
---@param prompt_bufnr number
---@return nil
local function find_files_in_plugin(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  vim.schedule(function()
    require('telescope.builtin').find_files { cwd = selection.path }
  end)
end

-- Collect and return the plugin information table.
--
-- Each plugin contains the following field:
--   - `name`: Full name of the plugin (user/repo) or only the name (repo)
--   - `url`: Plugin repository url
--   - `path`: Local path to the installation directory
---@return { name: string, url: string, path: string }[]
local function collect_plugin_info()
  local plugins = {}
  for name, info in pairs(packer_plugins) do
    -- Get the `user/repo` part from the URL.
    local fullname = info.url:match '.-([^/]+/[^/]+)$'
    table.insert(plugins, {
      name = fullname or name,
      url = info.url,
      path = info.path,
    })
  end
  return plugins
end

-- This extension will show the currently installed neovim plugins using
-- packer.nvim and provide actions to either open the plugin homepage in the
-- browser or a telescope finder for plugin files.
--
-- There are two actions available:
--   - Default action (<CR>) will open the GitHub URL in the default browser.
--   - <C-f> will open a new telescope finder with current working
--     set to the plugin installation path.
---@param opts table
---@return nil
return function(opts)
  opts = opts or {}

  local plugins = collect_plugin_info()
  if vim.tbl_isempty(plugins) then
    dm.notify('Telescope', 'Plugin information is not available', 3)
    return nil
  end

  pickers
    .new(opts, {
      prompt_title = 'Installed Plugins',
      finder = finders.new_table {
        results = plugins,
        entry_maker = function(entry)
          return {
            display = entry.name,
            value = entry.name,
            path = entry.path,
            url = entry.url,
            ordinal = entry.name,
          }
        end,
      },
      previewer = false,
      sorter = telescope_config.generic_sorter(opts),
      attach_mappings = function(_, map)
        actions.select_default:replace(custom_actions.open_in_browser)
        map('i', '<C-f>', find_files_in_plugin)
        map('n', '<C-f>', find_files_in_plugin)
        return true
      end,
    })
    :find()
end
