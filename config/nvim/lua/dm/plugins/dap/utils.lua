local M = {}

-- Helper function to ask the user for arguments.
---@return thread
function M.ask_for_arguments()
  return coroutine.create(function(dap_run_co)
    vim.ui.input({ prompt = 'Arguments: ' }, function(args)
      if args then
        coroutine.resume(
          dap_run_co,
          vim.split(args, ' +', { trimempty = true })
        )
      end
    end)
  end)
end

return M
