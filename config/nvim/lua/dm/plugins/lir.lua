local api = vim.api
local actions = require 'lir.actions'
local lir = require 'lir'
local mark_actions = require 'lir.mark.actions'

-- Go to the git root directory for the current directory using lspconfig
-- util function.
local function goto_git_root()
  local ok, util = pcall(require, 'lspconfig.util')
  if not ok then
    return
  end
  local dir = util.find_git_ancestor(vim.fn.getcwd())
  if dir == nil or dir == '' then
    return
  end
  vim.cmd('edit ' .. dir)
end

-- Enhanced clipboard actions. This will automatically mark either the
-- current selection or visually selected items and call the respective
-- clipboard action.
local clipboard_actions = setmetatable({}, {
  __index = function(_, action)
    return function(mode)
      mark_actions.mark(mode)
      require('lir.clipboard.actions')[action]()
    end
  end,
})

-- Construct the Lir floating window options according to the window we are
-- currently in. The position of the window will be centered in the current
-- window, thus not blocking other windows if opened.
---@return table<string, any>
local function construct_win_opts()
  local winwidth = api.nvim_win_get_width(0)
  local winheight = api.nvim_win_get_height(0)

  local width = math.min(80, winwidth - 14)
  local height = winheight - 6
  local row = (winheight / 2) - (height / 2) - 1
  local col = (winwidth / 2) - (width / 2)

  return {
    border = dm.border[vim.g.border_style],
    col = col,
    height = height,
    relative = 'win',
    row = row,
    width = width,
  }
end

lir.setup {
  show_hidden_files = true,
  devicons = {
    enable = true,
    highlight_dirname = true,
  },
  hide_cursor = false,
  float = {
    winblend = 0,
    win_opts = construct_win_opts,
  },
  mappings = {
    ['q'] = actions.quit,
    ['cd'] = actions.cd,
    ['yy'] = actions.yank_path,
    ['.'] = actions.toggle_show_hidden,
    ['R'] = actions.reload,

    ['h'] = actions.up,
    ['l'] = actions.edit,
    ['<CR>'] = actions.edit,
    ['<C-s>'] = actions.split,
    ['<C-v>'] = actions.vsplit,
    ['<C-t>'] = actions.tabedit,

    ['d'] = actions.mkdir,
    ['f'] = actions.touch,
    ['r'] = actions.rename,
    ['x'] = actions.wipeout,

    -- <Space>/<C-Space> to toggle mark and move down/up
    ['<Space>'] = function()
      mark_actions.toggle_mark()
      vim.cmd 'normal! j'
    end,
    ['<C-Space>'] = function()
      mark_actions.toggle_mark()
      vim.cmd 'normal! k'
    end,

    -- Enhanced cut and copy.
    ['C'] = clipboard_actions.copy,
    ['X'] = clipboard_actions.cut,
    ['P'] = clipboard_actions.paste,

    -- Easy access to common places.
    ['~'] = function()
      vim.cmd('edit ' .. vim.loop.os_homedir())
    end,
    ['`'] = function()
      vim.cmd 'edit /'
      -- https://github.com/neovim/neovim/issues/13726
      vim.cmd 'doautocmd BufEnter'
    end,
    ['gr'] = goto_git_root,

    -- Open the current directory in finder
    ['gx'] = vim.fn['external#explorer'],

    -- Search and open Lir in any directory from the current one using Telescope
    -- Mapping is similar to `nnn`
    [';c'] = function()
      -- This is a callable metatable which is not accepted in `vim.keymap.set`.
      require('telescope').extensions.custom.lir_cd()
    end,
  },
}

vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'lir' },
  callback = function()
    -- These additional mappings allow us to visually select multiple items and
    -- then copy or cut them all at once.
    --
    -- They need to be defined here as using the setup table only maps to normal mode.
    vim.keymap.set('x', 'C', function()
      clipboard_actions.copy 'v'
    end, {
      buffer = true,
      desc = 'Lir: Copy visual selection',
    })

    vim.keymap.set('x', 'X', function()
      clipboard_actions.cut 'v'
    end, {
      buffer = true,
      desc = 'Lir: Cut visual selection',
    })
  end,
})

vim.keymap.set('n', '-', require('lir.float').toggle, { desc = 'Lir: Toggle' })
