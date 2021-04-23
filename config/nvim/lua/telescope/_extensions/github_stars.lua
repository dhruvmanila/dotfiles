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

local max_length = 0

local function collect_github_stars()
  if vim.fn.executable("gh") == 0 then
    error("GitHub CLI tool ('gh') is required")
  end

  local stars = {}
  local stderr = {}
  local output, code = Job:new({
    command = 'gh',
    args = {'api', 'user/starred', '--paginate'},
    on_stderr = function(_, data)
      table.insert(stderr, data)
    end
  }):sync()

  if code > 0 then
    error(vim.fn.join(stderr, "\n"))
  end

  output = output[1]:gsub("%]%[", ",")
  local json_output = vim.fn.json_decode(output)

  for _, data in ipairs(json_output) do
    local length = string.len(data.full_name)
    if length > max_length then
      max_length = length
    end
    table.insert(
      stars,
      {
        name = data.full_name,
        description = data.description,
        url = data.html_url,
      }
    )
  end
  return stars
end

local function github_stars(opts)
  opts = opts or {}
  local results = collect_github_stars()

  local displayer = entry_display.create {
    separator = " ",
    items = {
      {width = max_length + 2},
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
      results = results,
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

        os.execute('open ' .. '"' .. selection.url .. '" &> /dev/null')
      end)
      return true
    end,
  }):find()
end

return telescope.register_extension {
  exports = {github_stars = github_stars},
}
