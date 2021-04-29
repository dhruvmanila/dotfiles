local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local config = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")

local warn = require("core.utils").warn

local function installed_plugins(opts)
  opts = opts or {}

  if vim.tbl_isempty(_CachedPluginInfo.plugins) then
    warn('[Telescope] No plugin info was cached.')
    return nil
  end

  local displayer = entry_display.create {
    separator = " ",
    items = {
      {remaining = true}
    },
  }

  local function make_display(entry)
    return displayer {
      entry.name,
    }
  end

  pickers.new(opts, {
    prompt_title = "Installed Plugins",
    finder = finders.new_table {
      results = _CachedPluginInfo.plugins,
      entry_maker = function(entry)
        return {
          display = make_display,
          name = entry.name,
          path = entry.path,
          url = entry.url,
          ordinal = entry.name,
        }
      end,
    },
    previewer = false,
    sorter = config.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()

        if not selection.url then
          error("[Telescope] Selection is a local plugin.")
          return nil
        end

        actions.close(prompt_bufnr)
        os.execute('open' .. ' "' .. selection.url .. '" &> /dev/null')
      end)

      local function find_files_in_plugin()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        vim.schedule(function()
          require('plugin.telescope').find_files_in_dir(selection.path, {})
        end)
      end

      map('i', '<C-f>', find_files_in_plugin)
      map('n', '<C-f>', find_files_in_plugin)
      return true
    end,
  }):find()
end

return telescope.register_extension {
  exports = {installed_plugins = installed_plugins},
}

