local api = vim.api
local utils = require("core.utils")
local Job = require("plenary.job")
local root_pattern = require("lspconfig.util").root_pattern

local M = {}

local finder = {
  stylua = root_pattern("stylua.toml"),
}

function M.stylua(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  local filename = api.nvim_buf_get_name(bufnr)
  local config_dir = finder.stylua(filename)

  if not config_dir then
    return
  end

  local output = Job
      :new({
      command = "stylua",
      args = { "-" },
      writer = api.nvim_buf_get_lines(bufnr, 0, -1, false),
    })
      :sync()

  api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
end

-- function M.black(bufnr)
--   bufnr = bufnr or api.nvim_get_current_buf()

--   local output = Job
--       :new({
--       command = "black",
--       args = { "--quiet", "-" },
--       writer = api.nvim_buf_get_lines(bufnr, 0, -1, false),
--     })
--       :sync()

--   api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
-- end

-- function M.isort(bufnr)
--   bufnr = bufnr or api.nvim_get_current_buf()

--   local output = Job
--       :new({
--       command = "isort",
--       args = { "--profile", "black", "-" },
--       writer = api.nvim_buf_get_lines(bufnr, 0, -1, false),
--     })
--       :sync()

--   api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
-- end

-- Auto formatting for specific filetypes
utils.create_augroups({
  auto_formatting = { "BufWritePre *.lua lua require('core.format').stylua()" },
})

return M
