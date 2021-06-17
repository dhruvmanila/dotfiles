local g = vim.g
local fn = vim.fn
local cmd = vim.cmd
local format = string.format
local packer = nil

do
  local install_path = fn.stdpath "data" .. "/site/pack/packer/opt/packer.nvim"

  if not vim.loop.fs_stat(install_path) then
    print "Installing packer.nvim..."
    cmd("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
  end
end

-- Reset the global plugin info variable.
local function reset_plugin_info()
  _PackerPluginInfo = { plugins = {}, max_length = 0 }
end

-- Helper function to create the 'config' string value for packer.
---@param config_name string
---@return string
local function conf(config_name)
  if config_name == "lsp" then
    return format("require('dm.%s')", config_name)
  end
  return format("require('dm.plugin.%s')", config_name)
end

-- Extending packer with a custom handler to store plugin information to be
-- used by `:Telescope packer_plugins`
---@param plugin table
---@param type string
local function packer_type_handler(_, plugin, type)
  local name = type == "local" and "local/" .. plugin.short_name or plugin.name
  local length = #name

  if length > _PackerPluginInfo.max_length then
    _PackerPluginInfo.max_length = length
  end

  table.insert(_PackerPluginInfo.plugins, {
    name = name,
    path = plugin.install_path,
    url = type == "git" and plugin.url or nil,
  })
end

-- Load the packer.nvim plugin. This will set the 'packer' variable to the module,
-- initialize it and set the custom handler for storing plugin information.
local function load_packer()
  cmd "packadd packer.nvim"
  packer = require "packer"
  packer.init {
    compile_path = g.packer_compiled_path,
    disable_commands = true,
    display = {
      open_cmd = "silent botright 80vnew packer",
    },
    profile = {
      enable = true,
      threshold = 0, -- ms
    },
  }
  packer.set_handler("type", packer_type_handler)
end

-- Load the plugin specification. The information is always reset to always
-- keep the internal specification table in sync with the user table. The
-- plugin info variable is also reset to avoid having duplicate entries.
local function load_plugins()
  reset_plugin_info()
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
    { "wbthomason/packer.nvim", opt = true },
    { "yamatsum/nvim-nonicons" },
    { "~/projects/telescope-bookmarks.nvim" },
  }
end

-- Dump the plugin information from the global variable in a file to persist
-- across Neovim sessions. This will then be loaded automatically by Neovim
-- on startup as the file is in runtime path.
local function dump_plugin_info()
  local lines = format(
    "_G._PackerPluginInfo = %s\n",
    vim.inspect(_PackerPluginInfo)
  )
  local file = io.open(g.packer_plugin_info_path, "w")
  file:write(lines)
  file:close()
  cmd("source " .. g.packer_plugin_info_path)
end

return setmetatable({ dump = dump_plugin_info }, {
  __index = function(_, key)
    if not packer then
      load_packer()
    end
    load_plugins()
    return packer[key]
  end,
})
