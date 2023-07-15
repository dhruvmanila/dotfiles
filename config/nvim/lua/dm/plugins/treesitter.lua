return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'BufReadPre',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'IndianBoy42/tree-sitter-just',
    },
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        -- A list of parser names, or "all"
        ensure_installed = {
          'bash',
          'c',
          'cmake',
          'comment',
          'cpp',
          'dockerfile',
          'fish',
          'gitattributes',
          'gitignore',
          'go',
          'gomod',
          'gowork',
          'hcl',
          'java',
          'javascript',
          'json',
          'jsonc',
          -- 'just',
          'lalrpop',
          'lua',
          'make',
          'markdown',
          'markdown_inline',
          'python',
          'query',
          'ruby',
          'rust',
          'scheme',
          'toml',
          'typescript',
          'vim',
          'vimdoc',
          'yaml',
        },

        highlight = {
          enable = true,
        },

        playground = {
          enable = true,
          updatetime = 25,
        },

        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = 'gn',
            node_incremental = '<C-n>',
            scope_incremental = '<C-s>',
            node_decremental = '<C-p>',
          },
        },

        textobjects = {
          select = {
            enable = true,
            keymaps = {
              ['aC'] = '@class.outer',
              ['iC'] = '@class.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['aF'] = '@call.outer',
              ['iF'] = '@call.inner',
              ['ac'] = '@conditional.outer',
              ['ic'] = '@conditional.inner',
              ['ao'] = '@loop.outer',
              ['io'] = '@loop.inner',
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
            },
            selection_modes = {
              ['@function.outer'] = 'V',
              ['@function.inner'] = 'V',
            },
          },

          swap = {
            enable = true,
            swap_next = {
              [']a'] = '@parameter.inner',
            },
            swap_previous = {
              ['[a'] = '@parameter.inner',
            },
          },

          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']f'] = '@function.outer',
              [']]'] = '@class.outer',
            },
            goto_previous_start = {
              ['[f'] = '@function.outer',
              ['[['] = '@class.outer',
            },
          },
        },
      }
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'BufReadPre',
    opts = {
      mode = 'cursor',
      separator = '─',
    },
  },

  {
    'nvim-treesitter/playground',
    cmd = { 'TSPlaygroundToggle' },
    keys = {
      { '<Leader>tp', '<Cmd>TSPlaygroundToggle<CR>' },
      { '<Leader>th', '<Cmd>TSHighlightCapturesUnderCursor<CR>' },
    },
    dependencies = { 'nvim-treesitter' },
  },

  {
    'danymat/neogen',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    keys = {
      { '<leader>nn', '<Cmd>Neogen<CR>' },
      {
        '<leader>ng',
        function()
          require('neogen').generate {
            annotation_convention = {
              python = 'google_docstrings',
            },
          }
        end,
        desc = 'neogen: google docstring',
      },
    },
    opts = {
      snippet_engine = 'luasnip',
      placeholders_hl = 'None',
      languages = {
        python = {
          template = {
            -- Update the default annotation convention.
            annotation_convention = 'numpydoc',
          },
        },
      },
    },
  },
}
