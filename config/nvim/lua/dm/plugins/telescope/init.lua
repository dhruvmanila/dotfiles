return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
      {
        'dhruvmanila/browser-bookmarks.nvim',
        opts = {
          selected_browser = 'brave',
          url_open_command = vim.g.open_command,
          full_path = false,
        },
      },
    },
    config = function()
      local action_layout = require 'telescope.actions.layout'
      local actions = require 'telescope.actions'
      local entry_display = require 'telescope.pickers.entry_display'
      local telescope = require 'telescope'

      local custom_actions = require 'dm.plugins.telescope.actions'

      telescope.setup {
        defaults = {
          prompt_prefix = ' ',
          selection_caret = '❯ ',
          sorting_strategy = 'ascending',
          layout_strategy = 'flex',
          layout_config = {
            prompt_position = 'top',
            horizontal = {
              width = { padding = 14 },
              height = { padding = 3 },
              preview_width = 0.55,
            },
            vertical = {
              width = { padding = 8 },
              height = { padding = 1 },
              preview_height = 0.6,
              preview_cutoff = 30,
              mirror = true,
            },
            flex = {
              flip_columns = 140,
            },
          },
          preview = {
            hide_on_startup = true,
          },
          mappings = {
            i = {
              ['<C-x>'] = false,
              ['<C-u>'] = false,
              ['<C-d>'] = false,
              ['<Esc>'] = actions.close,
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              ['<Up>'] = actions.cycle_history_prev,
              ['<Down>'] = actions.cycle_history_next,
              ['<C-f>'] = actions.preview_scrolling_down,
              ['<C-b>'] = actions.preview_scrolling_up,
              ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
              ['<C-s>'] = actions.select_horizontal,
              ['<C-p>'] = action_layout.toggle_preview,
              ['<C-y>'] = custom_actions.yank_entry,
              ['<C-c>'] = custom_actions.stop_insert,
              ['<A-q>'] = custom_actions.qflist_tab_session,
            },
          },
        },
        pickers = {
          buffers = {
            sort_lastused = true,
            sort_mru = true,
            ignore_current_buffer = true,
            theme = 'dropdown',
            previewer = false,
            mappings = {
              i = { ['<C-d>'] = actions.delete_buffer },
              n = { ['<C-d>'] = actions.delete_buffer },
            },
          },
          builtin = {
            theme = 'dropdown',
            layout_config = {
              width = 50,
              height = 0.5,
            },
            include_extensions = true,
            use_default_opts = true,
          },
          diagnostics = {
            sort_by = 'severity',
          },
          git_commits = {
            layout_strategy = 'vertical',
          },
          git_files = {
            show_untracked = true,
          },
          git_branches = {
            theme = 'dropdown',
            layout_config = {
              width = 0.5,
            },
            mappings = {
              i = {
                ['<CR>'] = custom_actions.git_create_or_checkout_branch,
              },
            },
          },
          grep_string = {
            path_display = { truncate = 3 },
          },
          live_grep = {
            path_display = { truncate = 3 },
          },
        },
        extensions = {
          fzf = {
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
          custom = {
            websearch = {
              search_engine = 'duckduckgo',
              -- For DuckDuckGo max results can be either [1, 25] which is the actual
              -- number of results to fetch or 0 which means to fetch all the results
              -- from the first page.
              max_results = 0,
            },
          },
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
            specific_opts = {
              ['session'] = {
                make_displayer = function()
                  return entry_display.create {
                    separator = ' ',
                    items = {
                      { width = 1 },
                      { width = 0.5 },
                      { remaining = true },
                    },
                  }
                end,
                make_display = function(displayer)
                  return function(entry)
                    local session = entry.value.text
                    ---@cast session Session
                    return displayer {
                      { session:is_active() and '' or ' ', 'Green' },
                      session.project:gsub(vim.g.os_homedir, ''):sub(2),
                      { session.branch, 'AquaBold' },
                    }
                  end
                end,
              },
            },
          },
        },
      }

      -- Define the telescope mappings.
      require 'dm.plugins.telescope.mappings'

      -- Load the telescope extensions without blowing up.
      pcall(telescope.load_extension, 'fzf')

      -- Custom extensions. The extensions are lazily loaded whenever they're called.
      pcall(telescope.load_extension, 'custom')

      -- Loading the extension will increase the startuptime, so defer it when the
      -- function is called.
      vim.ui.select = function(...)
        -- This will override the `vim.ui.select` function with a new implementation.
        telescope.load_extension 'ui-select'
        vim.ui.select(...)
      end

      -- Start the background job for collecting the GitHub stars. This will be cached
      -- and used by `custom.github_stars` extension.
      if dm.executable 'gh' then
        require('dm.gh').collect_stars()
      end
    end,
  },
}
