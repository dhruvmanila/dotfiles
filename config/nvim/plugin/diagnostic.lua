local icons = dm.icons
local nnoremap = dm.nnoremap
local vdiagnostic = vim.diagnostic

-- Global diagnostic configuration.
vdiagnostic.config {
  underline = false,
  virtual_text = false,
  signs = true,
  severity_sort = true,
}

do
  local prefix = "DiagnosticSign"

  local severity_icons = {
    Error = icons.error,
    Warn = icons.warn,
    Info = icons.info,
    Hint = icons.hint,
  }

  for severity, icon in pairs(severity_icons) do
    local name = prefix .. severity
    vim.fn.sign_define(name, { text = icon, texthl = name })
  end
end

-- Format the diagnostic message to include the `code` value.
---@param diagnostic table
---@return string
local function format_diagnostic(diagnostic)
  local message = diagnostic.message
  local code = diagnostic.code
    or (diagnostic.user_data and diagnostic.user_data.lsp.code)
  if code then
    message = ("%s (%s)"):format(message, code)
  end
  return message
end

local opts = {
  popup_opts = {
    source = "always",
    show_header = false,
    format = format_diagnostic,
    focusable = false,
  },
}

-- For all types of diagnostics: `[d`, `]d`
nnoremap("[d", wrap(vdiagnostic.goto_prev, opts))
nnoremap("]d", wrap(vdiagnostic.goto_next, opts))

opts.severity = { min = vdiagnostic.severity.WARN }
-- For warning and error diagnostics: `[w`, `]w`
nnoremap("[w", wrap(vdiagnostic.goto_prev, opts))
nnoremap("]w", wrap(vdiagnostic.goto_next, opts))

nnoremap("<leader>l", wrap(vdiagnostic.show_line_diagnostics, opts.popup_opts))
