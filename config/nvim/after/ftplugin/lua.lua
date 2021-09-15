local opt_local = vim.opt_local

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
  local fname = vim.v.fname
  local module = fname:gsub("%.", "/")
  for _, lua_path in ipairs(vim.api.nvim_list_runtime_paths()) do
    lua_path = lua_path .. "/lua/"
    local check1 = lua_path .. module .. ".lua"
    local check2 = lua_path .. module .. "/init.lua"
    if vim.fn.filereadable(check1) == 1 then
      return check1
    elseif vim.fn.filereadable(check2) == 1 then
      return check2
    end
  end
  return fname
end
