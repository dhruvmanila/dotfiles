local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'
local telescope_config = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local entry_display = require 'telescope.pickers.entry_display'

-- Defines the action to open the selection in the browser.
local function open_in_browser(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  os.execute(('open "%s"'):format(selection.url))
end

-- This extension will show the users GitHub stars with the repository
-- description and provide an action to open it in the default browser.
--
-- The information is cached using an asynchronous job which is started when
-- this plugin is loaded. It is stored in a global variable
-- (`_CachedGithubStars`) which contains the following two fields:
--   - `stars`: List of tables each containing respository information:
--     - `name`: Full repository name (user/repo)
--     - `url`: GitHub url
--     - `description`: Repository description
--   - `max_length`: Maximum length of the `name` field from above
--
-- Default action (<CR>) will open the GitHub URL in the default browser.
---@param opts table
---@return nil
return function(opts)
  opts = opts or {}

  if vim.tbl_isempty(_CachedGithubStars.stars) then
    return dm.notify('Telescope', 'GitHub stars are not cached yet', 3)
  end

  local displayer = entry_display.create {
    separator = ' ',
    items = {
      { width = _CachedGithubStars.max_length + 2 },
      { remaining = true },
    },
  }

  local function make_display(entry)
    return displayer {
      entry.value,
      { entry.description, 'Comment' },
    }
  end

  pickers.new(opts, {
    prompt_title = 'Search GitHub Stars',
    finder = finders.new_table {
      results = _CachedGithubStars.stars,
      entry_maker = function(entry)
        return {
          display = make_display,
          value = entry.name,
          description = entry.description,
          url = entry.url,
          ordinal = entry.name .. ' ' .. entry.description,
        }
      end,
    },
    previewer = false,
    sorter = telescope_config.generic_sorter(opts),
    attach_mappings = function()
      actions.select_default:replace(open_in_browser)
      return true
    end,
  }):find()
end