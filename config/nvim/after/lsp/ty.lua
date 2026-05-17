---@type vim.lsp.Config
return {
  cmd = { 'ty', 'server' },
  init_options = {
    logLevel = 'debug',
    logFile = vim.fn.stdpath 'log' .. '/lsp.ty.log',
  },
}
