local api = vim.api
local lir = require "lir"
local actions = require "lir.actions"
local mark_actions = require "lir.mark.actions"
local clipboard_actions = require "lir.clipboard.actions"

local Path = require "plenary.path"
local M = {}

-- Helper function to jump the cursor to the given name (file/directory)
---@param name string
local function cursor_jump(name)
  local lnum = lir.get_context():indexof(name)
  if lnum then
    vim.cmd(tostring(lnum))
  end
end

-- Alternative to the builtin `new_file` function. This creates a new file
-- in the file system and puts the cursor above the file, similar to `mkdir`.
-- Original implementation just creates a vim buffer and opens it.
function actions.newfile()
  local name = vim.fn.input "Create file: "
  if name == "" then
    return
  end

  local ctx = lir.get_context()
  local path = Path:new(ctx.dir .. name)
  if path:exists() then
    vim.notify("[lir]: File already exists", 3)
    cursor_jump(name)
    return
  end

  path:touch()
  actions.reload()

  vim.schedule(function()
    cursor_jump(name)
  end)
end

-- Go to the git root directory for the current directory using lspconfig
-- util function.
local function goto_git_root()
  local ok, util = pcall(require, "lspconfig.util")
  if not ok then
    return
  end
  local dir = util.find_git_ancestor(vim.fn.getcwd())
  if dir == nil or dir == "" then
    return
  end
  vim.cmd("edit " .. dir)
end

---@alias Action '"copy"'|'"cut"'
---@alias Mode '"n"'|'"v"'
---Enhanced clipboard actions. This will automatically mark either the
---current selection or visually selected items and call the respective
---clipboard action.
---@param action Action
---@param mode Mode
function M.clipboard_action(action, mode)
  mode = mode or "n"
  mark_actions.mark(mode)
  clipboard_actions[action]()
end

-- Construct the Lir floating window options according to the window we are
-- currently in. The position of the window will be centered in the current
-- window, thus not blocking other windows if opened.
---@return table<string, any>
local function construct_win_opts()
  local winpos = api.nvim_win_get_position(0)
  local winwidth = api.nvim_win_get_width(0)
  local winheight = api.nvim_win_get_height(0)

  local width = math.min(80, winwidth - 14)
  local height = winheight - 6
  local row = (winheight / 2) - (height / 2) - 1
  local col = (winwidth / 2) - (width / 2)

  return {
    width = width,
    height = height,
    row = row + winpos[1],
    col = col + winpos[2],
    border = dm.border[vim.g.border_style],
  }
end

-- Start a telescope search to cd into any directory from the current one.
-- The keybinding is defined only for the lir buffer.
local function lir_cd()
  -- Previewer is turned off by default. If it is enabled, then use the
  -- horizontal layout with wider results window and narrow preview window.
  require("telescope").extensions.lir_cd.lir_cd(
    require("telescope.themes").get_dropdown {
      layout_config = {
        width = function(_, editor_width, _)
          return math.min(100, editor_width - 10)
        end,
        height = 0.8,
      },
      previewer = false,
    }
  )
end

lir.setup {
  show_hidden_files = true,
  devicons_enable = true,
  hide_cursor = false,
  float = {
    winblend = vim.g.window_blend,
    win_opts = construct_win_opts,
  },
  mappings = {
    ["q"] = actions.quit,
    ["l"] = actions.edit,
    ["<CR>"] = actions.edit,
    ["h"] = actions.up,

    -- Consistent with telescope and nvim-tree.
    ["<C-s>"] = actions.split,
    ["<C-v>"] = actions.vsplit,
    ["<C-t>"] = actions.tabedit,

    -- Actions should be similar to that of nnn for consistency
    ["@"] = actions.cd,
    ["."] = actions.toggle_show_hidden,
    ["nd"] = actions.mkdir,
    ["nf"] = actions.newfile,
    ["yy"] = actions.yank_path,
    ["r"] = actions.rename,
    ["x"] = actions.delete,

    -- <Space> to toggle mark and move down
    ["<Space>"] = function()
      mark_actions.toggle_mark()
      vim.cmd "normal! j"
    end,

    -- <CTRL-Space> to toggle mark and move up
    ["<C-Space>"] = function()
      mark_actions.toggle_mark()
      vim.cmd "normal! k"
    end,

    -- Enhanced cut and copy.
    ["C"] = function()
      M.clipboard_action "copy"
    end,
    ["X"] = function()
      M.clipboard_action "cut"
    end,
    ["P"] = clipboard_actions.paste,

    -- Easy access to home, root and git root directory
    ["~"] = function()
      vim.cmd("edit " .. vim.loop.os_homedir())
    end,
    ["`"] = function()
      vim.cmd "edit /"
      -- https://github.com/neovim/neovim/issues/13726
      vim.cmd "doautocmd BufEnter"
    end,
    ["gr"] = goto_git_root,

    -- Open the current directory in finder
    ["gx"] = function()
      vim.cmd "call external#explorer()"
    end,

    -- Search and open Lir in any directory from the current one using Telescope
    -- Mapping is similar to `nnn`
    [";c"] = lir_cd,
  },
}

dm.nnoremap("-", require("lir.float").toggle)

return M
