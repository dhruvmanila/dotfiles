local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'
local telescope_config = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local entry_display = require 'telescope.pickers.entry_display'

local session = require 'dm.session'

-- Load the selected session.
---@param prompt_bufnr number
local function load_session(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  if selection.current then
    return
  end
  actions.close(prompt_bufnr)
  session.load(selection.value)
end

-- Delete the selected session.
---@param prompt_bufnr number
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
return function(opts)
  opts = opts or {}

  local results = {}
  local current_session = session.current()
  for _, name in ipairs(session.list()) do
    table.insert(results, {
      value = name,
      name = name == current_session and name .. ' (*)' or name,
      current = name == current_session,
    })
  end

  local displayer = entry_display.create {
    separator = ' ',
    items = { { remaining = true } },
  }

  local function make_display(entry)
    return displayer { entry.name }
  end

  pickers.new(opts, {
    prompt_title = 'Sessions',
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
    sorter = telescope_config.generic_sorter(opts),
    attach_mappings = function(_, map)
      actions.select_default:replace(load_session)
      map('i', '<C-x>', delete_session)
      map('n', '<C-x>', delete_session)
      return true
    end,
  }):find()
end
