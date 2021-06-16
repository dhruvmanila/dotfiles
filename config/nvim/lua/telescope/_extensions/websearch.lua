-- Heavily inspired from telescope-arecibo but uses `ddgr`/`googler` as
-- the backend.
--
-- Refer:
--   - https://github.com/jarun/ddgr
--   - https://github.com/jarun/googler
local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error "This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)"
end

local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local config = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local entry_display = require "telescope.pickers.entry_display"

local warn = require("dm.utils").warn
local Job = require "plenary.job"

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
  QUERY = "QUERY",
  RESULT = "RESULT",
}

-- Simple animation frames displayed as the prompt prefix.
local anim_frames = { "- ", "\\ ", "| ", "/ " }

-- Callback for setting the prompt animation frame appropriately.
local function in_progress_animation()
  state.current_frame = state.current_frame >= #anim_frames and 1
    or state.current_frame + 1
  state.picker:change_prompt_prefix(anim_frames[state.current_frame], "Comment")
  state.picker:reset_prompt()
end

---Set the configuration state.
---@param opt_name string
---@param value any
---@param default any
local function set_config_state(opt_name, value, default)
  state[opt_name] = value == nil and default or value
end

local function make_display(entry)
  return state.displayer {
    entry.title,
    { entry.url, "Comment" },
  }
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
---@param new_mode string (default: `mode.QUERY`)
---@param results table
local function set_finder(new_mode, results)
  new_mode = new_mode or mode.QUERY
  state.mode = new_mode

  results = results or {}
  state.results = results
  state.current_frame = 0

  local new_finder = finders.new_table {
    results = results,
    entry_maker = entry_maker,
  }

  state.picker:refresh(new_finder, {
    reset_prompt = true,
    new_prefix = { state.original_prompt_prefix, "TelescopePromptPrefix" },
  })
end

-- Perform the search with the prompt query.
local function do_search()
  local query_text = state.picker:_get_prompt()
  if query_text == "" then
    return
  end

  set_finder(mode.QUERY)

  -- start in-progress animation
  if not state.anim_timer then
    state.anim_timer = vim.fn.timer_start(
      100,
      in_progress_animation,
      { ["repeat"] = -1 }
    )
  end

  local function process_complete(job, code)
    if code > 0 then
      error(job:stderr_result())
    end
    local result = job:result()
    result = vim.fn.json_decode(result)
    vim.fn.timer_stop(state.anim_timer)
    state.anim_timer = nil
    set_finder(mode.RESULT, result)
  end

  Job
    :new({
      command = executable[state.search_engine],
      args = {
        "--nocolor",
        "-n",
        state.max_results,
        "--json",
        "--noprompt",
        query_text,
      },
      enable_recording = true,
      on_exit = vim.schedule_wrap(process_complete),
    })
    :start()
end

-- Define the default action of either searching or opening the URL depending
-- on the current mode.
---@param prompt_bufnr number
local function search_or_select(prompt_bufnr)
  if state.mode == mode.QUERY then
    do_search()
  else
    local selection = action_state.get_selected_entry()
    if not selection then
      return
    end
    actions.close(prompt_bufnr)
    os.execute(string.format('%s "%s"', state.open_command, selection.value))
  end
end

-- Open the telescope browser with the provided options.
local function websearch(opts)
  opts = opts or {}
  local search_engine = state.search_engine

  if vim.fn.executable(executable[search_engine]) <= 0 then
    error(
      string.format(
        "This plugin requires the `%s` executable for searching on '%s'",
        executable[search_engine],
        search_engine
      )
    )
  end

  state.displayer = entry_display.create {
    separator = " ",
    items = {
      { width = math.min(65, config.width * vim.o.columns / 2) },
      { remaining = true },
    },
  }

  state.picker = pickers.new(opts, {
    prompt_title = aliases[search_engine] .. " Search",
    finder = finders.new_table {
      results = {},
      entry_maker = entry_maker,
    },
    previewer = false,
    sorter = config.generic_sorter(opts),
    attach_mappings = function(_, map)
      actions.select_default:replace(search_or_select)
      map("i", "<C-f>", function()
        set_finder()
      end)
      return true
    end,
  })
  state.original_prompt_prefix = state.picker.prompt_prefix
  state.picker:find()
  set_finder(mode.QUERY)
end

return telescope.register_extension {
  setup = function(ext_config)
    local search_engine = ext_config.search_engine
    local max_results = ext_config.max_results or 25

    if search_engine == "duckduckgo" and max_results > 25 then
      warn "[telescope] duckduckgo (ddgr) supports a maximum of 25 results"
      max_results = 25
    end

    set_config_state("search_engine", search_engine, "duckduckgo")
    set_config_state("max_results", math.min(max_results, 50))
    set_config_state("open_command", ext_config.open_command, "open")
  end,
  exports = { websearch = websearch },
}
