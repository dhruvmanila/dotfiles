local M = {}

-- Keep the values around between reloads.
---@type GitHubStar[]
_CachedGithubStars = _CachedGithubStars or {}

-- Parse the data received from running the GitHub stars job.
---@param data string
local function parse_gh_stars_data(data)
  -- As we're paginating the results, GitHub will separate the page results as:
  -- [{...}, {...}][{...}, {...}] ...
  -- Replace the middle "][" with a "," to make it a valid JSON string.
  data = data:gsub('%]%[', ',')
  local json_data = vim.json.decode(data)
  for _, repo in ipairs(json_data) do
    table.insert(_CachedGithubStars, {
      name = repo.full_name,
      description = repo.description ~= vim.NIL and repo.description or '',
      url = repo.html_url,
    })
  end
end

-- Start a new asynchronous job to collect the user GitHub stars using
-- GitHub's CLI tool `gh`. The data will be stored in a global variable
-- `_CachedGithubStars` for the current Neovim session.
---@see telescope._extensions.github_stars
function M.collect_stars()
  vim.system(
    { 'gh', 'api', 'user/starred', '--paginate', '--cache', '24h' },
    ---@param result vim.SystemCompleted
    function(result)
      if result.code > 0 then
        dm.notify('Telescope', result.stderr, 4)
        return
      end
      parse_gh_stars_data(result.stdout)
    end
  )
end

return M
