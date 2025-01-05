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
          'ini',
          'java',
          'javascript',
          'json',
          'jsonc',
          -- 'just',
          'lalrpop',
          'make',
          'requirements',
          'ruby',
          'rust',
          'scheme',
          'swift',
          'toml',
          'typescript',
          'yaml',
        },

        highlight = {
          enable = true,
        },

        incremental_selection = {
          enable = true,
          keymaps = {
            node_incremental = 'v',
            node_decremental = 'V',
            scope_incremental = '<C-s>',
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
    opts = {
      mode = 'topline',
      separator = '─',
      max_lines = math.floor(vim.o.lines * 0.2),
      multiline_threshold = 1,
    },
    config = function(_, opts)
      require('treesitter-context').setup(opts)

      vim.keymap.set('n', '<leader>tc', '<Cmd>TSContextToggle<CR>')
    end,
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
