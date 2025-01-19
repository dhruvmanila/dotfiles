---@type string[]
local events = {}

-- Flag to denote the current state of logging autocmds.
local logging_autocmds = false

local function toggle_autocmds_logging()
  local logger = dm.log.get_logger 'dm.autocmds'
  logger.set_level(dm.log.levels.INFO)

  logging_autocmds = not logging_autocmds
  local id = vim.api.nvim_create_augroup('dm__log_autocmds', { clear = true })

  if not logging_autocmds then
    logger.info '---------- Logging autocmds: OFF ----------'
    return
  end

  logger.info '---------- Logging autocmds: ON ----------'
  for _, event in ipairs(events) do
    vim.api.nvim_create_autocmd(event, {
      group = id,
      callback = function(args)
        logger.info(
          'event="%s"\tmatch="%s"\tdata=%s',
          args.event,
          vim.fs.basename(args.match) or args.match,
          vim.inspect(args.data)
        )
      end,
    })
  end
end

vim.api.nvim_create_user_command('ToggleAutocmdsLogging', toggle_autocmds_logging, {
  desc = 'Toggle autocmds logging',
})

-- These are deliberately left out due to side effects
--   - SourceCmd
--   - FileAppendCmd
--   - FileWriteCmd
--   - BufWriteCmd
--   - FileReadCmd
--   - BufReadCmd
--   - FuncUndefined

events = {
  'BufAdd',
  'BufCreate',
  'BufDelete',
  'BufEnter',
  'BufFilePost',
  'BufFilePre',
  'BufHidden',
  'BufLeave',
  'BufNew',
  'BufNewFile',
  'BufRead',
  'BufReadPost',
  'BufReadPre',
  'BufUnload',
  'BufWinEnter',
  'BufWinLeave',
  'BufWipeout',
  'BufWrite',
  'BufWritePost',
  'BufWritePre',
  'CmdlineChanged',
  'CmdlineEnter',
  'CmdlineLeave',
  'CmdUndefined',
  'CmdwinEnter',
  'CmdwinLeave',
  'ColorScheme',
  'CompleteDone',
  'CursorHold',
  'CursorHoldI',
  'CursorMoved',
  'CursorMovedI',
  'EncodingChanged',
  'FileAppendPost',
  'FileAppendPre',
  'FileChangedRO',
  'FileChangedShell',
  'FileChangedShellPost',
  'FileReadPost',
  'FileReadPre',
  'FileType',
  'FileWritePost',
  'FileWritePre',
  'FilterReadPost',
  'FilterReadPre',
  'FilterWritePost',
  'FilterWritePre',
  'FocusGained',
  'FocusLost',
  'GUIEnter',
  'GUIFailed',
  'InsertChange',
  'InsertCharPre',
  'InsertEnter',
  'InsertLeave',
  'InsertLeavePre',
  'MenuPopup',
  'QuickFixCmdPost',
  'QuickFixCmdPre',
  'QuitPre',
  'RemoteReply',
  'SessionLoadPost',
  'ShellCmdPost',
  'ShellFilterPost',
  'SourcePre',
  'SpellFileMissing',
  'StdinReadPost',
  'StdinReadPre',
  'SwapExists',
  'Syntax',
  'TabEnter',
  'TabLeave',
  'TermOpen',
  'TermEnter',
  'TermLeave',
  'TermClose',
  'TermChanged',
  'TermRequest',
  'TermResponse',
  'TextChanged',
  'TextChangedI',
  'User',
  'VimEnter',
  'VimLeave',
  'VimLeavePre',
  'VimResized',
  'WinEnter',
  'WinLeave',
  'WinScrolled',
}

if vim.env.NVIM_LOG_AUTOCMDS then
  toggle_autocmds_logging()
end
