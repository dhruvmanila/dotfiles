let g:slime_target = "neovim"
let g:slime_no_mappings = 1

" Use `cpaste -q` to send text to the IPython repl. Another option is to
" disable `autoindent` in the repl.
let g:slime_python_ipython = 1

nmap <leader>sc <Plug>SlimeSendCell
nmap <leader>s  <Plug>SlimeMotionSend
xmap <leader>s  <Plug>SlimeRegionSend
nmap <leader>ss <Plug>SlimeLineSend
nmap <leader>sp <Plug>SlimeParagraphSend

function SlimeOverrideConfig()
  if g:slime_target == "neovim"
    if !exists("b:slime_config")
      let b:slime_config = {}
    endif
    " Avoid the prompt if slime already knows the channel id.
    let b:slime_config["jobid"] = exists("g:slime_last_channel")
          \ ? g:slime_last_channel
          \ : input("[slime] jobid: ")
  endif
endfunction
