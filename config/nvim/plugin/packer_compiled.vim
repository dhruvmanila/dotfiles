" Automatically generated packer.nvim plugin loader code

if !has('nvim-0.5')
  echohl WarningMsg
  echom "Invalid Neovim version for packer.nvim!"
  echohl None
  finish
endif

packadd packer.nvim

try

lua << END
  local time
  local profile_info
  local should_profile = true
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time("Luarocks path setup", true)
local package_path_str = "/Users/dhruvmanilawala/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/dhruvmanilawala/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/dhruvmanilawala/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/dhruvmanilawala/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/dhruvmanilawala/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time("Luarocks path setup", false)
time("try_loadstring definition", true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    print('Error running ' .. component .. ' for ' .. name)
    error(result)
  end
  return result
end

time("try_loadstring definition", false)
time("Defining packer_plugins", true)
_G.packer_plugins = {
  ["FixCursorHold.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/FixCursorHold.nvim"
  },
  ["applescript.vim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/applescript.vim"
  },
  ["clever-f.vim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/clever-f.vim"
  },
  ["gitsigns.nvim"] = {
    config = { "require('plugin.gitsigns')" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/gitsigns.nvim"
  },
  ["gruvbox-material"] = {
    config = { "require('plugin.colorscheme')" },
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/gruvbox-material"
  },
  ["lir.nvim"] = {
    config = { "require('plugin.lir')" },
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/lir.nvim"
  },
  ["lsp-status.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/lsp-status.nvim"
  },
  ["lsp_signature.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/lsp_signature.nvim"
  },
  ["lua-dev.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/lua-dev.nvim"
  },
  ["luv-vimdocs"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/luv-vimdocs"
  },
  ["nvim-colorizer.lua"] = {
    config = { "\27LJ\2\n°\1\0\0\6\0\n\0\0146\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0'\4\5\0005\5\6\0B\0\5\0016\0\a\0'\2\b\0B\0\2\0029\0\t\0B\0\1\1K\0\1\0\nsetup\14colorizer\frequire\1\0\1\fnoremap\2\29<Cmd>ColorizerToggle<CR>\15<Leader>cc\6n\20nvim_set_keymap\bapi\bvim\0" },
    keys = { { "n", "<Leader>cc" } },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-colorizer.lua"
  },
  ["nvim-compe"] = {
    after_files = { "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe/after/plugin/compe.vim" },
    config = { "\27LJ\2\nF\0\1\a\0\3\0\b6\1\0\0009\1\1\0019\1\2\1\18\3\0\0+\4\2\0+\5\2\0+\6\2\0D\1\5\0\27nvim_replace_termcodes\bapi\bvim£\1\0\0\6\0\b\2\0306\0\0\0009\0\1\0009\0\2\0'\2\3\0B\0\2\2\23\0\0\0\b\0\1\0X\1\16Ä6\1\0\0009\1\1\0019\1\4\1'\3\3\0B\1\2\2\18\3\1\0009\1\5\1\18\4\0\0\18\5\0\0B\1\4\2\18\3\1\0009\1\6\1'\4\a\0B\1\3\2\15\0\1\0X\2\3Ä+\1\2\0L\1\2\0X\1\2Ä+\1\1\0L\1\2\0K\0\1\0\a%s\nmatch\bsub\fgetline\6.\bcol\afn\bvim\2\0ï\1\0\0\3\2\6\1\0236\0\0\0009\0\1\0009\0\2\0B\0\1\2\t\0\0\0X\0\4Ä-\0\0\0'\2\3\0D\0\2\0X\0\fÄ-\0\1\0B\0\1\2\15\0\0\0X\1\4Ä-\0\0\0'\2\4\0D\0\2\0X\0\4Ä6\0\0\0009\0\1\0009\0\5\0D\0\1\0K\0\1\0\2¿\3¿\19compe#complete\n<Tab>\n<C-n>\15pumvisible\afn\bvim\2b\0\0\3\1\5\1\0146\0\0\0009\0\1\0009\0\2\0B\0\1\2\t\0\0\0X\0\4Ä-\0\0\0'\2\3\0D\0\2\0X\0\3Ä-\0\0\0'\2\4\0D\0\2\0K\0\1\0\2¿\f<S-Tab>\n<C-p>\15pumvisible\afn\bvim\2Ø\6\1\0\b\0+\0I6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\1\3\0\18\2\0\0'\4\4\0'\5\5\0'\6\6\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\a\0'\6\b\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\t\0'\6\n\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\v\0'\6\f\0\18\a\1\0B\2\5\1\18\2\0\0'\4\4\0'\5\r\0'\6\14\0\18\a\1\0B\2\5\1\18\2\0\0005\4\15\0'\5\16\0'\6\17\0005\a\18\0B\2\5\1\18\2\0\0005\4\19\0'\5\20\0'\6\21\0005\a\22\0B\2\5\0016\2\0\0'\4\23\0B\2\2\0029\2\24\0025\4\25\0005\5\27\0005\6\26\0=\6\28\0055\6\29\0=\6\30\0055\6\31\0=\6 \0055\6!\0=\6\"\5=\5#\4B\2\2\0013\2$\0003\3%\0006\4&\0003\5(\0=\5'\0046\4&\0003\5*\0=\5)\0042\0\0ÄK\0\1\0\0\19s_tab_complete\0\17tab_complete\a_G\0\0\vsource\rnvim_lua\1\0\1\rpriority\3\n\rnvim_lsp\1\0\1\rpriority\3\n\vbuffer\1\0\2\rpriority\3\b\tmenu\n[Buf]\tpath\1\0\0\1\0\1\rpriority\3\t\1\0\6\15min_length\3\1\17autocomplete\2\fenabled\2\18documentation\2\ndebug\1\14preselect\fdisable\nsetup\ncompe\1\0\1\texpr\2\27v:lua.s_tab_complete()\f<S-Tab>\1\3\0\0\6i\6s\1\0\1\texpr\2\25v:lua.tab_complete()\n<Tab>\1\3\0\0\6i\6s compe#scroll({'delta': -4})\n<C-b> compe#scroll({'delta': +4})\n<C-f>\25compe#close('<C-e>')\n<C-e>\26compe#confirm('<CR>')\t<CR>\21compe#complete()\14<C-Space>\6i\1\0\2\vsilent\2\texpr\2\bmap\15core.utils\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-compe"
  },
  ["nvim-lightbulb"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-lightbulb"
  },
  ["nvim-lint"] = {
    config = { "require('plugin.lint')" },
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/nvim-lint"
  },
  ["nvim-lspconfig"] = {
    config = { "require('plugin.lsp')" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-lspconfig"
  },
  ["nvim-luaref"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/nvim-luaref"
  },
  ["nvim-nonicons"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/nvim-nonicons"
  },
  ["nvim-tree.lua"] = {
    config = { "require('plugin.nvim_tree')" },
    keys = { { "n", "<C-n>" } },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    after = { "nvim-treesitter-textobjects" },
    config = { "require('plugin.treesitter')" },
    loaded = false,
    needs_bufread = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-treesitter"
  },
  ["nvim-treesitter-textobjects"] = {
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/nvim-treesitter-textobjects"
  },
  ["nvim-web-devicons"] = {
    config = { "require('plugin.nvim_web_devicons')" },
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/packer.nvim"
  },
  playground = {
    commands = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
    loaded = false,
    needs_bufread = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/playground"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/popup.nvim"
  },
  ["requirements.txt.vim"] = {
    loaded = false,
    needs_bufread = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/requirements.txt.vim"
  },
  ["startuptime.vim"] = {
    commands = { "StartupTime" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/startuptime.vim"
  },
  ["symbols-outline.nvim"] = {
    config = { "\27LJ\2\nt\0\0\6\0\a\0\t6\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0'\4\5\0005\5\6\0B\0\5\1K\0\1\0\1\0\1\fnoremap\2\28<Cmd>SymbolsOutline<CR>\15<Leader>so\6n\20nvim_set_keymap\bapi\bvim\0" },
    keys = { { "n", "<Leader>so" } },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/symbols-outline.nvim"
  },
  ["telescope-bookmarks.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/telescope-bookmarks.nvim"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim"
  },
  ["telescope-fzy-native.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/telescope-fzy-native.nvim"
  },
  ["telescope.nvim"] = {
    config = { "require('plugin.telescope')" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/telescope.nvim"
  },
  ["tree-sitter-lua"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/tree-sitter-lua"
  },
  ["vim-cheat40"] = {
    config = { "vim.g.cheat40_use_default = false" },
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-cheat40"
  },
  ["vim-commentary"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-commentary"
  },
  ["vim-cool"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-cool"
  },
  ["vim-easy-align"] = {
    config = { "\27LJ\2\nw\0\0\6\0\a\0\n6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0'\3\4\0'\4\5\0005\5\6\0B\0\5\1K\0\1\0\1\0\2\vsilent\2\fnoremap\1\22<Plug>(EasyAlign)\age\1\3\0\0\6n\6x\bmap\15core.utils\frequire\0" },
    keys = { { "n", "ge" }, { "x", "ge" } },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/vim-easy-align"
  },
  ["vim-eunuch"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-eunuch"
  },
  ["vim-external"] = {
    config = { "require('plugin.vim_external')" },
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-external"
  },
  ["vim-fugitive"] = {
    config = { "require('plugin.fugitive')" },
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-fugitive"
  },
  ["vim-scriptease"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-scriptease"
  },
  ["vim-startify"] = {
    loaded = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/start/vim-startify"
  },
  ["vim-toml"] = {
    loaded = false,
    needs_bufread = true,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/vim-toml"
  },
  ["vista.vim"] = {
    config = { "require('plugin.vista')" },
    keys = { { "n", "<Leader>vv" } },
    loaded = false,
    needs_bufread = false,
    path = "/Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/vista.vim"
  }
}

time("Defining packer_plugins", false)
-- Setup for: clever-f.vim
time("Setup for clever-f.vim", true)
try_loadstring("\27LJ\2\n¥\1\0\0\2\0\a\0\0176\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0)\1\1\0=\1\3\0006\0\0\0009\0\1\0)\1\1\0=\1\4\0006\0\0\0009\0\1\0'\1\6\0=\1\5\0K\0\1\0\a;:#clever_f_chars_match_any_signs\25clever_f_show_prompt\24clever_f_smart_case\28clever_f_across_no_line\6g\bvim\0", "setup", "clever-f.vim")
time("Setup for clever-f.vim", false)
time("packadd for clever-f.vim", true)
vim.cmd [[packadd clever-f.vim]]
time("packadd for clever-f.vim", false)
-- Setup for: nvim-compe
time("Setup for nvim-compe", true)
try_loadstring("\27LJ\2\n…\3\0\0\2\0\14\00016\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0)\1\1\0=\1\3\0006\0\0\0009\0\1\0)\1\1\0=\1\4\0006\0\0\0009\0\1\0)\1\1\0=\1\5\0006\0\0\0009\0\1\0)\1\1\0=\1\6\0006\0\0\0009\0\1\0)\1\1\0=\1\a\0006\0\0\0009\0\1\0)\1\1\0=\1\b\0006\0\0\0009\0\1\0)\1\1\0=\1\t\0006\0\0\0009\0\1\0)\1\1\0=\1\n\0006\0\0\0009\0\1\0)\1\1\0=\1\v\0006\0\0\0009\0\1\0)\1\1\0=\1\f\0006\0\0\0009\0\1\0)\1\1\0=\1\r\0K\0\1\0\23loaded_compe_vsnip\25loaded_compe_vim_lsp\25loaded_compe_vim_lsc\27loaded_compe_ultisnips\28loaded_compe_treesitter\22loaded_compe_tags\23loaded_compe_spell\31loaded_compe_snippets_nvim\22loaded_compe_omni\25loaded_compe_luasnip\23loaded_compe_emoji\22loaded_compe_calc\6g\bvim\0", "setup", "nvim-compe")
time("Setup for nvim-compe", false)
-- Setup for: symbols-outline.nvim
time("Setup for symbols-outline.nvim", true)
try_loadstring("\27LJ\2\nÅ\2\0\0\3\0\a\0\t6\0\0\0009\0\1\0005\1\3\0005\2\4\0=\2\5\0014\2\0\0=\2\6\1=\1\2\0K\0\1\0\18lsp_blacklist\fkeymaps\1\0\6\19focus_location\6o\17code_actions\6a\18rename_symbol\6r\17hover_symbol\14<C-space>\nclose\6q\18goto_location\t<CR>\1\0\4\rposition\nright\17auto_preview\1\16show_guides\2\27highlight_hovered_item\2\20symbols_outline\6g\bvim\0", "setup", "symbols-outline.nvim")
time("Setup for symbols-outline.nvim", false)
-- Config for: vim-cheat40
time("Config for vim-cheat40", true)
vim.g.cheat40_use_default = false
time("Config for vim-cheat40", false)
-- Config for: lir.nvim
time("Config for lir.nvim", true)
require('plugin.lir')
time("Config for lir.nvim", false)
-- Config for: gruvbox-material
time("Config for gruvbox-material", true)
require('plugin.colorscheme')
time("Config for gruvbox-material", false)
-- Config for: nvim-web-devicons
time("Config for nvim-web-devicons", true)
require('plugin.nvim_web_devicons')
time("Config for nvim-web-devicons", false)
-- Config for: nvim-lint
time("Config for nvim-lint", true)
require('plugin.lint')
time("Config for nvim-lint", false)
-- Config for: vim-external
time("Config for vim-external", true)
require('plugin.vim_external')
time("Config for vim-external", false)
-- Config for: vim-fugitive
time("Config for vim-fugitive", true)
require('plugin.fugitive')
time("Config for vim-fugitive", false)

-- Command lazy-loads
time("Defining lazy-load commands", true)
vim.cmd [[command! -nargs=* -range -bang -complete=file TSHighlightCapturesUnderCursor lua require("packer.load")({'playground'}, { cmd = "TSHighlightCapturesUnderCursor", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
vim.cmd [[command! -nargs=* -range -bang -complete=file StartupTime lua require("packer.load")({'startuptime.vim'}, { cmd = "StartupTime", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
vim.cmd [[command! -nargs=* -range -bang -complete=file TSPlaygroundToggle lua require("packer.load")({'playground'}, { cmd = "TSPlaygroundToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
time("Defining lazy-load commands", false)

-- Keymap lazy-loads
time("Defining lazy-load keymaps", true)
vim.cmd [[nnoremap <silent> <Leader>vv <cmd>lua require("packer.load")({'vista.vim'}, { keys = "<lt>Leader>vv", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <C-n> <cmd>lua require("packer.load")({'nvim-tree.lua'}, { keys = "<lt>C-n>", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>cc <cmd>lua require("packer.load")({'nvim-colorizer.lua'}, { keys = "<lt>Leader>cc", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> ge <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "ge", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[xnoremap <silent> ge <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "ge", prefix = "" }, _G.packer_plugins)<cr>]]
vim.cmd [[nnoremap <silent> <Leader>so <cmd>lua require("packer.load")({'symbols-outline.nvim'}, { keys = "<lt>Leader>so", prefix = "" }, _G.packer_plugins)<cr>]]
time("Defining lazy-load keymaps", false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time("Defining lazy-load filetype autocommands", true)
vim.cmd [[au FileType toml ++once lua require("packer.load")({'vim-toml'}, { ft = "toml" }, _G.packer_plugins)]]
vim.cmd [[au FileType applescript ++once lua require("packer.load")({'applescript.vim'}, { ft = "applescript" }, _G.packer_plugins)]]
vim.cmd [[au FileType requirements ++once lua require("packer.load")({'requirements.txt.vim'}, { ft = "requirements" }, _G.packer_plugins)]]
time("Defining lazy-load filetype autocommands", false)
  -- Event lazy-loads
time("Defining lazy-load event autocommands", true)
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'nvim-compe'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufNewFile * ++once lua require("packer.load")({'nvim-treesitter', 'gitsigns.nvim'}, { event = "BufNewFile *" }, _G.packer_plugins)]]
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'telescope.nvim'}, { event = "VimEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufRead * ++once lua require("packer.load")({'nvim-treesitter'}, { event = "BufRead *" }, _G.packer_plugins)]]
vim.cmd [[au BufReadPre * ++once lua require("packer.load")({'gitsigns.nvim', 'nvim-lspconfig'}, { event = "BufReadPre *" }, _G.packer_plugins)]]
time("Defining lazy-load event autocommands", false)
vim.cmd("augroup END")
vim.cmd [[augroup filetypedetect]]
time("Sourcing ftdetect script at: /Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/vim-toml/ftdetect/toml.vim", true)
vim.cmd [[source /Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/vim-toml/ftdetect/toml.vim]]
time("Sourcing ftdetect script at: /Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/vim-toml/ftdetect/toml.vim", false)
time("Sourcing ftdetect script at: /Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/requirements.txt.vim/ftdetect/requirements.vim", true)
vim.cmd [[source /Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/requirements.txt.vim/ftdetect/requirements.vim]]
time("Sourcing ftdetect script at: /Users/dhruvmanilawala/.local/share/nvim/site/pack/packer/opt/requirements.txt.vim/ftdetect/requirements.vim", false)
vim.cmd("augroup END")
if should_profile then save_profiles(0) end

END

catch
  echohl ErrorMsg
  echom "Error in packer_compiled: " .. v:exception
  echom "Please check your config for correctness"
  echohl None
endtry
