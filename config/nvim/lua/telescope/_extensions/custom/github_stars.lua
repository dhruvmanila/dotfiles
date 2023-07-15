local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'
local telescope_config = require('telescope.config').values
local actions = require 'telescope.actions'
local entry_display = require 'telescope.pickers.entry_display'

local custom_actions = require 'dm.plugins.telescope.actions'

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

  if vim.tbl_isempty(_CachedGithubStars) then
    dm.notify('Telescope', 'GitHub stars are not cached yet', vim.log.levels.WARN)
    return
  end

  local displayer = entry_display.create {
    separator = ' ',
    items = {
      { width = 0.3 },
      { remaining = true },
    },
  }

  local function make_display(entry)
    return displayer {
      entry.value,
      { entry.description, 'Comment' },
    }
  end

  pickers
    .new(opts, {
      prompt_title = 'Search GitHub Stars',
      finder = finders.new_table {
        results = _CachedGithubStars,
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
        actions.select_default:replace(custom_actions.open_in_browser)
        return true
      end,
    })
    :find()
end
