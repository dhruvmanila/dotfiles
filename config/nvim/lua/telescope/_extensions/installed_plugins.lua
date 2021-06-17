local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error "This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)"
end

local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local config = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local entry_display = require "telescope.pickers.entry_display"

local warn = require("dm.utils").warn

---Defines the action to open the selection in the browser.
local function open_in_browser(prompt_bufnr)
  local selection = action_state.get_selected_entry()

  if not selection.url then
    error('"' .. selection.value .. '" is a local plugin.')
    return nil
  end

  actions.close(prompt_bufnr)
  os.execute("open" .. ' "' .. selection.url .. '" &> /dev/null')
end

---Defines the action to open the selection in a new Telescope finder with the
---current working directory being set to the selected plugin installation path.
local function find_files_in_plugin(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)

  vim.schedule(function()
    require("telescope.builtin").find_files { cwd = selection.path }
  end)
end

--- This extension will show the currently installed neovim plugins using
--- packer.nvim and provide actions to either open the plugin homepage in the
--- browser or a telescope finder for plugin files.
---
--- The information regarding the plugins is cached in `core.plugins` as a
--- global variable (`_PackerPluginInfo`) which contains the following
--- two fields:
---   - `plugins`: List of tables each containing plugin information:
---     - `name`: Full name as provided by the user (user/repo)
---     - `url`: GitHub url
---     - `path`: Local path to the installation directory
---   - `max_length`: Maximum length of the `name` field from above
---
--- There are two actions available:
---   - Default action (<CR>) will open the GitHub URL in the default browser.
---   - <C-f> will open a new telescope finder with current working
---     set to the plugin installation path.
---@param opts table
---@return nil
local function installed_plugins(opts)
  opts = opts or {}

  if vim.tbl_isempty(_PackerPluginInfo.plugins) then
    warn "[Telescope] Plugin information was not cached"
    return nil
  end

  local displayer = entry_display.create {
    separator = " ",
    items = {
      { remaining = true },
    },
  }

  local function make_display(entry)
    return displayer {
      entry.value,
    }
  end

  pickers.new(opts, {
    prompt_title = "Installed Plugins",
    finder = finders.new_table {
      results = _PackerPluginInfo.plugins,
      entry_maker = function(entry)
        return {
          display = make_display,
          value = entry.name,
          path = entry.path,
          url = entry.url,
          ordinal = entry.name,
        }
      end,
    },
    previewer = false,
    sorter = config.generic_sorter(opts),
    attach_mappings = function(_, map)
      actions.select_default:replace(open_in_browser)
      map("i", "<C-f>", find_files_in_plugin)
      map("n", "<C-f>", find_files_in_plugin)
      return true
    end,
  }):find()
end

return telescope.register_extension {
  exports = { installed_plugins = installed_plugins },
}
