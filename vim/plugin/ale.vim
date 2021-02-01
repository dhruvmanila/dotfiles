let g:ale_enabled = 1

" Error message format
let g:ale_echo_msg_info_str = 'I'
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %code: %%s [%severity%]'

" Don't lint on opening the files but when I save them
" Also, not when I do some edits
let g:ale_lint_on_enter = 0
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_insert_leave = 0

" Set this variable to 1 to fix files when you save them.
let g:ale_fix_on_save = 1
let g:ale_fixers = {'*': ['remove_trailing_lines', 'trim_whitespace']}

" Custom symbols
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '!'
let g:ale_sign_info = 'i'

" Remove background color
highlight clear ALEErrorSign
highlight clear ALEWarningSign

" Navigate between errors
nmap <silent> [a <Plug>(ale_previous_wrap)
nmap <silent> ]a <Plug>(ale_next_wrap)
