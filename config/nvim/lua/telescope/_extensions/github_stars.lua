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

local job = require "dm.job"

-- Keep the values around between reloads
_CachedGithubStars = _CachedGithubStars or { stars = {}, max_length = 0 }

local github_stars

-- Parse the data received from running the GitHub stars job.
---@data string
local function parse_data(data)
  -- As we're paginating the results, GitHub will separate the page results as:
  -- [{...}, {...}][{...}, {...}] ...
  -- Replace the middle "][" with a "," to make it a valid JSON string.
  data = data:gsub("%]%[", ",")
  local json_data = vim.json.decode(data)
  local max_length = 0
  for _, repo in ipairs(json_data) do
    max_length = math.max(max_length, #repo.full_name)
    table.insert(_CachedGithubStars.stars, {
      name = repo.full_name,
      description = repo.description ~= vim.NIL and repo.description or "",
      url = repo.html_url,
    })
  end
  _CachedGithubStars.max_length = max_length
end

-- Start a new asynchronous job to collect the user GitHub stars using
-- GitHub's CLI tool `gh`.
---@param opts table picker opts table
local function collect_github_stars(opts)
  job {
    cmd = "gh",
    args = { "api", "user/starred", "--paginate", "--cache", "24h" },
    on_exit = function(result)
      if result.code > 0 then
        dm.notify("Telescope", result.stderr, 4)
        return
      end
      parse_data(result.stdout)
      github_stars(opts)
    end,
  }
end

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
---@opts table
---@return nil
github_stars = function(opts)
  opts = opts or {}

  if vim.tbl_isempty(_CachedGithubStars.stars) then
    return collect_github_stars(opts)
  end

  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = _CachedGithubStars.max_length + 2 },
      { remaining = true },
    },
  }

  local function make_display(entry)
    return displayer {
      entry.value,
      { entry.description, "Comment" },
    }
  end

  pickers.new(opts, {
    prompt_title = "Search GitHub Stars",
    finder = finders.new_table {
      results = _CachedGithubStars.stars,
      entry_maker = function(entry)
        return {
          display = make_display,
          value = entry.name,
          description = entry.description,
          url = entry.url,
          ordinal = entry.name .. " " .. entry.description,
        }
      end,
    },
    previewer = false,
    sorter = config.generic_sorter(opts),
    attach_mappings = function()
      actions.select_default:replace(open_in_browser)
      return true
    end,
  }):find()
end

return telescope.register_extension {
  exports = { github_stars = github_stars },
}
