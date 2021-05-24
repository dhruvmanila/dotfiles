local lir = require("lir")
local utils = require("lir.utils")
local actions = require("lir.actions")
local mark_actions = require("lir.mark.actions")
local clipboard_actions = require("lir.clipboard.actions")

local Path = require("plenary.path")
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
  local name = vim.fn.input("Create file: ")
  if name == "" then
    return
  end

  local ctx = lir.get_context()
  local path = Path:new(ctx.dir .. name)
  if path:exists() then
    utils.error("[lir] File already exists")
    cursor_jump(name)
    return
  end

  path:touch()
  actions.reload()

  vim.schedule(function()
    cursor_jump(name)
  end)
end

---Enhanced clipboard actions. This will automatically mark either the
---current selection or visually selected items and call the respective
---clipboard action.
---@param action string one of "copy" or "cut"
---@param mode string one of "n" or "v" (default: "n")
function M.clipboard_action(action, mode)
  mode = mode or "n"
  mark_actions.mark(mode)
  clipboard_actions[action]()
end

lir.setup({
  show_hidden_files = true,
  devicons_enable = true,
  hide_cursor = true,
  float = {
    size_percentage = { width = 0.4, height = 0.8 },
    winblend = 0,
    border = true,
    borderchars = require("core.icons").border.edgechars,
    -- shadow = true,
  },
  mappings = {
    ["q"] = actions.quit,
    ["l"] = actions.edit,
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
      vim.cmd("normal! j")
    end,

    -- <CTRL-Space> to toggle mark and move up
    ["<C-Space>"] = function()
      mark_actions.toggle_mark()
      vim.cmd("normal! k")
    end,

    -- Enhanced cut and copy.
    ["C"] = function()
      M.clipboard_action("copy")
    end,
    ["X"] = function()
      M.clipboard_action("cut")
    end,
    ["P"] = clipboard_actions.paste,
  },
})

-- Similar to dirvish
vim.api.nvim_set_keymap("n", "-", [[<Cmd>lua require('lir.float').toggle()<CR>]], {
  noremap = true,
})

return M