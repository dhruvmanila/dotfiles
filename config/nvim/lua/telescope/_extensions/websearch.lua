-- Heavily inspired from telescope-arecibo but uses `ddgr`/`googler` as
-- the backend.
--
-- Refer:
--   - https://github.com/jarun/ddgr
--   - https://github.com/jarun/googler
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
local utils = require("telescope.utils")

local warn = require("core.utils").warn

local state = {}

-- Executable for the selected search engine.
local executable = {
  duckduckgo = "ddgr",
  google = "googler",
}

-- Aliases to be displayed in the prompt title.
local aliases = {
  duckduckgo = "DuckDuckGo",
  google = "Google",
}

local mode = {
  query = "QUERY",
  result = "RESULT",
}

---Set the configuration state.
---@param opt_name string
---@param value any
---@param default any
local function set_config_state(opt_name, value, default)
  state[opt_name] = value == nil and default or value
end

local function make_display(entry)
  return state.displayer({
    entry.title,
    { entry.url, "Comment" },
  })
end

---@param entry table
---@return table
local function entry_maker(entry)
  return {
    display = make_display,
    value = entry.url,
    abstract = entry.abstract,
    title = entry.title,
    url = entry.url,
    ordinal = entry.title .. " " .. entry.url,
  }
end

-- Set the telescope finder according to the provided information.
---@param new_mode string (default: `mode.query`)
---@param results table
local function set_finder(_, new_mode, results)
  new_mode = new_mode or mode.query
  state.mode = new_mode

  results = results or {}
  state.results = results

  local new_finder = finders.new_table({
    results = results,
    entry_maker = entry_maker,
  })

  state.picker:refresh(new_finder, { reset_prompt = true })
end

-- Perform the search with the prompt query.
local function do_search()
  local query_text = state.picker:_get_prompt()
  if query_text == "" then
    return
  end

  set_finder(_, mode.query)

  local command = {
    executable[state.search_engine],
    "--nocolor",
    "-n",
    state.max_results,
    "--json",
    "--noprompt",
    query_text,
  }
  local output, code, err = utils.get_os_command_output(command)
  if code > 0 then
    error(table.concat(err, "\n"))
  end

  output = vim.fn.json_decode(output)
  set_finder(_, mode.result, output)
end

-- Define the default action of either searching or opening the URL depending
-- on the current mode.
---@param prompt_bufnr number
local function search_or_select(prompt_bufnr)
  if state.mode == mode.query then
    do_search()
  else
    local selection = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    os.execute(string.format('%s "%s"', state.open_command, selection.value))
  end
end

-- Open the telescope browser with the provided options.
local function websearch(opts)
  opts = opts or {}
  local search_engine = state.search_engine

  if vim.fn.executable(executable[search_engine]) <= 0 then
    error(string.format(
      "This plugin requires the `%s` executable for searching on '%s'",
      executable[search_engine],
      search_engine
    ))
  end

  state.displayer = entry_display.create({
    separator = " ",
    items = {
      { width = math.min(65, config.width * vim.o.columns / 2) },
      { remaining = true },
    },
  })

  state.picker = pickers.new(opts, {
    prompt_title = aliases[search_engine] .. " Search",
    finder = finders.new_table({
      results = {},
      entry_maker = entry_maker,
    }),
    previewer = false,
    sorter = config.generic_sorter(opts),
    attach_mappings = function(_, map)
      actions.select_default:replace(search_or_select)
      map("i", "<C-f>", set_finder)
      return true
    end,
  })

  state.picker:find()
  set_finder(_, mode.query)
end

return telescope.register_extension({
  setup = function(ext_config)
    local search_engine = ext_config.search_engine
    local max_results = ext_config.max_results or 25

    if search_engine == "duckduckgo" and max_results > 25 then
      warn("[telescope] duckduckgo (ddgr) supports a maximum of 25 results")
      max_results = 25
    end

    set_config_state("search_engine", search_engine, "duckduckgo")
    set_config_state("max_results", math.min(max_results, 50))
    set_config_state("open_command", ext_config.open_command, "open")
  end,
  exports = { websearch = websearch },
})
