local fn = vim.fn
local cmd = vim.api.nvim_command
local format = string.format

do
  local install_path = fn.stdpath "data"
    .. "/site/pack/packer/start/packer.nvim"

  if fn.empty(fn.glob(install_path)) > 0 then
    cmd("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
    cmd "packadd! packer.nvim"
  end
end

local packer = require "packer"
local packer_compiled_path = fn.stdpath "data"
  .. "/site/pack/loader/start/packer.nvim/plugin/packer_compiled.vim"

-- By always resetting, the plugins which were removed will be removed from
-- this table as well.
_CachedPluginInfo = { plugins = {}, max_length = 0 }

-- Extending packer.nvim to store plugin info to be used by
-- :Telescope packer_plugins
packer.set_handler("type", function(_, plugin, type)
  local name = type == "local" and "local/" .. plugin.short_name or plugin.name
  local length = #name

  if length > _CachedPluginInfo.max_length then
    _CachedPluginInfo.max_length = length
  end

  table.insert(_CachedPluginInfo.plugins, {
    name = name,
    path = plugin.install_path,
    url = type == "git" and plugin.url or nil,
  })
end)

-- Helper function to create the 'config' string value for packer.
---@param config_name string
---@return string
local function conf(config_name)
  return dm.case(config_name, {
    ["lsp"] = format("require('dm.%s')", config_name),
    ["*"] = format("require('dm.plugin.%s')", config_name),
  })
end

packer.init {
  compile_path = packer_compiled_path,
  display = {
    open_cmd = "silent botright 80vnew packer",
    prompt_border = require("dm.icons").border[vim.g.border_style],
  },
  profile = {
    enable = true,
    threshold = 0, -- ms
  },
}

-- This is recommended in case of re-running the specification code (e.g. by
-- sourcing the plugin specification file with `source %`)
packer.reset()

packer.use {
  { "airblade/vim-rooter" },
  { "antoinemadec/FixCursorHold.nvim" },
  { "cespare/vim-toml" },
  { "editorconfig/editorconfig-vim" },
  { "folke/lua-dev.nvim" },
  { "hrsh7th/nvim-compe", event = "InsertEnter", config = conf "completion" },
  { "itchyny/vim-external" },
  { "junegunn/vim-easy-align", keys = "<Plug>(EasyAlign)" },
  { "junegunn/vim-slash" },
  { "kosayoda/nvim-lightbulb", opt = true },
  { "kyazdani42/nvim-tree.lua", keys = "<C-n>", config = conf "nvim_tree" },
  { "kyazdani42/nvim-web-devicons" },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = conf "gitsigns",
  },
  { "lifepillar/vim-cheat40" },
  { "liuchengxu/vista.vim", cmd = "Vista" },
  {
    "lukas-reineke/indent-blankline.nvim",
    branch = "lua",
    event = { "BufRead", "BufNewFile" },
    disable = true,
  },
  { "mfussenegger/nvim-lint" },
  { "mhinz/vim-startify" },
  { "milisims/nvim-luaref" },
  { "nanotee/luv-vimdocs" },
  { "neovim/nvim-lspconfig", event = "BufReadPre", config = conf "lsp" },
  {
    "norcalli/nvim-colorizer.lua",
    keys = "<leader>cc",
    config = conf "colorizer",
  },
  { "nvim-lua/lsp-status.nvim" },
  { "nvim-lua/plenary.nvim" },
  { "nvim-lua/popup.nvim" },
  { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    config = conf "telescope",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufRead", "BufNewFile" },
    run = ":TSUpdate",
    config = conf "treesitter",
  },
  { "nvim-treesitter/nvim-treesitter-textobjects", after = "nvim-treesitter" },
  {
    "nvim-treesitter/playground",
    cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
  },
  { "raimon49/requirements.txt.vim" },
  { "ray-x/lsp_signature.nvim", opt = true },
  { "rhysd/clever-f.vim" },
  { "sainnhe/gruvbox-material" },
  { "tamago324/lir.nvim" },
  { "tjdevries/tree-sitter-lua", opt = true },
  { "tpope/vim-commentary" },
  { "tpope/vim-eunuch" },
  { "tpope/vim-fugitive" },
  { "tpope/vim-scriptease" },
  { "tweekmonster/startuptime.vim", cmd = "StartupTime" },
  { "vim-scripts/applescript.vim" },
  { "wbthomason/packer.nvim" },
  { "yamatsum/nvim-nonicons" },
  { "~/projects/telescope-bookmarks.nvim" },
}

-- PackerSync -> PackerClean + PackerInstall + PackerUpdate + PackerCompile
vim.api.nvim_set_keymap(
  "n",
  "<leader>ps",
  "<Cmd>PackerSync<CR>",
  { noremap = true }
)

dm.command { "PackerCompiledEdit", function()
  vim.cmd("$tabedit " .. packer_compiled_path)
end }

-- Manual workaround until #405 is fixed and #402 is merged.
-- This is done so that the handlers get called on startup and store the
-- plugin information.
pcall(packer.__manage_all)
