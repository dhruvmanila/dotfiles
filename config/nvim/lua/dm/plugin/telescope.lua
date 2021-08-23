local should_reload = true

if should_reload then
  RELOAD "plenary"
  RELOAD "popup"
  RELOAD "telescope"
end

local telescope = require "telescope"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local builtin = require "telescope.builtin"
local themes = require "telescope.themes"

local nnoremap = dm.nnoremap

-- Custom actions {{{1

-- Namespace to hold custom actions
local custom_actions = {}

-- Yank the selected entry or all the selections made using multi-selection
-- into the register pointed by the variable 'v:register'.
custom_actions.yank_entry = function(prompt_bufnr)
  local values = {}
  local picker = action_state.get_current_picker(prompt_bufnr)
  local selections = picker:get_multi_selection()
  if vim.tbl_isempty(selections) then
    table.insert(selections, action_state.get_selected_entry())
  end
  for _, selection in ipairs(selections) do
    table.insert(values, selection.value)
  end
  vim.fn.setreg(vim.v.register, table.concat(values, "\n"))
end

-- Reset the prompt keeping the cursor at the current entry in the results window.
custom_actions.reset_prompt = function(prompt_bufnr)
  action_state.get_current_picker(prompt_bufnr):reset_prompt()
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

local default_dropdown = themes.get_dropdown {
  layout_config = {
    width = 0.8,
    height = 0.8,
  },
  previewer = false,
}

local default_ivy = themes.get_ivy {
  layout_config = {
    height = 0.5,
  },
}

-- Setup {{{1

telescope.setup {
  defaults = { -- {{{2
    prompt_prefix = " ",
    selection_caret = "❯ ",
    sorting_strategy = "ascending",
    file_ignore_patterns = { "__pycache__", ".mypy_cache" },
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
        ["<Esc>"] = actions.close,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,
        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        ["<C-s>"] = actions.select_horizontal,
        ["<C-y>"] = custom_actions.yank_entry,
        ["<C-l>"] = custom_actions.reset_prompt,
        ["<C-c>"] = custom_actions.stop_insert,
        ["<A-q>"] = custom_actions.qflist_tab_session,
      },
    },
  },
  pickers = { -- {{{2
    builtin = {
      theme = "dropdown",
      previewer = false,
      layout_config = {
        width = 45,
        height = 0.85,
      },
    },
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
          return math.min(editor_height - 10, #picker.finder.results)
        end,
      },
    },
    live_grep = {
      path_display = { "tail" },
    },
    grep_string = {
      path_display = { "tail" },
    },
    help_tags = {
      layout_config = {
        horizontal = {
          width = 0.75,
          preview_width = 0.6,
        },
      },
    },
    highlights = {
      layout_config = {
        horizontal = {
          width = 0.75,
          preview_width = 0.6,
        },
      },
    },
    command_history = default_ivy,
    search_history = default_ivy,
    oldfiles = default_dropdown,
    current_buffer_fuzzy_find = default_dropdown,
    vim_options = default_dropdown,
    keymaps = default_dropdown,
    commands = default_dropdown,
    lsp_code_actions = {
      theme = "cursor",
    },
    lsp_range_code_actions = {
      theme = "cursor",
    },
    git_branches = {
      theme = "dropdown",
      previewer = false,
    },
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
nnoremap("<C-p>", function()
  if vim.fn.isdirectory ".git" == 1 then
    builtin.git_files()
  else
    builtin.find_files()
  end
end)

nnoremap("<leader>;", builtin.buffers)
nnoremap("<leader>fl", builtin.current_buffer_fuzzy_find)

nnoremap("<leader>rg", builtin.live_grep)

nnoremap(";b", builtin.git_branches)
nnoremap("<leader>gc", builtin.git_commits)

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
  if pattern == "" then
    return
  end
  builtin.grep_string {
    prompt_title = ("Find Pattern (%s)"):format(pattern),
    use_regex = true,
    search = pattern,
  }
end)

nnoremap("<leader>rw", function()
  local word = vim.fn.expand "<cword>"
  builtin.grep_string {
    prompt_title = ("Find word (%s)"):format(word),
    search = word,
  }
end)

nnoremap("<leader>rW", function()
  local word = vim.fn.expand "<cWORD>"
  builtin.grep_string {
    prompt_title = ("Find WORD (%s)"):format(word),
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
  telescope.extensions.installed_plugins.installed_plugins(themes.get_dropdown {
    layout_config = {
      width = _PackerPluginInfo.max_length + 10,
      height = 0.8,
    },
    previewer = false,
  })
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
  telescope.extensions.lir_cd.lir_cd(themes.get_dropdown {
    layout_config = {
      width = function(_, editor_width, _)
        return math.min(100, editor_width - 10)
      end,
      height = 0.8,
    },
    previewer = false,
  })
end

-- List out all the saved sessions and provide action to either open them or
-- delete them.
local function sessions()
  telescope.extensions.sessions.sessions(themes.get_dropdown {
    layout_config = {
      width = 40,
      height = 0.5,
    },
    previewer = false,
  })
end

nnoremap("<leader>fs", sessions)

-- }}}2
-- }}}1

-- Used in Lir and Dashboard
return {
  lir_cd = lir_cd,
  sessions = sessions,
}
