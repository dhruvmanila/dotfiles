local api = vim.api
local opt_local = vim.opt_local

opt_local.formatprg = "stylua --search-parent-directories --stdin-filepath % -"
opt_local.formatoptions:remove "o"
opt_local.includeexpr = "v:lua.LuaInclude()"

-- This function will be called if vim cannot determine the file path under
-- cursor when using the variants of `gf`. So, it will allow us to jump directly
-- to the file from the `require(...)` path.
--
-- There's a limitation where if the current filename is the same as that of the
-- required path, Vim will not call this function as its thinking the file has
-- been found.
function LuaInclude()
  local module = vim.v.fname:gsub("%.", "/")
  local check = api.nvim_get_runtime_file("lua/" .. module .. ".lua", false)
  if not vim.tbl_isempty(check) then
    return check[1]
  end
  check = api.nvim_get_runtime_file("lua/" .. module .. "/init.lua", false)
  if not vim.tbl_isempty(check) then
    return check[1]
  end
  return module
end
