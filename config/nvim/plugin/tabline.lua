local fn = vim.fn
local has_devicons, devicons = pcall(require, "nvim-web-devicons")

-- Return the currently active session name.
---@return string
local function current_session()
  local session = vim.v.this_session
  if session and session ~= "" then
    return "  " .. vim.fn.fnamemodify(session, ":t") .. " "
  end
  return ""
end

---File flags provider.
---Supported flags: Readonly, modified.
---@param ctx table
---@return string
local function buf_flags(ctx)
  local icon = ""
  if ctx.readonly then
    icon = ""
  elseif ctx.modifiable and ctx.buftype ~= "prompt" then
    if ctx.modified then
      icon = "●"
    end
  end
  return icon
end

---Return the filename for the given context.
---If the buffer is active, then return the filepath from the Git root if we're
---in a Git repository else return the full path.
---
---For non-active buffers, 'help' filetype and 'terminal' buftype,
---return the filename (tail part).
---@param ctx table
---@return string
local function filename(ctx, is_active)
  if ctx.bufname and #ctx.bufname > 0 then
    local modifier
    if is_active and ctx.filetype ~= "help" and ctx.buftype ~= "terminal" then
      modifier = ":~:."
    else
      modifier = ":p:t"
    end
    return fn.fnamemodify(ctx.bufname, modifier)
  elseif ctx.buftype == "prompt" then
    return ctx.filetype == "TelescopePrompt" and ctx.filetype or "[Prompt]"
  elseif ctx.filetype == "dashboard" then
    return "Dashboard"
  else
    return "[No Name]"
  end
end

---Return the filetype icon and highlight group.
---@param ctx table
---@return string, string
local function ft_icon(ctx)
  if not has_devicons then
    return ""
  end
  local extension = fn.fnamemodify(ctx.bufname, ":e")
  return devicons.get_icon(
    --         lir/devicons:12 ┐
    --                         │
    ctx.filetype == "lir" and "lir_folder_icon" or ctx.filename,
    extension,
    { default = true }
  )
end

---Tabline labels
---@param tabnr integer
---@param is_active boolean
---@return string
local function tabline_label(tabnr, is_active)
  local buflist = fn.tabpagebuflist(tabnr)
  local winnr = fn.tabpagewinnr(tabnr)
  local curbuf = buflist[winnr]
  local curbo = vim.bo[curbuf]

  local ctx = {
    bufnr = curbuf,
    bufname = fn.resolve(fn.bufname(curbuf)),
    readonly = curbo.readonly,
    modifiable = curbo.modifiable,
    modified = curbo.modified,
    buftype = curbo.buftype,
    filetype = curbo.filetype,
  }
  ctx.filename = filename(ctx, is_active)

  local flags = buf_flags(ctx)
  local icon, icon_hl = ft_icon(ctx)
  icon_hl = is_active and icon_hl or "TabLine"
  local flag_hl = is_active and "Yellow" or "TabLine"
  local tab_hl = is_active and "%#TabLineSel#" or "%#TabLine#"
  -- Ref: https://en.wikipedia.org/wiki/Block_Elements
  local sep = is_active and "▌" or " "

  return tab_hl
    .. "%"
    .. tabnr
    .. "T" -- Starts mouse click target region
    .. sep
    .. " "
    .. tabnr
    .. ".  "
    .. "%#"
    .. icon_hl
    .. "#"
    .. icon
    .. tab_hl
    .. " "
    .. ctx.filename
    .. "  "
    .. "%#"
    .. flag_hl
    .. "#"
    .. flags
    .. tab_hl
    .. " "
end

---Provide the tabline
---@return string
function _G.nvim_tabline()
  local line = ""
  local current_tabpage = fn.tabpagenr()
  for i = 1, fn.tabpagenr "$" do
    local is_active = i == current_tabpage
    line = line .. tabline_label(i, is_active)
  end
  return line
    .. "%#TabLineFill#" -- After the last tab fill with TabLineFill
    .. "%T" -- Ends mouse click target region(s)
    .. "%="
    .. current_session()
end

-- Show the tabline always
vim.o.showtabline = 2

-- Set the tabline
vim.o.tabline = "%!v:lua.nvim_tabline()"
