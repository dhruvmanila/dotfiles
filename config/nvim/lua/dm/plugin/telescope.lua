local should_reload = true

if should_reload then
  RELOAD "plenary"
  RELOAD "popup"
  RELOAD "telescope"
end

local telescope = require "telescope"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local themes = require "telescope.themes"

local nnoremap = dm.nnoremap

-- Namespace to hold custom actions
local custom_actions = {}

-- Yank the selected entry into the selection register '*'
custom_actions.yank_entry = function()
  local entry = action_state.get_selected_entry()
  vim.fn.setreg(vim.api.nvim_get_vvar "register", entry.value)
end

-- Reset the prompt keeping the cursor at the current entry in the results window.
custom_actions.reset_prompt = function(prompt_bufnr)
  action_state.get_current_picker(prompt_bufnr):reset_prompt()
end

-- Default dropdown theme options.
local default_dropdown = themes.get_dropdown {
  layout_config = {
    width = 0.8,
    height = 0.8,
  },
  previewer = false,
}

-- Default ivy theme options.
local default_ivy = themes.get_ivy {
  layout_config = {
    height = 0.5,
  },
}

-- Default options for LSP code action picker.
local default_code_action = themes.get_cursor {
  layout_config = {
    width = function(picker, editor_width, _)
      local strings = require "plenary.strings"
      local max_width = 0
      for _, entry in ipairs(picker.finder.results) do
        max_width = math.max(
          max_width,
          strings.strdisplaywidth(entry.client_name)
            + strings.strdisplaywidth(entry.command_title)
            + 2 -- idx + ':'
            + 3 -- spaces which separates the columns
            + 2 -- prompt prefix + padding
        )
      end
      return math.min(editor_width - 4, max_width)
    end,
    height = function(picker, _, editor_height)
      return math.min(editor_height - 4, #picker.finder.results)
    end,
  },
}

telescope.setup {
  defaults = {
    prompt_prefix = " ",
    selection_caret = "❯ ",
    sorting_strategy = "ascending",
    winblend = vim.g.window_blend,
    file_ignore_patterns = { "__pycache__", ".mypy_cache" },
    layout_strategy = "flex",
    layout_config = {
      prompt_position = "top",
      height = { padding = 4 },
      horizontal = {
        width = { padding = 14 },
        preview_width = 0.55,
      },
      vertical = {
        width = { padding = 8 },
        preview_height = 0.5,
        mirror = true,
      },
      flex = {
        flip_columns = 120,
      },
    },
    mappings = {
      i = {
        ["<Esc>"] = actions.close,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        ["<C-s>"] = actions.select_horizontal,
        ["<C-y>"] = custom_actions.yank_entry,
        ["<C-l>"] = custom_actions.reset_prompt,
      },
    },
  },
  pickers = {
    buffers = {
      sort_lastused = true,
      show_all_buffers = true,
      theme = "dropdown",
      previewer = false,
      mappings = {
        i = {
          ["<C-x>"] = actions.delete_buffer,
        },
        n = {
          ["<C-x>"] = actions.delete_buffer,
        },
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
        width = 0.8,
        horizontal = {
          preview_width = 0.65,
        },
      },
    },
    highlights = {
      layout_config = {
        width = 0.8,
        horizontal = {
          preview_width = 0.65,
        },
      },
    },
    command_history = default_ivy,
    search_history = default_ivy,
    current_buffer_fuzzy_find = default_dropdown,
    vim_options = default_dropdown,
    keymaps = default_dropdown,
    commands = default_dropdown,
    lsp_code_actions = default_code_action,
    lsp_range_code_actions = default_code_action,
    git_branches = {
      theme = "dropdown",
      previewer = false,
    },
  },
  extensions = {
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
}

-- Load the telescope extensions without blowing up. It only emits a
-- small warning. Only the required extensions are loaded, the others
-- will be loaded lazily by telescope.
do
  local extensions = {
    "fzf",
    "github_stars",
  }

  for _, name in ipairs(extensions) do
    local loaded, _ = pcall(telescope.load_extension, name)
    if not loaded then
      vim.notify(
        { "Telescope", "", "Failed to load the extension: '" .. name .. "'" },
        3
      )
    end
  end
end

-- NOTE: This must be required after setting up telescope otherwise the result
-- will be cached without the updates from the setup call.
local builtin = require "telescope.builtin"

-- This is mainly to avoid .gitignore patterns.
local function find_all_files()
  builtin.find_files {
    prompt_title = "Find All Files",
    find_command = {
      "fd",
      "--type",
      "f",
      "--hidden",
      "--follow",
      "--exclude",
      ".git",
      "--no-ignore",
    },
  }
end

local function grep_prompt()
  builtin.grep_string {
    use_regex = true,
    search = vim.fn.input "Grep pattern > ",
  }
end

local function find_dotfiles()
  builtin.find_files {
    prompt_title = "Find dotfiles",
    cwd = "~/dotfiles",
    hidden = true,
    follow = true,
    file_ignore_patterns = { ".git/" },
  }
end

-- List out all the installed plugins and provide action to either go to the
-- GitHub page of the plugin or find files within the plugin using telescope.
local function installed_plugins()
  telescope.extensions.installed_plugins.installed_plugins(themes.get_dropdown {
    layout_config = {
      width = _PackerPluginInfo.max_length + 10,
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

-- Using `ddgr/googler` search the web and fuzzy find through the results and
-- open them up in the browser.
local function websearch()
  telescope.extensions.websearch.websearch(default_dropdown)
end

-- Fuzzy find over your browser bookmarks.
local function bookmarks()
  telescope.extensions.bookmarks.bookmarks(default_dropdown)
end

-- Gaze the stars with the power of telescope.
local function github_stars()
  telescope.extensions.github_stars.github_stars(default_dropdown)
end

-- Meta
nnoremap { "<leader>te", builtin.builtin }

-- Files
nnoremap { "<C-p>", builtin.find_files }
nnoremap { "<C-f>", builtin.current_buffer_fuzzy_find }
nnoremap { "<leader>;", builtin.buffers }
nnoremap { "<leader>fd", find_dotfiles }
nnoremap { "<leader>fa", find_all_files }

-- Grep
nnoremap { "<leader>rp", grep_prompt }
nnoremap { "<leader>rg", builtin.live_grep }

-- Git
nnoremap { "<leader>gc", builtin.git_commits }
nnoremap { ";b", builtin.git_branches }

-- Neovim
nnoremap { "<leader>fh", builtin.help_tags }
nnoremap { "<leader>fm", builtin.keymaps }
nnoremap { "<leader>fc", builtin.commands }
nnoremap { "<leader>hi", builtin.highlights }
nnoremap { "<leader>vo", builtin.vim_options }
nnoremap { "<leader>:", builtin.command_history }
nnoremap { "<leader>/", builtin.search_history }

-- Extensions
nnoremap { "<leader>gs", github_stars }
nnoremap { "<leader>fp", installed_plugins }
nnoremap { "<leader>fb", bookmarks }
nnoremap { "<leader>fw", websearch }
nnoremap { "<leader>fs", sessions }
nnoremap { "<leader>fi", telescope.extensions.icons.icons }

-- Used in Dashboard
return { sessions = sessions }
