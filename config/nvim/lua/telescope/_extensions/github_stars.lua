local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local Job = require('plenary.job')
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local config = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")

-- Keep the values around between reloads
_CachedGithubStars = _CachedGithubStars or {stars = {}, max_length = 0}

local function parse_data(data)
  -- As we're paginating the results, GitHub will separate the page results as:
  -- [{...}, {...}] [{...}, {...}] ...
  -- JSON does not like random symbols and so a small hack ;)
  data = data:gsub("%]%[", ",")
  local json_data = vim.fn.json_decode(data)

  for _, repo in ipairs(json_data) do
    local length = string.len(repo.full_name)
    if length > _CachedGithubStars.max_length then
      _CachedGithubStars.max_length = length
    end
    table.insert(
      _CachedGithubStars.stars,
      {
        name = repo.full_name,
        description = repo.description,
        url = repo.html_url,
      }
    )
  end
end

local function collect_github_stars()
  local stderr = {}

  local function process_complete(job, code)
    if code > 0 then
      error(table.concat(stderr, "\n"))
    end
    local result = job:result()
    if result and result[1] ~= '' then
      parse_data(result[1])
    end
  end

  Job:new({
    command = "gh",
    args = {"api", "user/starred", "--paginate"},
    enable_recording = true,
    on_stderr = function(_, data)
      table.insert(stderr, data)
    end,
    on_exit = vim.schedule_wrap(process_complete),
  }):start()
end

local function github_stars(opts)
  opts = opts or {}

  -- TODO: start the job again? run the job synchronously?
  if vim.tbl_isempty(_CachedGithubStars.stars) then
    vim.api.nvim_echo(
      {{'[Telescope] No GitHub stars are cached yet.', 'WarningMsg'}}, true, {}
    )
    return nil
  end

  local displayer = entry_display.create {
    separator = " ",
    items = {
      {width = _CachedGithubStars.max_length + 2},
      {remaining = true},
    },
  }

  local function make_display(entry)
    return displayer {
      entry.name,
      {entry.description, "Comment"},
    }
  end

  pickers.new(opts, {
    prompt_title = "Search GitHub Stars",
    finder = finders.new_table {
      results = _CachedGithubStars.stars,
      entry_maker = function(entry)
        return {
          display = make_display,
          name = entry.name,
          description = entry.description,
          url = entry.url,
          ordinal = entry.name,
        }
      end,
    },
    previewer = false,
    sorter = config.file_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        os.execute('open' .. ' "' .. selection.url .. '" &> /dev/null')
      end)
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
  exports = {github_stars = github_stars},
}
