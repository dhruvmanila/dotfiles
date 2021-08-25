local g = vim.g
local cmd = vim.cmd
local packer = nil

-- Reset the global plugin info variable.
local function reset_plugin_info()
  _PackerPluginInfo = { plugins = {}, max_length = 0 }
end

-- Helper function to create the 'config' string value for packer.
---@param config_name string
---@return string
local function conf(config_name)
  if config_name == "lsp" then
    return ("require('dm.%s')"):format(config_name)
  end
  return ("R('dm.plugin.%s')"):format(config_name)
end

-- Extending packer with a custom handler to store plugin information to be
-- used by `:Telescope packer_plugins`
---@param plugin table
---@param type string
local function packer_type_handler(_, plugin, type)
  local name = type == "local" and "local/" .. plugin.short_name or plugin.name
  _PackerPluginInfo.max_length = math.max(_PackerPluginInfo.max_length, #name)
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
      prompt_border = dm.border[vim.g.border_style],
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
    { "L3MON4D3/LuaSnip", config = conf "luasnip" },
    { "airblade/vim-rooter" },
    { "cespare/vim-toml" },
    { "dstein64/vim-startuptime", cmd = "StartupTime" },
    { "editorconfig/editorconfig-vim" },
    { "folke/lua-dev.nvim" },
    { "ggandor/lightspeed.nvim" },
    {
      "hrsh7th/nvim-cmp",
      config = conf "completion",
      requires = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
      },
    },
    { "itchyny/vim-external" },
    { "junegunn/vim-easy-align" },
    { "kyazdani42/nvim-web-devicons" },
    { "lewis6991/gitsigns.nvim", event = "BufRead", config = conf "gitsigns" },
    {
      "mfussenegger/nvim-dap",
      keys = { { "n", "<leader>db" }, { "n", "<leader>dc" } },
      config = conf "nvim_dap",
    },
    { "mfussenegger/nvim-dap-python" },
    { "mfussenegger/nvim-lint" },
    { "milisims/nvim-luaref" },
    { "nanotee/luv-vimdocs" },
    { "neovim/nvim-lspconfig", event = "BufReadPre", config = conf "lsp" },
    {
      "norcalli/nvim-colorizer.lua",
      keys = "<leader>cc",
      config = conf "colorizer",
    },
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
    {
      "nvim-telescope/telescope.nvim",
      event = "CursorHold",
      config = conf "telescope",
    },
    { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },
    { "nvim-treesitter/nvim-treesitter-textobjects" },
    { "nvim-treesitter/playground" },
    { "raimon49/requirements.txt.vim" },
    { "rcarriga/nvim-dap-ui" },
    { "rcarriga/nvim-notify" },
    { "rhysd/committia.vim" },
    { "rhysd/git-messenger.vim" },
    { "romainl/vim-cool" },
    { "tamago324/lir.nvim", keys = "-", config = conf "lir" },
    { "tpope/vim-commentary" },
    { "tpope/vim-eunuch" },
    { "tpope/vim-fugitive" },
    { "tpope/vim-repeat" },
    { "tpope/vim-rhubarb" },
    { "tpope/vim-scriptease" },
    { "tpope/vim-surround" },
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
  local lines = ("_G._PackerPluginInfo = %s\n"):format(
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
