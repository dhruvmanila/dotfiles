local icons = dm.icons
local nnoremap = dm.nnoremap
local vdiagnostic = vim.diagnostic

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

-- Global diagnostic configuration.
vdiagnostic.config {
  underline = false,
  virtual_text = false,
  signs = true,
  severity_sort = true,
  float = {
    show_header = false,
    source = "always",
    format = format_diagnostic,
  },
}

-- For all types of diagnostics: `[d`, `]d`
nnoremap("[d", wrap(vdiagnostic.goto_prev, { float = { focusable = false } }))
nnoremap("]d", wrap(vdiagnostic.goto_next, { float = { focusable = false } }))

-- For warning and error diagnostics: `[w`, `]w`
nnoremap(
  "[w",
  wrap(vdiagnostic.goto_prev, {
    float = { focusable = false },
    severity = { min = vdiagnostic.severity.WARN },
  })
)
nnoremap(
  "]w",
  wrap(vdiagnostic.goto_next, {
    float = { focusable = false },
    severity = { min = vdiagnostic.severity.WARN },
  })
)

nnoremap("<leader>l", wrap(vdiagnostic.open_float, 0, { scope = "line" }))
