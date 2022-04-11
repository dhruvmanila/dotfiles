local log = require('dm.log').new {
  plugin = 'autocmds',
  use_console = false,
}

---@type string[]
local events = {}

-- Flag to denote the current state of logging autocmds.
local logging_autocmds = false

local function toggle_autocmds_logging()
  logging_autocmds = not logging_autocmds
  local id = vim.api.nvim_create_augroup('dm__log_autocmds', { clear = true })

  if not logging_autocmds then
    vim.notify 'Logging autocmds: OFF'
    return
  end

  vim.notify 'Logging autocmds: ON'
  for _, event in ipairs(events) do
    vim.api.nvim_create_autocmd(event, {
      group = id,
      callback = function(args)
        log.info(
          ('%s %s'):format(args.event, vim.fn.fnamemodify(args.match, ':t'))
        )
      end,
    })
  end
end

vim.api.nvim_add_user_command('LogAutocmds', toggle_autocmds_logging, {
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
