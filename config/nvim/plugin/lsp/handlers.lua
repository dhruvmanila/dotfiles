local M = vim.lsp.protocol.Methods

do
  -- See: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#messageType
  local levels = {
    vim.log.levels.ERROR, -- MessageType.Error
    vim.log.levels.WARN, -- MessageType.Warning
    vim.log.levels.INFO, -- MessageType.Info
    vim.log.levels.INFO, -- MessageType.Log
    vim.log.levels.DEBUG, -- MessageType.Debug
  }

  -- See: https://github.com/neovim/nvim-lspconfig/wiki/User-contributed-tips#use-nvim-notify-to-display-lsp-messages
  vim.lsp.handlers[M.window_showMessage] = function(err, result, ctx)
    local title = 'LSP (' .. ctx.method .. ')'
    if err ~= nil then
      dm.notify(title, tostring(err), vim.log.levels.ERROR)
      return
    end
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if not client then
      return
    end
    dm.notify(('Server message (%s)'):format(client.name), result.message, levels[result.type])
  end
end

do
  local MessageType = vim.lsp.protocol.MessageType

  -- Override the original handler to allow us to divert the log messages for each server in a
  -- separate log file using the custom logging module.
  vim.lsp.handlers[M.window_logMessage] = function(_, result, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if not client then
      return
    end
    local logger = dm.log.get_logger('lsp.' .. client.name)
    -- Keep the logger level in sync with `vim.lsp`. This is important for `LspSetLogLevel` command.
    logger.set_level(vim.lsp.log.get_level())
    if result.type == MessageType.Error then
      logger.error(result.message)
    elseif result.type == MessageType.Warning then
      logger.warn(result.message)
    elseif result.type == MessageType.Info or result.type == MessageType.Log then
      logger.info(result.message)
    else
      logger.debug(result.message)
    end
  end
end
