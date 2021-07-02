local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local themes = require "telescope.themes"

local should_reload = true

if should_reload then
  RELOAD "plenary"
  RELOAD "popup"
  RELOAD "telescope"
end

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

require("telescope").setup {
  defaults = {
    prompt_prefix = require("dm.icons").telescope .. " ",
    selection_caret = "❯ ",
    sorting_strategy = "ascending",
    winblend = vim.g.window_blend,
    file_ignore_patterns = { "__pycache__", ".mypy_cache" },
    layout_strategy = "flex",
    layout_config = {
      prompt_position = "top",
      width = { padding = 12 },
      height = { padding = 4 },
      horizontal = {
        preview_width = 0.55,
      },
      vertical = {
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
        height = function(_, _, editor_height)
          -- Number of listed buffers
          local buflisted = #vim.fn.getbufinfo { buflisted = 1 }
          return math.max(10, math.min(editor_height - 10, buflisted))
        end,
      },
    },
    live_grep = {
      shorten_path = true,
    },
    grep_string = {
      shorten_path = true,
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
    command_history = {
      theme = "ivy",
      layout_config = {
        height = 20,
      },
    },
    search_history = {
      theme = "ivy",
      layout_config = {
        height = 20,
      },
    },
    git_branches = {
      theme = "dropdown",
      previewer = false,
    },
    current_buffer_fuzzy_find = default_dropdown,
    vim_options = default_dropdown,
    keymaps = default_dropdown,
    commands = default_dropdown,
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
    local loaded, _ = pcall(require("telescope").load_extension, name)
    if not loaded then
      vim.notify("[Telescope] Failed to load the extension: " .. name, 3)
    end
  end
end

-- Entrypoints which will allow me to configure each command individually.
local M = {}

-- This is mainly to avoid .gitignore patterns.
function M.find_all_files()
  require("telescope.builtin").find_files {
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

function M.grep_prompt()
  require("telescope.builtin").grep_string {
    use_regex = true,
    search = vim.fn.input "Grep pattern > ",
  }
end

function M.find_dotfiles()
  require("telescope.builtin").find_files {
    prompt_title = "Find dotfiles",
    cwd = "~/dotfiles",
    hidden = true,
    follow = true,
    file_ignore_patterns = { ".git/" },
  }
end

-- List out all the installed plugins and provide action to either go to the
-- GitHub page of the plugin or find files within the plugin using telescope.
function M.installed_plugins()
  require("telescope").extensions.installed_plugins.installed_plugins(
    themes.get_dropdown {
      layout_config = {
        width = _PackerPluginInfo.max_length + 10,
        height = 0.8,
      },
      previewer = false,
    }
  )
end

-- List out all the saved startify sessions and provide action to either open
-- them or delete them.
function M.startify_sessions()
  require("telescope").extensions.startify_sessions.startify_sessions(
    themes.get_dropdown {
      layout_config = {
        width = 40,
        height = 0.5,
      },
      previewer = false,
    }
  )
end

-- Using `ddgr/googler` search the web and fuzzy find through the results and
-- open them up in the browser.
function M.websearch()
  require("telescope").extensions.websearch.websearch(default_dropdown)
end

-- Fuzzy find over your browser bookmarks.
function M.bookmarks()
  require("telescope").extensions.bookmarks.bookmarks(default_dropdown)
end

-- Gaze the stars with the power of telescope.
function M.github_stars()
  require("telescope").extensions.github_stars.github_stars(default_dropdown)
end

-- Start a telescope search to cd into any directory from the current one.
-- The keybinding is defined only for the lir buffer.
---@see `after/ftplugin/lir`
function M.lir_cd()
  -- Previewer is turned off by default. If it is enabled, then use the
  -- horizontal layout with wider results window and narrow preview window.
  require("telescope").extensions.lir_cd.lir_cd(themes.get_dropdown {
    layout_config = {
      width = function(_, editor_width, _)
        return math.min(100, editor_width - 10)
      end,
      height = 0.8,
    },
    previewer = false,
  })
end

do
  local nvim_set_keymap = vim.api.nvim_set_keymap
  local opts = { noremap = true, silent = true }

  local mappings = {
    -- Meta
    ["<leader>te"] = "require('telescope.builtin').builtin()",

    -- Files
    ["<C-p>"] = "require('telescope.builtin').find_files()",
    ["<C-f>"] = "require('telescope.builtin').current_buffer_fuzzy_find()",
    ["<leader>;"] = "require('telescope.builtin').buffers()",
    ["<leader>fd"] = "require('dm.plugin.telescope').find_dotfiles()",
    ["<leader>fa"] = "require('dm.plugin.telescope').find_all_files()",

    -- Grep
    ["<leader>rp"] = "require('dm.plugin.telescope').grep_prompt()",
    ["<leader>rg"] = "require('telescope.builtin').live_grep()",

    -- Git
    ["<leader>gc"] = "require('telescope.builtin').git_commits()",
    [";b"] = "require('telescope.builtin').git_branches()",

    -- Neovim
    ["<leader>fh"] = "require('telescope.builtin').help_tags()",
    ["<leader>fm"] = "require('telescope.builtin').keymaps()",
    ["<leader>fc"] = "require('telescope.builtin').commands()",
    ["<leader>hi"] = "require('telescope.builtin').highlights()",
    ["<leader>vo"] = "require('telescope.builtin').vim_options()",
    ["<leader>:"] = "require('telescope.builtin').command_history()",
    ["<leader>/"] = "require('telescope.builtin').search_history()",

    -- Extensions
    ["<leader>gs"] = "require('dm.plugin.telescope').github_stars()",
    ["<leader>fp"] = "require('dm.plugin.telescope').installed_plugins()",
    ["<leader>fb"] = "require('dm.plugin.telescope').bookmarks()",
    ["<leader>fw"] = "require('dm.plugin.telescope').websearch()",
    ["<leader>fs"] = "require('dm.plugin.telescope').startify_sessions()",
  }

  for key, command in pairs(mappings) do
    command = "<Cmd>lua " .. command .. "<CR>"
    nvim_set_keymap("n", key, command, opts)
  end
end

return M
