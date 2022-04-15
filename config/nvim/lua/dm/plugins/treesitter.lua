vim.keymap.set('n', '<Leader>tp', '<Cmd>TSPlaygroundToggle<CR>')
vim.keymap.set('n', '<Leader>th', '<Cmd>TSHighlightCapturesUnderCursor<CR>')

-- Set custom capture groups defined in `highlights.scm`
require('nvim-treesitter.highlight').set_custom_captures {
  ['docstring'] = 'TSComment',
}

require('nvim-treesitter.configs').setup {
  -- Install the parsers synchronously on a fresh setup
  sync_install = vim.env.NVIM_BOOTSTRAP and true or false,

  -- A list of parser names, or "all"
  ensure_installed = {
    'bash',
    'c',
    'cmake',
    'comment',
    'cpp',
    'dockerfile',
    'fish',
    'go',
    'gomod',
    'gowork',
    'hcl',
    'javascript',
    'json',
    'jsonc',
    'lua',
    'make',
    'markdown',
    'python',
    'query',
    'rust',
    'scheme',
    'toml',
    'typescript',
    'vim',
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
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
    },
  },
}
