local M = {}

local job = require "dm.job"

---@class GitHubStar
---@field name string
---@field description string
---@field url string

-- Keep the values around between reloads.
---@type { stars: GitHubStar[], max_length: number }
_CachedGithubStars = _CachedGithubStars or { stars = {}, max_length = 0 }

-- Parse the data received from running the GitHub stars job.
---@param data string
local function parse_gh_stars_data(data)
  -- As we're paginating the results, GitHub will separate the page results as:
  -- [{...}, {...}][{...}, {...}] ...
  -- Replace the middle "][" with a "," to make it a valid JSON string.
  data = data:gsub("%]%[", ",")
  local json_data = vim.json.decode(data)
  local max_length = 0
  for _, repo in ipairs(json_data) do
    max_length = math.max(max_length, #repo.full_name)
    table.insert(_CachedGithubStars.stars, {
      name = repo.full_name,
      description = repo.description ~= vim.NIL and repo.description or "",
      url = repo.html_url,
    })
  end
  _CachedGithubStars.max_length = max_length
end

-- Start a new asynchronous job to collect the user GitHub stars using
-- GitHub's CLI tool `gh`. The data will be stored in a global variable
-- `_CachedGithubStars` for the current Neovim session.
---@see telescope._extensions.github_stars
function M.collect_stars()
  job {
    cmd = "gh",
    args = { "api", "user/starred", "--paginate", "--cache", "24h" },
    on_exit = function(result)
      if result.code > 0 then
        dm.notify("Telescope", result.stderr, 4)
        return
      end
      parse_gh_stars_data(result.stdout)
    end,
  }
end

return M
