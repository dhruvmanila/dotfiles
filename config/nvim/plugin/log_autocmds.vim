" Ref: https://github.com/lervag/dotvim/blob/master/personal/plugin/log-autocmds.vim
"
" For more detailed information, take a look at:
" https://github.com/wincent/wincent/blob/main/aspects/vim/files/.config/nvim/autoload/wincent/debug.vim
command! LogAutocmds call s:log_autocmds_toggle()

function! s:log_autocmds_toggle()
  augroup dm__log_autocmds
    autocmd!
  augroup END

  let l:date = strftime('%F', localtime())
  let s:activate = get(s:, 'activate', 0) ? 0 : 1
  if !s:activate
    call s:log('Stopped autocmd log (' . l:date . ')')
    echo "[DEBUG] Logging autocmds: OFF"
    return
  endif

  call s:log('Started autocmd log (' . l:date . ')')
  echo "[DEBUG] Logging autocmds: ON"
  augroup dm__log_autocmds
    for l:au in s:aulist
      silent execute 'autocmd' l:au '* call <SID>log("' . l:au . '")'
    endfor
  augroup END
endfunction

" Add the provided autocmd name and related information to the log file.
" 'a': append to the file
function! s:log(name)
  let l:timestamp = strftime('%T', localtime())
  let l:amatch = fnamemodify(expand('<amatch>'), ':t')
  let l:amatch = l:amatch !=# '' ? ' ' . l:amatch : ''
  call writefile([
        \ '[' . l:timestamp . '] - ' .
        \ a:name .
        \ l:amatch
        \ ], '/tmp/vim_debug.log', 'a')
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
