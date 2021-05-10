local packer = require("packer")
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  execute(
    "!git clone https://github.com/wbthomason/packer.nvim " .. install_path
  )
  execute("packadd packer.nvim")
end

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

--[[
Notes:

A lot of the plugins will be lazy loaded on keys/commands to improve the
startup time. There are two ways of doing this:

- Keep the plugins keymap separated in the respective plugin configuration file
which in this case will be lua/plugin/*.lua files. Add the plugin configuration
to be lazy loaded on those keys.

- Add the plugins keymap in the core/mappings.lua file which will be loaded on
startup. Add the plugin configuration to be lazy loaded on the commands to
which the keys were bound to.

--]]
packer.startup({
  function(use)
    -- Packer
    use("wbthomason/packer.nvim")

    -- Color scheme
    use({ "sainnhe/gruvbox-material", config = "require('plugin.colorscheme')" })

    -- Helpful in visualizing colors live in the editor
    use({
      "norcalli/nvim-colorizer.lua",
      keys = { { "n", "<Leader>cc" } },
      config = function()
        vim.api.nvim_set_keymap(
          "n",
          "<Leader>cc",
          "<Cmd>ColorizerToggle<CR>",
          { noremap = true }
        )
        require("colorizer").setup()
      end,
    })

    -- Icons
    use({
      {
        "kyazdani42/nvim-web-devicons",
        config = "require('plugin.nvim_web_devicons')",
      },
      "yamatsum/nvim-nonicons",
    })

    -- TODO: remove after #12587 is fixed (upstream bug)
    use("antoinemadec/FixCursorHold.nvim")
    use("~/git/pylance.nvim")

    -- LSP, auto completion and related
    use({
      "nvim-lua/lsp-status.nvim",
      { "kosayoda/nvim-lightbulb", opt = true },
      {
        "neovim/nvim-lspconfig",
        event = "BufReadPre",
        config = "require('plugin.lsp')",
      },
      {
        "hrsh7th/nvim-compe",
        event = "InsertEnter",
        config = "require('plugin.completion')",
      },
      { "glepnir/lspsaga.nvim", opt = true },
      -- TODO: keep either of them
      {
        "liuchengxu/vista.vim",
        keys = { { "n", "<Leader>vv" } },
        config = "require('plugin.vista')",
      },
      {
        "simrat39/symbols-outline.nvim",
        keys = { { "n", "<Leader>so" } },
        setup = "require('plugin.symbols_outline')",
        config = function()
          vim.api.nvim_set_keymap(
            "n",
            "<Leader>so",
            "<Cmd>SymbolsOutline<CR>",
            { noremap = true }
          )
        end,
      },
    })

    -- Linters and formatters (WIP plugins)
    use({
      "mfussenegger/nvim-lint",
      config = "require('plugin.lint')",
      opt = true,
    })

    -- Telescope and family
    use({
      {
        "~/git/telescope.nvim",
        event = "VimEnter",
        config = "require('plugin.telescope')",
        requires = {
          { "nvim-lua/popup.nvim" },
          { "nvim-lua/plenary.nvim" },
        },
      },
      { "~/projects/telescope-bookmarks.nvim" },
      { "nvim-telescope/telescope-fzy-native.nvim", opt = true },
      { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
      {
        "nvim-telescope/telescope-arecibo.nvim",
        rocks = {
          "lua-http-parser",
          {
            "openssl",
            env = { OPENSSL_DIR = "/usr/local/Cellar/openssl@1.1/1.1.1k" },
          },
        },
        opt = true,
      },
    })

    -- Treesitter
    use({
      {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufRead", "BufNewFile" },
        run = ":TSUpdate",
        config = "require('plugin.treesitter')",
      },
      {
        "nvim-treesitter/playground",
        cmd = "TSPlaygroundToggle",
        requires = "nvim-treesitter/nvim-treesitter",
      },
    })

    -- Language specific
    use({
      { "cespare/vim-toml", ft = "toml" },
      { "raimon49/requirements.txt.vim", ft = "requirements" },
      { "tjdevries/tree-sitter-lua", opt = true },
    })

    -- Git
    use({
      { "tpope/vim-fugitive", config = "require('plugin.fugitive')" },
      {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        requires = "nvim-lua/plenary.nvim",
        config = "require('plugin.gitsigns')",
      },
    })

    -- Comment
    use("tpope/vim-commentary")
    use("tpope/vim-scriptease")
    use("tpope/vim-eunuch")

    -- Pretification
    use({
      "junegunn/vim-easy-align",
      keys = { { "n", "ge" }, { "x", "ge" } },
      config = "require('plugin.easy_align')",
    })

    -- Using only the session management functionalities
    use("mhinz/vim-startify")

    -- File explorer (Mainly used for going through new projects)
    use({
      "kyazdani42/nvim-tree.lua",
      requires = { "kyazdani42/nvim-web-devicons" },
      keys = { { "n", "<C-n>" } },
      config = "require('plugin.nvim_tree')",
    })

    -- Path navigator
    use({
      { "justinmk/vim-dirvish", config = "require('plugin.dirvish')" },
      -- TODO: use vim-eunuch instead
      { "roginfarrer/vim-dirvish-dovish", branch = "main" },
    })

    -- Indentation tracking
    use({
      "lukas-reineke/indent-blankline.nvim",
      branch = "lua",
      event = { "BufRead", "BufNewFile" },
      config = "require('plugin.indentline')",
      disable = true,
    })

    -- Search
    -- TODO: Convert this to lua :)
    use({ "romainl/vim-cool", config = [[vim.g.CoolTotalMatches = 1]] })

    -- Profiling
    use({ "tweekmonster/startuptime.vim", cmd = "StartupTime" })

    -- Open external browsers, editor, finder from Neovim
    use({ "itchyny/vim-external", config = "require('plugin.vim_external')" })
  end,

  config = {
    profile = {
      enable = true,
      threshold = 0, -- ms
    },
  },
})
