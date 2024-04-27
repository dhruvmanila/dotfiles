vim.api.nvim_create_user_command('SetLogLevel', function(opts)
  dm.log.set_level(opts.fargs[1])
end, {
  nargs = 1,
  complete = function(arglead)
    return vim
      .iter(vim.tbl_keys(dm.log.levels))
      :filter(function(level)
        return type(level) == 'string' and level:match(arglead)
      end)
      :totable()
  end,
  desc = 'Set log level for the root logger',
})
