local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  return
end

local Job = require "plenary.job"
local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local config = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local entry_display = require "telescope.pickers.entry_display"

-- Keep the values around between reloads
_CachedGithubStars = _CachedGithubStars or { stars = {}, max_length = 0 }

--- Parse the data received from running the GitHub stars job.
---@data string
local function parse_data(data)
  -- As we're paginating the results, GitHub will separate the page results as:
  -- [{...}, {...}][{...}, {...}] ...
  -- Replace the middle "][" with a "," to make it a valid JSON string.
  data = data:gsub("%]%[", ",")
  local json_data = vim.fn.json_decode(data)
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

--- Start a new asynchronous job to collect the user GitHub stars using
--- GitHub's CLI tool `gh`.
local function collect_github_stars()
  ---@param job Job
  ---@param code number
  local function process_complete(job, code)
    if code > 0 then
      vim.notify("[telescope]: " .. table.concat(job:stderr_result(), "\n"), 4)
      return
    end
    local result = job:result()
    if result and result[1] ~= "" then
      parse_data(result[1])
    end
  end

  Job
    :new({
      command = "gh",
      args = { "api", "user/starred", "--paginate" },
      enable_recording = true,
      on_exit = vim.schedule_wrap(process_complete),
    })
    :start()
end

--- Defines the action to open the selection in the browser.
local function open_in_browser(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)

  os.execute("open" .. ' "' .. selection.url .. '" &> /dev/null')
end

--- This extension will show the users GitHub stars with the repository
--- description and provide an action to open it in the default browser.
---
--- The information is cached using an asynchronous job which is started when
--- this plugin is loaded. It is stored in a global variable
--- (`_CachedGithubStars`) which contains the following two fields:
---   - `stars`: List of tables each containing respository information:
---     - `name`: Full repository name (user/repo)
---     - `url`: GitHub url
---     - `description`: Repository description
---   - `max_length`: Maximum length of the `name` field from above
---
--- Default action (<CR>) will open the GitHub URL in the default browser.
---@opts table
---@return nil
local function github_stars(opts)
  opts = opts or {}

  -- TODO: start the job again? run the job synchronously?
  if vim.tbl_isempty(_CachedGithubStars.stars) then
    vim.notify("[telescope]: No GitHub stars are cached yet", 3)
    return nil
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
      -- TODO: refresh the telescope window
      -- map('i', '<C-l>', collect_github_stars)
      return true
    end,
  }):find()
end

return telescope.register_extension {
  setup = function(_)
    if vim.tbl_isempty(_CachedGithubStars.stars) then
      collect_github_stars()
    end
  end,
  exports = { github_stars = github_stars },
}
