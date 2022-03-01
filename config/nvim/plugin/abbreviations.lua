local cmd = vim.cmd

-- Helper function to create a *command* abbreviation.
---@param short string
---@param long string
local function cabbrev(short, long)
  cmd(
    (
      "cnoreabbrev <expr> %s getcmdtype() == ':' && getcmdpos() == %d ? '%s' : '%s'"
    ):format(short, #short + 1, long, short)
  )
end

-- Packer commands (`wbthomason/packer.nvim`)
cabbrev("pc", "PackerClean")
cabbrev("po", "PackerCompile")
cabbrev("pi", "PackerInstall")
cabbrev("ps", "PackerSync")
cabbrev("pu", "PackerUpdate")

-- Session commands
cabbrev("sc", "SClose")
cabbrev("sd", "SDelete")
cabbrev("sl", "SLoad")
cabbrev("sr", "SRename")
cabbrev("ss", "SSave")

-- :so -> :source %
cabbrev("so", "source %")

-- For better readability (`tpope/vim-scriptease`)
cabbrev("mes", "Message")
cabbrev("veb", "Verbose")
