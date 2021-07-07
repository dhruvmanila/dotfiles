" Ref: https://github.com/lervag/dotvim/blob/master/personal/plugin/log-autocmds.vim
command! LogAutocmds call s:log_autocmds_toggle()

function! s:log_autocmds_toggle()
  augroup LogAutocmd
    autocmd!
  augroup END

  let l:date = strftime('%F', localtime())
  let s:activate = get(s:, 'activate', 0) ? 0 : 1
  if !s:activate
    call s:log('Stopped autocmd log (' . l:date . ')')
    return
  endif

  call s:log('Started autocmd log (' . l:date . ')')
  augroup LogAutocmd
    for l:au in s:aulist
      silent execute 'autocmd' l:au '* call s:log(''' . l:au . ''')'
    endfor
  augroup END
endfunction

function! s:log(message)
  silent execute '!echo "'
        \ . strftime('%T', localtime()) . ' - ' . a:message . '"'
        \ '>> /tmp/vim_log_autocommands'
endfunction

" These are deliberately left out due to side effects
" - SourceCmd
" - FileAppendCmd
" - FileWriteCmd
" - BufWriteCmd
" - FileReadCmd
" - BufReadCmd
" - FuncUndefined

let s:aulist = [
      \ 'BufAdd',
      \ 'BufCreate',
      \ 'BufDelete',
      \ 'BufEnter',
      \ 'BufFilePost',
      \ 'BufFilePre',
      \ 'BufHidden',
      \ 'BufLeave',
      \ 'BufNew',
      \ 'BufNewFile',
      \ 'BufRead',
      \ 'BufReadPost',
      \ 'BufReadPre',
      \ 'BufUnload',
      \ 'BufWinEnter',
      \ 'BufWinLeave',
      \ 'BufWipeout',
      \ 'BufWrite',
      \ 'BufWritePost',
      \ 'BufWritePre',
      \ 'CmdlineChanged',
      \ 'CmdlineEnter',
      \ 'CmdlineLeave',
      \ 'CmdUndefined',
      \ 'CmdwinEnter',
      \ 'CmdwinLeave',
      \ 'ColorScheme',
      \ 'CompleteDone',
      \ 'CursorHold',
      \ 'CursorHoldI',
      \ 'CursorMoved',
      \ 'CursorMovedI',
      \ 'EncodingChanged',
      \ 'FileAppendPost',
      \ 'FileAppendPre',
      \ 'FileChangedRO',
      \ 'FileChangedShell',
      \ 'FileChangedShellPost',
      \ 'FileReadPost',
      \ 'FileReadPre',
      \ 'FileType',
      \ 'FileWritePost',
      \ 'FileWritePre',
      \ 'FilterReadPost',
      \ 'FilterReadPre',
      \ 'FilterWritePost',
      \ 'FilterWritePre',
      \ 'FocusGained',
      \ 'FocusLost',
      \ 'GUIEnter',
      \ 'GUIFailed',
      \ 'InsertChange',
      \ 'InsertCharPre',
      \ 'InsertEnter',
      \ 'InsertLeave',
      \ 'MenuPopup',
      \ 'QuickFixCmdPost',
      \ 'QuickFixCmdPre',
      \ 'QuitPre',
      \ 'RemoteReply',
      \ 'SessionLoadPost',
      \ 'ShellCmdPost',
      \ 'ShellFilterPost',
      \ 'SourcePre',
      \ 'SpellFileMissing',
      \ 'StdinReadPost',
      \ 'StdinReadPre',
      \ 'SwapExists',
      \ 'Syntax',
      \ 'TabEnter',
      \ 'TabLeave',
      \ 'TermOpen',
      \ 'TermEnter',
      \ 'TermLeave',
      \ 'TermClose',
      \ 'TermChanged',
      \ 'TermResponse',
      \ 'TextChanged',
      \ 'TextChangedI',
      \ 'User',
      \ 'VimEnter',
      \ 'VimLeave',
      \ 'VimLeavePre',
      \ 'VimResized',
      \ 'WinEnter',
      \ 'WinLeave',
      \ ]

