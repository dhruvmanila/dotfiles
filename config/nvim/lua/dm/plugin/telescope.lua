local telescope = require "telescope"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local action_utils = require "telescope.actions.utils"
local builtin = require "telescope.builtin"
local themes = require "telescope.themes"

local parsers = require "nvim-treesitter.parsers"

local nnoremap = dm.nnoremap
local xnoremap = dm.xnoremap

-- Custom actions {{{1

-- Namespace to hold custom actions
local custom_actions = {}

-- Yank the selected entry or all the selections made using multi-selection
-- into the register pointed by the variable 'v:register'.
custom_actions.yank_entry = function(prompt_bufnr)
  local values = {}
  action_utils.map_selections(prompt_bufnr, function(selection)
    values[#values + 1] = selection.value
  end)
  if vim.tbl_isempty(values) then
    table.insert(values, action_state.get_selected_entry().value)
  end
  values = vim.tbl_map(function(value)
    if type(value) == "table" and value.text then
      value = value.text
    end
    return value
  end, values)
  vim.fn.setreg(vim.v.register, table.concat(values, "\n"))
end

-- Simple action to go to normal mode.
custom_actions.stop_insert = function()
  vim.cmd "stopinsert!"
end

-- Send the entries to the qflist and open the first entry and the quickfix
-- window in a new tab.
custom_actions.qflist_tab_session = function(prompt_bufnr)
  actions.smart_add_to_qflist(prompt_bufnr)
  vim.cmd "tabnew | copen | cfirst"
end

-- Default theme options {{{1

local function dropdown_opts(width, height)
  return themes.get_dropdown {
    layout_config = {
      width = width or 0.7,
      height = height or 0.75,
    },
    previewer = false,
  }
end

local default_dropdown = dropdown_opts()
local dropdown_list = dropdown_opts(50, 0.5)

-- Setup {{{1

telescope.setup {
  defaults = { -- {{{2
    prompt_prefix = " ",
    selection_caret = "❯ ",
    sorting_strategy = "ascending",
    layout_strategy = "flex",
    layout_config = {
      prompt_position = "top",
      horizontal = {
        width = { padding = 14 },
        height = { padding = 3 },
        preview_width = 0.55,
      },
      vertical = {
        width = { padding = 8 },
        height = { padding = 2 },
        preview_height = 0.5,
        mirror = true,
      },
      flex = {
        flip_columns = 140,
      },
    },
    mappings = {
      i = {
        ["<C-x>"] = false,
        ["<C-u>"] = false,
        ["<C-d>"] = false,
        ["<Esc>"] = actions.close,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,
        ["<C-f>"] = actions.preview_scrolling_down,
        ["<C-b>"] = actions.preview_scrolling_up,
        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        ["<C-s>"] = actions.select_horizontal,
        ["<C-y>"] = custom_actions.yank_entry,
        ["<C-c>"] = custom_actions.stop_insert,
        ["<A-q>"] = custom_actions.qflist_tab_session,
      },
    },
  },
  pickers = { -- {{{2
    buffers = {
      sort_lastused = true,
      sort_mru = true,
      ignore_current_buffer = true,
      theme = "dropdown",
      previewer = false,
      mappings = {
        i = { ["<C-x>"] = actions.delete_buffer },
        n = { ["<C-x>"] = actions.delete_buffer },
      },
      layout_config = {
        width = function(_, editor_width, _)
          return math.min(editor_width - 20, 100)
        end,
        height = function(picker, _, editor_height)
          return math.max(
            5,
            math.min(editor_height - 10, #picker.finder.results)
          )
        end,
      },
    },
    builtin = dropdown_list,
    command_history = default_dropdown,
    commands = default_dropdown,
    current_buffer_fuzzy_find = default_dropdown,
    find_files = default_dropdown,
    git_branches = default_dropdown,
    git_files = default_dropdown,
    grep_string = {
      path_display = { "tail" },
    },
    help_tags = default_dropdown,
    highlights = dropdown_list,
    keymaps = default_dropdown,
    live_grep = {
      path_display = { "tail" },
    },
    lsp_code_actions = {
      theme = "cursor",
    },
    lsp_document_symbols = default_dropdown,
    lsp_range_code_actions = {
      theme = "cursor",
    },
    lsp_workspace_symbols = default_dropdown,
    man_pages = default_dropdown,
    oldfiles = default_dropdown,
    reloader = default_dropdown,
    search_history = default_dropdown,
    vim_options = default_dropdown,
    treesitter = default_dropdown,
  },
  extensions = { -- {{{2
    fzf = {
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
    bookmarks = {
      selected_browser = "brave",
      url_open_command = "open",
    },
    websearch = {
      search_engine = "duckduckgo",
      url_open_command = "open",
      -- For DuckDuckGo max results can be either [1, 25] which is the actual
      -- number of results to fetch or 0 which means to fetch all the results
      -- from the first page.
      max_results = 0,
    },
  },
} -- }}}2

-- Extensions {{{1

-- Load the telescope extensions without blowing up. Only the required extensions
-- are loaded, the others will be loaded lazily by telescope.
pcall(telescope.load_extension, "fzf")

-- Key Bindings {{{1
-- Builtin Pickers {{{2

-- We cannot bind every builtin picker to a keymap and so this will help us
-- when we are in need of a rarely used picker.
nnoremap(";t", builtin.builtin)

-- What's the difference between `git_files` and `find_files`? {{{
--
-- `find_files` uses the `find(1)` command and without any options, it will
-- ignore hidden files (.*), not follow any symlinks, etc.
--
-- `git_files` uses the `git ls-files` command along with other flags to list
-- all the files tracked by `git(1)` which can include hidden files such as
-- `.editorconfig`, `.gitignore`, etc.
--
-- So, we will use `git_files` if we're in a directory tracked by `git(1)` and
-- `find_files` otherwise.
-- }}}
local function find_files()
  if vim.fn.isdirectory ".git" == 1 then
    builtin.git_files()
  else
    builtin.find_files()
  end
end

nnoremap("<C-p>", find_files)
nnoremap("<leader>;", builtin.buffers)
nnoremap("<leader>fl", builtin.current_buffer_fuzzy_find)

nnoremap("<leader>rg", builtin.live_grep)

-- Smart tags picker which uses either the LSP symbols, treesitter symbols or
-- buffer tags, whichever is available first.
nnoremap("<leader>ft", function()
  if #vim.lsp.buf_get_clients(0) > 0 then
    builtin.lsp_document_symbols()
  elseif parsers.has_parser() then
    builtin.treesitter()
  else
    builtin.current_buffer_tags()
  end
end)

nnoremap(";b", builtin.git_branches)
nnoremap("<leader>gc", builtin.git_commits)
nnoremap("<leader>bc", builtin.git_bcommits)

nnoremap("<leader>fh", builtin.help_tags)
nnoremap("<leader>fc", builtin.commands)
nnoremap("<leader>:", builtin.command_history)
nnoremap("<leader>/", builtin.search_history)

-- Custom pickers {{{2

nnoremap("<leader>fd", function()
  builtin.git_files {
    prompt_title = "Find dotfiles",
    cwd = "~/dotfiles",
  }
end)

-- This is mainly to avoid .gitignore patterns.
nnoremap("<leader>fa", function()
  builtin.find_files {
    prompt_title = "Find All Files",
    hidden = true,
    follow = true,
    no_ignore = true,
    file_ignore_patterns = { ".git/" },
  }
end)

nnoremap("<leader>rp", function()
  local pattern = vim.fn.input "Grep pattern ❯ "
  if pattern ~= "" then
    builtin.grep_string {
      prompt_title = ("Find Pattern » %s «"):format(pattern),
      use_regex = true,
      search = pattern,
    }
  end
end)

nnoremap("<leader>rw", function()
  local word = vim.fn.expand "<cword>"
  builtin.grep_string {
    prompt_title = ("Find word » %s «"):format(word),
    search = word,
  }
end)

xnoremap("<leader>rw", function()
  -- TODO: grep for visual selection
end)

nnoremap("<leader>rW", function()
  local word = vim.fn.expand "<cWORD>"
  builtin.grep_string {
    prompt_title = ("Find WORD » %s «"):format(word),
    search = word,
  }
end)

-- Extensions {{{2

-- Gaze the stars with the power of telescope.
nnoremap("<leader>gs", function()
  telescope.extensions.github_stars.github_stars(default_dropdown)
end)

-- List out all the installed plugins and provide action to either go to the
-- GitHub page of the plugin or find files within the plugin using telescope.
nnoremap("<leader>fp", function()
  telescope.extensions.installed_plugins.installed_plugins(dropdown_list)
end)

-- Fuzzy find over your browser bookmarks.
nnoremap("<leader>fb", function()
  telescope.extensions.bookmarks.bookmarks(default_dropdown)
end)

-- Using `ddgr/googler` search the web and fuzzy find through the results and
-- open them up in the browser.
nnoremap("<leader>fw", function()
  telescope.extensions.websearch.websearch(default_dropdown)
end)

-- This is wrapped inside a function to avoid loading telescope modules.
nnoremap("<leader>fi", function()
  telescope.extensions.icons.icons()
end)

-- Start a telescope search to cd into any directory from the current one.
-- The keybinding is defined only for the lir buffer.
local function lir_cd()
  -- Previewer is turned off by default. If it is enabled, then use the
  -- horizontal layout with wider results window and narrow preview window.
  telescope.extensions.lir_cd.lir_cd(default_dropdown)
end

-- List out all the saved sessions and provide action to either open them or
-- delete them.
local function sessions()
  telescope.extensions.sessions.sessions(dropdown_list)
end

nnoremap("<leader>fs", sessions)

-- }}}2
-- }}}1

-- Used in Lir and Dashboard
return {
  find_files = find_files,
  lir_cd = lir_cd,
  sessions = sessions,
}
