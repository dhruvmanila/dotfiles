-- Lazy packer setup. This mainly defines the keybindings, commands,
-- autocmds and path values.
local loader_path = vim.fn.stdpath "data"
  .. "/site/pack/loader/start/packer.nvim/plugin/"

-- This is defined as a global vim variable to be used by `dm.plugins`
vim.g.packer_compiled_path = loader_path .. "packer_compiled.vim"
vim.g.packer_plugin_info_path = loader_path .. "packer_plugin_info.lua"

-- This is done only for a fresh setup when the actual file containing this
-- variable is not created yet.
_PackerPluginInfo = { plugins = {}, max_length = 0 }

do
  local commands = {
    { "PackerInstall", "lua require('dm.plugins').install()" },
    { "PackerUpdate", "lua require('dm.plugins').update()" },
    { "PackerSync", "lua require('dm.plugins').sync()" },
    { "PackerCompile", "lua require('dm.plugins').compile()" },
    { "PackerClean", "lua require('dm.plugins').clean()" },
    { "PackerStatus", "lua require('dm.plugins').status()" },
    { "PackerProfile", "lua require('dm.plugins').profile_output()" },
    { "PackerCompiledEdit", "tabedit " .. vim.g.packer_compiled_path },
  }

  for _, command in ipairs(commands) do
    dm.command(command)
  end
end

dm.autocmd {
  events = { "User PackerComplete" },
  command = "lua require('dm.plugins').dump()",
}

-- PackerSync -> PackerClean + PackerInstall + PackerUpdate + PackerCompile
vim.api.nvim_set_keymap(
  "n",
  "<leader>ps",
  "<Cmd>PackerSync<CR>",
  { noremap = true }
)
