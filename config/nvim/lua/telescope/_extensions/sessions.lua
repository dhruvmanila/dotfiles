local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  return
end

local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local config = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local entry_display = require "telescope.pickers.entry_display"

local session = require "session"

--- Return the current session name.
local function get_current_session_name()
  local this_session = vim.api.nvim_get_vvar "this_session"
  if this_session and this_session ~= "" then
    return vim.fn.fnamemodify(vim.fn.resolve(this_session), ":t")
  end
end

--- Load the selected startify session.
local function load_session(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  if selection.current then
    return
  end
  actions.close(prompt_bufnr)
  session.load(selection.value)
end

--- Delete the selected startify session.
local function delete_session(prompt_bufnr)
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  current_picker:delete_selection(function(selection)
    session.delete(selection.value)
  end)
end

--- This extension will show all the available sessions and provide actions to
--- either open or delete a session.
---
--- There are two actions available:
---   - Default action (<CR>) will load the selected session.
---   - <C-x> will delete the selected session.
---@param opts table
local function sessions(opts)
  opts = opts or {}

  local results = {}
  local current_session = get_current_session_name()
  for _, name in ipairs(session.list()) do
    table.insert(results, {
      value = name,
      name = name == current_session and name .. " (*)" or name,
      current = name == current_session,
    })
  end

  local displayer = entry_display.create {
    separator = " ",
    items = { { remaining = true } },
  }

  local function make_display(entry)
    return displayer { entry.name }
  end

  pickers.new(opts, {
    prompt_title = "Sessions",
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        return {
          display = make_display,
          value = entry.value,
          name = entry.name,
          current = entry.current,
          ordinal = entry.name,
        }
      end,
    },
    previewer = false,
    sorter = config.generic_sorter(opts),
    attach_mappings = function(_, map)
      actions.select_default:replace(load_session)
      map("i", "<C-x>", delete_session)
      map("n", "<C-x>", delete_session)
      return true
    end,
  }):find()
end

return telescope.register_extension {
  exports = { sessions = sessions },
}
