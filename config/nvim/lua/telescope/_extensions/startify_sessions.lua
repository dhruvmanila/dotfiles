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

--- Load the selected startify session.
local function load_session(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  vim.fn["startify#session_load"](false, selection.name)
end

--- Delete the selected startify session.
local function delete_session(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)

  vim.schedule(function()
    vim.fn["startify#session_delete"](false, selection.name)
  end)
end

--- This extension will show all the startify sessions and provide actions to
--- either open or delete a session.
---
--- Requires: vim-startify
--- Reference: (autoload/startify.vim)
---   - `startify#session_list`
---   - `startify#session_load`
---   - `startify#session_delete`
---
--- Default action (<CR>) will load the selected session.
---@param opts table
local function startify_sessions(opts)
  opts = opts or {}

  local results = {}
  for _, name in ipairs(vim.fn["startify#session_list"]("")) do
    table.insert(results, {name = name})
  end

  local displayer = entry_display.create {
    separator = " ",
    items = {
      {remaining = true},
    },
  }

  local function make_display(entry)
    return displayer {
      entry.name,
    }
  end

  pickers.new(opts, {
    prompt_title = "Startify Sessions",
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        return {
          display = make_display,
          name = entry.name,
          ordinal = entry.name,
        }
      end,
    },
    previewer = false,
    sorter = config.generic_sorter(opts),
    attach_mappings = function(_, map)
      actions.select_default:replace(load_session)
      map('i', '<C-x>', delete_session)
      return true
    end,
  }):find()
end

return telescope.register_extension {
  exports = {startify_sessions = startify_sessions},
}
