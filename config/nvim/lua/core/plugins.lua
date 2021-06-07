local fn = vim.fn
local cmd = vim.api.nvim_command

do
  local install_path = fn.stdpath("data")
    .. "/site/pack/packer/start/packer.nvim"

  if fn.empty(fn.glob(install_path)) > 0 then
    cmd("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
    cmd("packadd packer.nvim")
  end
end

local packer = require("packer")

-- PackerSync -> PackerUpdate + PackerClean + PackerCompile
vim.api.nvim_set_keymap(
  "n",
  "<leader>ps",
  "<Cmd>PackerSync<CR>",
  { noremap = true }
)

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
  return string.format("require('plugin.%s')", config_name)
end

packer.startup({
  function(use)
    -- Packer
    use("wbthomason/packer.nvim")

    -- Color scheme
    use({ "sainnhe/gruvbox-material", config = conf("colorscheme") })

    -- 40 width vertical split containing quick reference to mappings, etc.
    use(
      { "lifepillar/vim-cheat40", config = "vim.g.cheat40_use_default = false" }
    )

    -- Lua
    use({
      -- Lua related docs in vim help format
      { "nanotee/luv-vimdocs" },
      { "milisims/nvim-luaref" },

      -- LSP sumneko setup
      { "folke/lua-dev.nvim" },
      { "tjdevries/tree-sitter-lua", opt = true },
    })

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
      { "kyazdani42/nvim-web-devicons", config = conf("nvim_web_devicons") },
      "yamatsum/nvim-nonicons",
    })

    -- TODO: remove after #12587 is fixed (upstream bug)
    use("antoinemadec/FixCursorHold.nvim")

    -- Common config across editors and teams
    use({
      "editorconfig/editorconfig-vim",
      config = function()
        vim.g.EditorConfig_exclude_patterns = { "fugitive://.*", "scp://.*" }
        vim.g.EditorConfig_max_line_indicator = "none"
        vim.g.EditorConfig_preserve_formatoptions = 1
      end,
    })

    -- LSP, auto completion, linting and related
    use({
      "nvim-lua/lsp-status.nvim",
      { "kosayoda/nvim-lightbulb", opt = true },
      { "ray-x/lsp_signature.nvim", opt = true },
      { "neovim/nvim-lspconfig", event = "BufReadPre", config = conf("lsp") },
      { "hrsh7th/nvim-compe", event = "InsertEnter", config = conf("completion") },
      { "mfussenegger/nvim-lint", config = conf("lint") },
      {
        "liuchengxu/vista.vim",
        keys = { { "n", "<Leader>vv" } },
        config = conf("vista"),
      },
    })

    -- Telescope and family
    use({
      {
        "~/contributing/telescope.nvim",
        event = "VimEnter",
        config = conf("telescope"),
        requires = {
          { "nvim-lua/popup.nvim" },
          { "nvim-lua/plenary.nvim" },
        },
      },
      { "~/projects/telescope-bookmarks.nvim" },
      { "nvim-telescope/telescope-fzy-native.nvim", opt = true },
      { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
    })

    -- Treesitter
    use({
      {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufRead", "BufNewFile" },
        run = ":TSUpdate",
        config = conf("treesitter"),
      },
      {
        "nvim-treesitter/playground",
        cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
        requires = "nvim-treesitter/nvim-treesitter",
      },
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        after = "nvim-treesitter",
        requires = "nvim-treesitter/nvim-treesitter",
      },
    })

    -- Language specific
    use({
      { "cespare/vim-toml", ft = "toml" },
      { "raimon49/requirements.txt.vim", ft = "requirements" },
      { "vim-scripts/applescript.vim", ft = "applescript" },
    })

    -- Git
    use({
      { "tpope/vim-fugitive", config = conf("fugitive") },
      {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        requires = "nvim-lua/plenary.nvim",
        config = conf("gitsigns"),
      },
    })

    -- tpope
    use("tpope/vim-commentary")
    use("tpope/vim-scriptease")
    use("tpope/vim-eunuch")

    -- Motion
    use({
      "rhysd/clever-f.vim",
      setup = function()
        vim.g.clever_f_across_no_line = 1
        vim.g.clever_f_smart_case = 1
        vim.g.clever_f_show_prompt = 1
        -- `f;` and `f:` matches all signs
        vim.g.clever_f_chars_match_any_signs = ";:"
      end,
    })

    -- Pretification
    use({
      "junegunn/vim-easy-align",
      keys = { { "n", "ge" }, { "x", "ge" } },
      config = function()
        require("core.utils").map({ "n", "x" }, "ge", "<Plug>(EasyAlign)", {
          noremap = false,
          silent = true,
        })
      end,
    })

    -- Using only the session management functionalities
    use("mhinz/vim-startify")

    -- File explorer
    use({
      -- Project drawer style
      {
        "kyazdani42/nvim-tree.lua",
        requires = { "kyazdani42/nvim-web-devicons" },
        keys = { { "n", "<C-n>" } },
        config = conf("nvim_tree"),
      },
      -- Split/floating window style
      { "tamago324/lir.nvim", config = conf("lir") },
    })

    -- Indentation tracking
    use({
      "lukas-reineke/indent-blankline.nvim",
      branch = "lua",
      event = { "BufRead", "BufNewFile" },
      config = conf("indentline"),
      disable = true,
    })

    -- Search
    -- TODO: Convert this to lua :)
    use({ "romainl/vim-cool" })

    -- Profiling
    use({ "tweekmonster/startuptime.vim", cmd = "StartupTime" })

    -- Open external browsers, editor, finder from Neovim
    use({ "itchyny/vim-external", config = conf("vim_external") })
  end,

  config = {
    display = {
      open_cmd = "silent botright 80vnew packer",
      prompt_border = require("core.icons").border[vim.g.border_style],
    },
    profile = {
      enable = true,
      threshold = 0, -- ms
    },
  },
})
