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
          dynamic_preview_title = true,
          results_title = false,
          layout_strategy = 'flex',
          layout_config = {
            prompt_position = 'top',
            horizontal = {
              width = { padding = 6 },
              height = { padding = 1 },
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
          cache_picker = {
            ignore_empty_prompt = true,
          },
          mappings = {
            i = {
              ['<C-x>'] = false,
              ['<C-s>'] = actions.select_horizontal,
              ['<C-p>'] = action_layout.toggle_preview,
              ['<C-y>'] = custom_actions.yank_entry,
              -- By default, the binding is reversed
              ['<Esc>'] = actions.close,
              ['<C-c>'] = custom_actions.stop_insert,
              -- Current selection
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
              -- Prompt history
              ['<Up>'] = actions.cycle_history_prev,
              ['<Down>'] = actions.cycle_history_next,
              ['<C-n>'] = false,
              -- Preview scrolling
              ['<C-u>'] = false,
              ['<C-d>'] = false,
              ['<C-f>'] = actions.preview_scrolling_down,
              ['<C-b>'] = actions.preview_scrolling_up,
              -- Quickfix list
              ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
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
          colorscheme = {
            enable_preview = true,
          },
          diagnostics = {
            sort_by = 'severity',
          },
          git_commits = {
            layout_strategy = 'vertical',
          },
          git_bcommits = {
            layout_strategy = 'vertical',
          },
          git_bcommits_range = {
            layout_strategy = 'vertical',
          },
          git_files = {
            show_untracked = true,
          },
          git_branches = {
            theme = 'dropdown',
            show_remote_tracking_branches = false,
            layout_config = {
              width = 0.7,
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
          keymaps = {
            show_plug = false,
          },
        },
        extensions = {
          fzf = {
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
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
                    if session.branch then
                      return displayer {
                        { session:is_active() and '' or ' ', 'Green' },
                        session.project:gsub(vim.g.os_homedir, ''):sub(2),
                        { session.branch, 'AquaBold' },
                      }
                    else
                      return displayer {
                        { session:is_active() and '' or ' ', 'Green' },
                        session.project:gsub(vim.g.os_homedir, ''):sub(2),
                      }
                    end
                  end
                end,
              },
            },
          },
        },
      }

      -- Define the telescope mappings.
      require 'dm.plugins.telescope.mappings'

      for _, extension in ipairs { 'fzf', 'custom', 'ui-select' } do
        -- Load the telescope extensions without blowing up.
        local ok, err = pcall(telescope.load_extension, extension)
        if not ok then
          dm.log.warn(err)
        end
      end

      -- Start the background job for collecting the GitHub stars. This will be cached
      -- and used by `custom.github_stars` extension.
      if dm.is_executable 'gh' then
        require('dm.gh').collect_stars()
      end
    end,
  },
}
