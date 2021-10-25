local log = dm.log
local job = require "dm.job"

-- Default configuration for the source.
local defaults = {
  -- Maximum number of issues to fetch.
  limit = 100,
}

local source = {}
source.__index = source

function source:new()
  return setmetatable({
    cache = {},
  }, self)
end

-- Check whether the source is available or not.
---@return boolean
function source:is_available()
  return vim.bo.filetype == "gitcommit"
end

-- Return a list of characters which will trigger the source completion.
---@return string[]
function source:get_trigger_characters()
  return { "#" }
end

-- Invoke completion.
function source:complete(params, callback)
  params.option = vim.tbl_deep_extend("keep", params.option, defaults)
  local bufnr = vim.api.nvim_get_current_buf()

  if self.cache[bufnr] then
    callback { items = self.cache[bufnr], isIncomplete = false }
  else
    job {
      cmd = "gh",
      args = {
        "issue",
        "list",
        "--limit",
        params.option.limit,
        "--json",
        "title,number,body",
      },
      on_exit = function(result)
        local ok, parsed = pcall(vim.json.decode, result.stdout)
        if not ok then
          log.fmt_error("Failed to parse `gh` result: %s", parsed)
          return
        end

        local items = {}
        for _, issue in ipairs(parsed) do
          issue.body = issue.body and issue.body:gsub("\r", "") or ""
          table.insert(items, {
            label = ("#%s"):format(issue.number),
            documentation = {
              kind = "markdown",
              value = ("# %s\n\n%s"):format(issue.title, issue.body),
            },
          })
        end

        callback { items = items, isIncomplete = false }
        self.cache[bufnr] = items
      end,
    }
  end
end

-- Register the source with `nvim-cmp`.
require("cmp").register_source("gh_issue", source:new())
